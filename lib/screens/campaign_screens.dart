import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../components/wind_indicator.dart';
import '../game/campaign_game.dart';
import '../game/campaign_level.dart';
import '../game/shape_size.dart';
import '../services/level_progress_service.dart';
import '../services/orientation_service.dart';
import '../utils/colors.dart';
import 'game_hud.dart';
import 'level_complete_overlay.dart';
import 'level_intro_card.dart';
import 'level_select.dart';
import 'mechanic_indicators.dart';
import 'shape_picker.dart';
import 'tilt_indicator.dart';

/// Campaign level select screen wrapper
class CampaignSelectScreen extends StatefulWidget {
  final LevelProgressService progressService;

  const CampaignSelectScreen({super.key, required this.progressService});

  @override
  State<CampaignSelectScreen> createState() => _CampaignSelectScreenState();
}

class _CampaignSelectScreenState extends State<CampaignSelectScreen> {
  @override
  Widget build(BuildContext context) {
    return LevelSelectScreen(
      progressService: widget.progressService,
      onBack: () => Navigator.of(context).pop(),
      onLevelSelected: (level) async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CampaignLevelScreen(
              level: level,
              progressService: widget.progressService,
            ),
          ),
        );
        // Refresh UI after returning from level
        setState(() {});
      },
    );
  }
}

/// Campaign level gameplay screen
class CampaignLevelScreen extends StatefulWidget {
  final CampaignLevel level;
  final LevelProgressService progressService;

  const CampaignLevelScreen({
    super.key,
    required this.level,
    required this.progressService,
  });

  @override
  State<CampaignLevelScreen> createState() => _CampaignLevelScreenState();
}

class _CampaignLevelScreenState extends State<CampaignLevelScreen> {
  late CampaignGame _game;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  bool _showIntro = true;
  bool _showWin = false;
  bool _showLose = false;
  int _score = 0;
  ShapeSize _selectedShapeSize = ShapeSize.medium;

  // ValueNotifiers for high-frequency updates - avoids 60x/sec full rebuilds
  late final ValueNotifier<double> _tiltNotifier = ValueNotifier(0);
  late final ValueNotifier<double> _timeNotifier = ValueNotifier(0);
  late final ValueNotifier<double> _heightNotifier = ValueNotifier(0);
  late final ValueNotifier<({WindState state, double direction})> _windNotifier =
      ValueNotifier((state: WindState.inactive, direction: 0));

  @override
  void initState() {
    super.initState();
    _createNewGame();
    _startAccelerometer();
  }

