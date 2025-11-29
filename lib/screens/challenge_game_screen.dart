import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../game/challenge_game.dart';
import '../game/game_level.dart';
import '../game/shape_size.dart';
import '../services/high_score_service.dart';
import '../services/tutorial_service.dart';
import '../utils/colors.dart';
import 'game_over_overlay.dart';
import 'shape_picker.dart';
import 'tilt_indicator.dart';
import 'tutorial_overlay.dart';

/// Challenge mode screen with game over handling
class ChallengeGameScreen extends StatefulWidget {
  const ChallengeGameScreen({super.key});

  @override
  State<ChallengeGameScreen> createState() => _ChallengeGameScreenState();
}

class _ChallengeGameScreenState extends State<ChallengeGameScreen> {
  late ChallengeGame _game;
  HighScoreService? _highScoreService;
  TutorialService? _tutorialService;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  bool _showGameOver = false;
  bool _showTutorial = false;
  double _finalAngle = 0;
  int _score = 0;
  int _highScore = 0;
  bool _isNewHighScore = false;
  double _currentTilt = 0;
  bool _showTiltIndicator = true;
  ShapeSize _selectedShapeSize = ShapeSize.medium;
  GameLevel? _levelNotification;
  Timer? _levelNotificationTimer;

  @override
  void initState() {
    super.initState();
    _initServices();
    _createNewGame();
    _startAccelerometer();
  }

  Future<void> _initServices() async {
    _highScoreService = await HighScoreService.getInstance();
    _tutorialService = await TutorialService.getInstance();
    setState(() {
      _highScore = _highScoreService!.highScore;
      _showTutorial = !_tutorialService!.hasSeenTutorial;
    });
  }

  void _startAccelerometer() {
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      // event.x: tilt left/right (negative = tilted left)
      // Pass to game to tilt the beam
      _game.updateBeamFromTilt(event.x);
    });
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _levelNotificationTimer?.cancel();
    super.dispose();
  }

  void _showLevelUp(GameLevel level) {
    // Don't show for level 1 (starting level)
    if (level == GameLevel.basics) return;

    _levelNotificationTimer?.cancel();

    setState(() {
      _levelNotification = level;
    });

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Auto-dismiss after 2.5 seconds
    _levelNotificationTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _levelNotification = null;
        });
      }
    });
  }

  void _dismissTutorial() {
    _tutorialService?.markTutorialSeen();
    setState(() {
      _showTutorial = false;
    });
  }

  void _createNewGame() {
    _game = ChallengeGame(
      onGameOver: (angle, score) async {
        final isNew = await _highScoreService?.submitScore(score) ?? false;
        // Haptic feedback for game over
        if (isNew) {
          HapticFeedback.heavyImpact();
        } else {
          HapticFeedback.mediumImpact();
        }
        setState(() {
          _showGameOver = true;
          _finalAngle = angle;
          _score = score;
          _isNewHighScore = isNew;
          if (isNew) _highScore = score;
        });
      },
      onScoreChanged: (score) {
        setState(() {
          _score = score;
        });
      },
      onTiltChanged: (angle) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _currentTilt = angle;
            });
          }
        });
      },
      onShapePlaced: () {
        HapticFeedback.lightImpact();
      },
      onLevelChanged: _showLevelUp,
    );
  }

  void _onShapeSizeChanged(ShapeSize size) {
    setState(() {
      _selectedShapeSize = size;
    });
    _game.selectShapeSize(size);
  }

  void _restart() {
    setState(() {
      _showGameOver = false;
      _score = 0;
      _isNewHighScore = false;
      _selectedShapeSize = ShapeSize.medium;
      _createNewGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      body: Stack(
        children: [
          GameWidget(
            key: ValueKey(_game.hashCode),
            game: _game,
            backgroundBuilder: (context) => Container(
              color: GameColors.background,
            ),
          ),
          // HUD overlay (only show when playing)
          if (!_showGameOver)
            SafeArea(
              child: Column(
                children: [
                  // Top bar: back button and score
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back button
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.arrow_back,
                            color: GameColors.beam.withValues(alpha: 0.6),
                            size: 28,
                          ),
                        ),
                        // Score and tilt indicator
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showTiltIndicator = !_showTiltIndicator;
                                });
                              },
                              child: _showTiltIndicator
                                  ? TiltIndicator(
                                      angleDegrees: _currentTilt,
                                    )
                                  : Icon(
                                      Icons.radio_button_unchecked,
                                      color: GameColors.beam.withValues(alpha: 0.3),
                                      size: 24,
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '$_score',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w200,
                                letterSpacing: 4,
                                color: GameColors.beam.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Bottom: shape picker
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: ShapePicker(
                      selectedSize: _selectedShapeSize,
                      onSizeChanged: _onShapeSizeChanged,
                    ),
                  ),
                ],
              ),
            ),
          // Game over overlay
          if (_showGameOver)
            GameOverOverlay(
              finalAngle: _finalAngle,
              score: _score,
              highScore: _highScore,
              isNewHighScore: _isNewHighScore,
              onRestart: _restart,
              onMenu: () => Navigator.of(context).pop(),
            ),
          // Tutorial overlay (first launch)
          if (_showTutorial)
            TutorialOverlay(onDismiss: _dismissTutorial),
          // Level up notification
          if (_levelNotification != null)
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    decoration: BoxDecoration(
                      color: GameColors.background.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'LEVEL ${_levelNotification!.number}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 6,
                            color: GameColors.beam,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _levelNotification!.challenge,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 3,
                            color: GameColors.beam,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
