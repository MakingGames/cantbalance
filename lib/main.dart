import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/sandbox_game.dart';
import 'game/challenge_game.dart';
import 'screens/main_menu.dart';
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
      title: 'Cant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: GameColors.background,
      ),
      home: const MainMenuScreen(),
    );
  }
}

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainMenu(
      onChallengePressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => GameScreen(
              game: ChallengeGame(
                onExit: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        );
      },
      onSandboxPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => GameScreen(
              game: SandboxGame(
                onExit: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class GameScreen extends StatelessWidget {
  final FlameGame game;

  const GameScreen({super.key, required this.game});

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
