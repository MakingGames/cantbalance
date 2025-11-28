import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'game/sandbox_game.dart';
import 'game/challenge_game.dart';
import 'game/campaign_game.dart';
import 'game/stacking_game.dart';
import 'game/stacking_physics.dart';
import 'game/campaign_level.dart';
import 'game/game_level.dart';
import 'game/shape_size.dart';
import 'game/shape_type.dart';
import 'screens/main_menu.dart';
import 'screens/game_over_overlay.dart';
import 'screens/level_select.dart';
import 'screens/level_complete_overlay.dart';
import 'screens/shape_picker.dart';
import 'screens/tilt_indicator.dart';
import 'screens/tutorial_overlay.dart';
import 'services/high_score_service.dart';
import 'services/level_progress_service.dart';
import 'services/theme_service.dart';
import 'services/tutorial_service.dart';
import 'utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize theme service
  final themeService = await ThemeService.getInstance();

  // Lock to portrait orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(CantApp(themeService: themeService));
}

class CantApp extends StatelessWidget {
  final ThemeService themeService;

  const CantApp({super.key, required this.themeService});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeService,
      builder: (context, _) {
        // Update system UI based on theme
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                themeService.isDarkMode ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: GameColors.background,
            systemNavigationBarIconBrightness:
                themeService.isDarkMode ? Brightness.light : Brightness.dark,
          ),
        );

        return MaterialApp(
          title: 'Cant Balance',
          debugShowCheckedModeBanner: false,
          theme: themeService.isDarkMode
              ? ThemeData.dark().copyWith(
                  scaffoldBackgroundColor: GameColors.background,
                )
              : ThemeData.light().copyWith(
                  scaffoldBackgroundColor: GameColors.background,
                ),
          home: const MainMenuScreen(),
        );
      },
    );
  }
}

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  int _highScore = 0;
  int _campaignStars = 0;
  LevelProgressService? _progressService;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Listen to theme changes to rebuild the menu
    ThemeService.instance.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    ThemeService.instance.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  Future<void> _loadData() async {
    final highScoreService = await HighScoreService.getInstance();
    final progressService = await LevelProgressService.getInstance();
    setState(() {
      _highScore = highScoreService.highScore;
      _campaignStars = progressService.totalStars;
      _progressService = progressService;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainMenu(
      highScore: _highScore,
      campaignStars: _campaignStars,
      totalCampaignLevels: CampaignLevel.all.length,
      isDarkMode: ThemeService.instance.isDarkMode,
      onThemeToggle: () {
        ThemeService.instance.toggleTheme();
      },
      onChallengePressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ChallengeGameScreen(),
          ),
        );
        // Refresh high score when returning from game
        _loadData();
      },
      onSandboxPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SandboxGameScreen(
              game: SandboxGame(),
            ),
          ),
        );
      },
      onCampaignPressed: () async {
        if (_progressService == null) return;
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CampaignSelectScreen(
              progressService: _progressService!,
            ),
          ),
        );
        // Refresh campaign stars when returning
        _loadData();
      },
      onStackingPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const StackingGameScreen(),
          ),
        );
      },
    );
  }
}

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
                            color: GameColors.accent,
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

/// Sandbox mode screen (simple, no game over)
class SandboxGameScreen extends StatelessWidget {
  final FlameGame game;

