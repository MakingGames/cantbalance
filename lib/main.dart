import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'game/sandbox_game.dart';
import 'game/challenge_game.dart';
import 'game/shape_size.dart';
import 'screens/main_menu.dart';
import 'screens/game_over_overlay.dart';
import 'screens/shape_picker.dart';
import 'screens/tilt_indicator.dart';
import 'services/high_score_service.dart';
import 'utils/colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: GameColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const CantApp());
}

class CantApp extends StatelessWidget {
  const CantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cant Balance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: GameColors.background,
      ),
      home: const MainMenuScreen(),
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

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final service = await HighScoreService.getInstance();
    setState(() {
      _highScore = service.highScore;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainMenu(
      highScore: _highScore,
      onChallengePressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ChallengeGameScreen(),
          ),
        );
        // Refresh high score when returning from game
        _loadHighScore();
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
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  bool _showGameOver = false;
  double _finalAngle = 0;
  int _score = 0;
  int _highScore = 0;
  bool _isNewHighScore = false;
  double _currentTilt = 0;
  bool _showTiltIndicator = true;
  ShapeSize _selectedShapeSize = ShapeSize.medium;

  @override
  void initState() {
    super.initState();
    _initHighScoreService();
    _createNewGame();
    _startAccelerometer();
  }

  void _startAccelerometer() {
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      // event.x: tilt left/right (negative = tilted left)
      // Pass to game to adjust gravity
      _game.updateGravityFromTilt(event.x);
    });
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initHighScoreService() async {
    _highScoreService = await HighScoreService.getInstance();
    setState(() {
      _highScore = _highScoreService!.highScore;
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
