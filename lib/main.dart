import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/campaign_level.dart';
import 'screens/main_menu.dart';
import 'screens/sandbox_game_screen.dart';
import 'screens/challenge_game_screen.dart';
import 'screens/campaign_screens.dart';
import 'screens/stacking_game_screen.dart';
import 'services/dev_mode_service.dart';
import 'services/high_score_service.dart';
import 'services/level_progress_service.dart';
import 'services/orientation_service.dart';
import 'services/theme_service.dart';
import 'utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final themeService = await ThemeService.getInstance();
  await DevModeService.getInstance();
  await OrientationService.getInstance();

  // Lock to preferred orientation (default portrait, can be changed in menu)
  await OrientationService.instance.lockOrientation();

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
  int _logoTapCount = 0;
  DateTime? _lastTapTime;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Listen to service changes
    ThemeService.instance.addListener(_onStateChanged);
    DevModeService.instance.addListener(_onStateChanged);
    OrientationService.instance.addListener(_onOrientationChanged);
  }

  @override
  void dispose() {
    ThemeService.instance.removeListener(_onStateChanged);
    DevModeService.instance.removeListener(_onStateChanged);
    OrientationService.instance.removeListener(_onOrientationChanged);
    super.dispose();
  }

  void _onOrientationChanged() {
    // Lock to new orientation and rebuild
    OrientationService.instance.lockOrientation();
    setState(() {});
  }

  void _onStateChanged() {
    setState(() {});
  }

  void _onLogoTap() {
    final now = DateTime.now();

    // Reset tap count if more than 2 seconds have passed
    if (_lastTapTime != null && now.difference(_lastTapTime!).inMilliseconds > 2000) {
      _logoTapCount = 0;
    }

    _lastTapTime = now;
    _logoTapCount++;

    if (_logoTapCount >= DevModeService.tapsToUnlock) {
      // Toggle dev mode
      DevModeService.instance.toggleDevMode();
      _logoTapCount = 0;

      // Haptic feedback
      HapticFeedback.heavyImpact();
    }
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
      isLandscape: OrientationService.instance.isLandscape,
      isDevMode: DevModeService.instance.isDevMode,
      onLogoTap: _onLogoTap,
      onThemeToggle: () {
        ThemeService.instance.toggleTheme();
      },
      onOrientationToggle: () {
        OrientationService.instance.toggleOrientation();
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
            builder: (context) => const SandboxGameScreen(),
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