  const SandboxGameScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      body: Stack(
        children: [
          GameWidget(
            game: game,
            backgroundBuilder: (context) => Container(
              color: GameColors.background,
            ),
          ),
          // Back button overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.arrow_back,
                  color: GameColors.beam.withValues(alpha: 0.6),
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
  bool _showWin = false;
  bool _showLose = false;
  int _score = 0;
  double _currentTilt = 0;
  ShapeSize _selectedShapeSize = ShapeSize.medium;

  @override
  void initState() {
    super.initState();
    _createNewGame();
    _startAccelerometer();
  }

  void _startAccelerometer() {
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      _game.updateBeamFromTilt(event.x);
    });
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
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
    );
  }

  void _onShapeSizeChanged(ShapeSize size) {
    setState(() {
      _selectedShapeSize = size;
    });
    _game.selectShapeSize(size);
  }

  void _retry() {
    setState(() {
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
          if (!_showWin && !_showLose)
            SafeArea(
              child: Column(
                children: [
                  // Top bar: back button, level info, and progress
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
                        // Level info and progress
                        Column(
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
                              '$_score / ${widget.level.targetShapes}',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w200,
                                letterSpacing: 4,
                                color: GameColors.beam.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                        // Tilt indicator placeholder for symmetry
                        SizedBox(
                          width: 48,
                          child: TiltIndicator(angleDegrees: _currentTilt),
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
          // Win overlay
          if (_showWin)
            LevelCompleteOverlay(
              level: widget.level,
              score: _score,
              hasNextLevel: widget.level.number < CampaignLevel.all.length,
              onNextLevel: _goToNextLevel,
              onRetry: _retry,
              onLevelSelect: _goToLevelSelect,
            ),
          // Lose overlay
          if (_showLose)
            LevelFailedOverlay(
              level: widget.level,
              score: _score,
              onRetry: _retry,
              onLevelSelect: _goToLevelSelect,
            ),
        ],
      ),
    );
  }
}

/// Stacking mode screen - infinite vertical stacking
class StackingGameScreen extends StatefulWidget {
  const StackingGameScreen({super.key});

  @override
  State<StackingGameScreen> createState() => _StackingGameScreenState();
}

class _StackingGameScreenState extends State<StackingGameScreen> {
  late StackingGame _game;
  bool _showGameOver = false;
  int _score = 0;
  double _height = 0;
  ShapeSize _selectedShapeSize = ShapeSize.medium;
  GameShapeType _nextShapeType = GameShapeType.square;
  bool _showTestPanel = false;
  StackingPhysics _physics = StackingPhysics();

  @override
  void initState() {
    super.initState();
    _createNewGame();
  }

  void _createNewGame() {
    _game = StackingGame(
      onGameOver: (score) {
        HapticFeedback.mediumImpact();
        setState(() {
          _showGameOver = true;
          _score = score;
        });
      },
      onScoreChanged: (score) {
        setState(() {
          _score = score;
        });
      },
      onHeightChanged: (height) {
        setState(() {
          _height = height;
        });
      },
      onNextShapeChanged: (nextShape) {
        setState(() {
          _nextShapeType = nextShape;
        });
      },
      onShapePlaced: () {
        HapticFeedback.lightImpact();
      },
    );
  }

  void _onShapeSizeChanged(ShapeSize size) {
    setState(() {
      _selectedShapeSize = size;
    });
    _game.selectShapeSize(size);
  }

  void _updatePhysics(StackingPhysics newPhysics) {
    setState(() {
      _physics = newPhysics;
    });
    _game.updatePhysics(newPhysics);
  }

  void _restart() {
    setState(() {
      _showGameOver = false;
      _score = 0;
      _height = 0;
      _selectedShapeSize = ShapeSize.medium;
      _createNewGame();
    });
    // Re-apply physics settings to new game
    _game.updatePhysics(_physics);
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
                  // Top bar: back button, next shape, height, and score
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
                        // Next shape preview
                        Column(
                          children: [
                            Text(
                              'NEXT',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 2,
                                color: GameColors.beam.withValues(alpha: 0.4),
                              ),
                            ),
                            const SizedBox(height: 4),
                            _NextShapePreview(shapeType: _nextShapeType),
                          ],
                        ),
                        // Height and score display
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${_height.toStringAsFixed(1)}m',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w200,
                                letterSpacing: 4,
                                color: GameColors.beam.withValues(alpha: 0.8),
                              ),
                            ),
                            Text(
                              '$_score shapes',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 2,
                                color: GameColors.beam.withValues(alpha: 0.5),
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
            _StackingGameOverOverlay(
              score: _score,
              height: _height,
              onRestart: _restart,
              onMenu: () => Navigator.of(context).pop(),
            ),
          // Test panel toggle button (top-left, below back button area)
          if (!_showGameOver)
            Positioned(
              left: 16,
              top: 80,
              child: SafeArea(
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _showTestPanel = !_showTestPanel;
                    });
                  },
                  icon: Icon(
                    _showTestPanel ? Icons.science : Icons.science_outlined,
                    color: _showTestPanel
                        ? GameColors.beam
                        : GameColors.beam.withValues(alpha: 0.4),
                    size: 24,
                  ),
                ),
              ),
            ),
          // Test panel
          if (_showTestPanel && !_showGameOver)
            Positioned(
              left: 16,
              top: 130,
              child: SafeArea(
                child: _PhysicsTestPanel(
                  physics: _physics,
                  onPhysicsChanged: _updatePhysics,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Test panel for physics settings
class _PhysicsTestPanel extends StatelessWidget {
  final StackingPhysics physics;
  final void Function(StackingPhysics) onPhysicsChanged;

  const _PhysicsTestPanel({
    required this.physics,
    required this.onPhysicsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GameColors.background.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: GameColors.beam.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'PHYSICS TEST',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              color: GameColors.beam.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          _PhysicsToggle(
            label: 'High Friction',
            tooltip: 'Shapes grip each other better\n(friction: 2.0 vs 0.8)',
            value: physics.highFriction,
            onChanged: (v) => onPhysicsChanged(physics.copyWith(highFriction: v)),
          ),
          _PhysicsToggle(
            label: 'High Damping',
            tooltip: 'Shapes settle faster, less sliding\n(linear: 2.0, angular: 3.0)',
            value: physics.highDamping,
            onChanged: (v) => onPhysicsChanged(physics.copyWith(highDamping: v)),
          ),
          _PhysicsToggle(
            label: 'Magnetic',
            tooltip: 'Shapes attract when close\n(range: 1.5 units)',
            value: physics.magneticAttraction,
            onChanged: (v) => onPhysicsChanged(physics.copyWith(magneticAttraction: v)),
          ),
          _PhysicsToggle(
            label: 'Sticky (Velcro)',
            tooltip: 'Very high friction for max grip\n(friction: 5.0)',
            value: physics.stickyContacts,
            onChanged: (v) => onPhysicsChanged(physics.copyWith(stickyContacts: v)),
          ),
        ],
      ),
    );
  }
}

class _PhysicsToggle extends StatelessWidget {
  final String label;
  final String tooltip;
  final bool value;
  final void Function(bool) onChanged;

  const _PhysicsToggle({
    required this.label,
    required this.tooltip,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      preferBelow: false,
      textStyle: TextStyle(
        fontSize: 12,
        color: GameColors.background,
      ),
      decoration: BoxDecoration(
        color: GameColors.beam,
        borderRadius: BorderRadius.circular(4),
      ),
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: value
                    ? GameColors.beam.withValues(alpha: 0.3)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: value
                      ? GameColors.beam
                      : GameColors.beam.withValues(alpha: 0.4),
                  width: value ? 2 : 1,
                ),
              ),
              child: value
                  ? Icon(
                      Icons.check,
                      size: 12,
                      color: GameColors.beam,
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: value
                    ? GameColors.beam
                    : GameColors.beam.withValues(alpha: 0.6),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StackingGameOverOverlay extends StatelessWidget {
  final int score;
  final double height;
  final VoidCallback onRestart;
  final VoidCallback onMenu;

  const _StackingGameOverOverlay({
    required this.score,
    required this.height,
    required this.onRestart,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GameColors.background.withValues(alpha: 0.9),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'TOWER COLLAPSED',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 8,
                  color: GameColors.beam,
                ),
              ),
              const SizedBox(height: 48),
              Text(
                '${height.toStringAsFixed(1)}m',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w100,
                  letterSpacing: 4,
                  color: GameColors.beam,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$score SHAPES',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 4,
                  color: GameColors.beam.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 64),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ActionButton(
                    icon: Icons.home,
                    label: 'MENU',
                    onTap: onMenu,
                  ),
                  const SizedBox(width: 24),
                  _ActionButton(
                    icon: Icons.refresh,
                    label: 'RETRY',
                    onTap: onRestart,
                    isPrimary: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isPrimary
              ? GameColors.beam.withValues(alpha: 0.2)
              : Colors.transparent,
          border: Border.all(
            color: isPrimary
                ? GameColors.beam
                : GameColors.beam.withValues(alpha: 0.4),
            width: isPrimary ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isPrimary
                  ? GameColors.beam
                  : GameColors.beam.withValues(alpha: 0.7),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: 2,
                color: isPrimary
                    ? GameColors.beam
                    : GameColors.beam.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Preview widget for the next shape in stacking mode
class _NextShapePreview extends StatelessWidget {
  final GameShapeType shapeType;

  const _NextShapePreview({required this.shapeType});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        border: Border.all(
          color: GameColors.beam.withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(20, 20),
          painter: _ShapePreviewPainter(shapeType: shapeType),
        ),
      ),
    );
  }
}

class _ShapePreviewPainter extends CustomPainter {
  final GameShapeType shapeType;

  _ShapePreviewPainter({required this.shapeType});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = GameColors.shapeMedium
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final halfSize = size.width / 2 - 2;

    switch (shapeType) {
      case GameShapeType.square:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: center, width: halfSize * 1.6, height: halfSize * 1.6),
            const Radius.circular(2),
          ),
          paint,
        );
      case GameShapeType.circle:
        canvas.drawCircle(center, halfSize * 0.85, paint);
      case GameShapeType.triangle:
        final path = Path()
          ..moveTo(center.dx, center.dy - halfSize * 0.9)
          ..lineTo(center.dx - halfSize * 0.9, center.dy + halfSize * 0.7)
          ..lineTo(center.dx + halfSize * 0.9, center.dy + halfSize * 0.7)
          ..close();
        canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_ShapePreviewPainter oldDelegate) {
    return oldDelegate.shapeType != shapeType;
  }
}