  void _startAccelerometer() {
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      final tilt = OrientationService.instance.getAdjustedTilt(event.x, event.y);
      _game.updateBeamFromTilt(tilt);
    });
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _tiltNotifier.dispose();
    _timeNotifier.dispose();
    _heightNotifier.dispose();
    _windNotifier.dispose();
    super.dispose();
  }

  void _createNewGame() {
    _game = CampaignGame(
      level: widget.level,
      onWin: (score) async {
        await widget.progressService.completeLevel(widget.level.number, score);
        HapticFeedback.heavyImpact();
        setState(() {
          _showWin = true;
          _score = score;
        });
      },
      onLose: (angle, score) {
        HapticFeedback.mediumImpact();
        setState(() {
          _showLose = true;
          _score = score;
        });
      },
      onScoreChanged: (score) {
        setState(() {
          _score = score;
        });
      },
      onTiltChanged: (angle) => _tiltNotifier.value = angle,
      onTimePressureChanged: (remaining, total) => _timeNotifier.value = remaining,
      onHeightChanged: (height, target) => _heightNotifier.value = height,
      onShapePlaced: () {
        HapticFeedback.lightImpact();
      },
      onWindChanged: (isActive, isWarning, direction) {
        final state = isActive
            ? WindState.active
            : isWarning
                ? WindState.warning
                : WindState.inactive;
        _windNotifier.value = (state: state, direction: direction);
      },
    );
  }

  void _onShapeSizeChanged(ShapeSize size) {
    setState(() {
      _selectedShapeSize = size;
    });
    _game.selectShapeSize(size);
  }

  void _retry() {
    // Reset notifiers
    _tiltNotifier.value = 0;
    _timeNotifier.value = 0;
    _heightNotifier.value = 0;
    _windNotifier.value = (state: WindState.inactive, direction: 0);

    setState(() {
      _showIntro = true;
      _showWin = false;
      _showLose = false;
      _score = 0;
      _selectedShapeSize = ShapeSize.medium;
      _createNewGame();
    });
  }

  void _goToLevelSelect() {
    Navigator.of(context).pop();
  }

  void _goToNextLevel() {
    final nextLevelNumber = widget.level.number + 1;
    if (nextLevelNumber <= CampaignLevel.all.length) {
      final nextLevel = CampaignLevel.all[nextLevelNumber - 1];
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => CampaignLevelScreen(
            level: nextLevel,
            progressService: widget.progressService,
          ),
        ),
      );
    }
  }

  void _startGame() {
    setState(() {
      _showIntro = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show intro card before game starts
    if (_showIntro) {
      return LevelIntroCard(
        level: widget.level,
        onStart: _startGame,
        onBack: () => Navigator.of(context).pop(),
      );
    }

    return GameHUD(
      gameWidget: GameWidget(
        key: ValueKey(_game.hashCode),
        game: _game,
        backgroundBuilder: (context) => Container(
          color: GameColors.background,
        ),
      ),
      onBack: () => Navigator.of(context).pop(),
      showHUD: !_showWin && !_showLose,
      // Left side: wind indicator and mechanic indicators
      leftIndicators: [
        // Wind indicator (shown when level has wind)
        if (widget.level.hasWind)
          ValueListenableBuilder<({WindState state, double direction})>(
            valueListenable: _windNotifier,
            builder: (context, wind, _) => AnimatedWindIndicator(
              state: wind.state,
              direction: wind.direction,
            ),
          ),
        if (_hasMechanicIndicators())
          ValueListenableBuilder<double>(
            valueListenable: _timeNotifier,
            builder: (context, timeRemaining, _) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: MechanicIndicators(
                hasWind: false, // Wind shown via AnimatedWindIndicator above
                hasGravity: widget.level.hasIncreasedGravity,
                hasInstability: widget.level.hasBeamInstability,
                hasTimer: widget.level.hasTimePressure,
                gravityMultiplier: widget.level.hasIncreasedGravity
                    ? widget.level.gravityY / 10.0
                    : null,
                timeRemaining: widget.level.hasTimePressure ? timeRemaining : null,
              ),
            ),
          ),
      ],
      // Center: Level info and progress
      centerContent: ValueListenableBuilder<double>(
        valueListenable: _heightNotifier,
        builder: (context, height, _) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'LEVEL ${widget.level.number}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                letterSpacing: 4,
                color: GameColors.beam.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${height.toStringAsFixed(1)} / ${widget.level.targetHeight.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w200,
                letterSpacing: 4,
                color: GameColors.beam.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
      // Right: Tilt indicator
      rightContent: SizedBox(
        width: 48,
        child: ValueListenableBuilder<double>(
          valueListenable: _tiltNotifier,
          builder: (context, tilt, _) => TiltIndicator(angleDegrees: tilt),
        ),
      ),
      // Bottom: Shape picker
      bottomContent: ShapePicker(
        selectedSize: _selectedShapeSize,
        onSizeChanged: _onShapeSizeChanged,
      ),
      // Overlays: Win/Lose screens
      overlays: [
        if (_showWin)
          LevelCompleteOverlay(
            level: widget.level,
            score: _score,
            hasNextLevel: widget.level.number < CampaignLevel.all.length,
            onNextLevel: _goToNextLevel,
            onRetry: _retry,
            onLevelSelect: _goToLevelSelect,
          ),
        if (_showLose)
          LevelFailedOverlay(
            level: widget.level,
            score: _score,
            onRetry: _retry,
            onLevelSelect: _goToLevelSelect,
          ),
      ],
    );
  }

  bool _hasMechanicIndicators() {
    return widget.level.hasWind ||
        widget.level.hasIncreasedGravity ||
        widget.level.hasBeamInstability ||
        widget.level.hasTimePressure;
  }
}
