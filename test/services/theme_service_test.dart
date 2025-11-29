import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cant/services/theme_service.dart';

void main() {
  group('ThemeService', () {
    setUp(() {
      ThemeService.resetForTesting();
      SharedPreferences.setMockInitialValues({});
    });

    group('initialization', () {
      test('defaults to dark mode when no preference exists', () async {
        SharedPreferences.setMockInitialValues({});
        final service = await ThemeService.getInstance();

        expect(service.themeMode, GameThemeMode.dark);
        expect(service.isDarkMode, true);
      });

      test('loads light mode from preferences', () async {
        SharedPreferences.setMockInitialValues({'game_theme_mode': 'light'});
        final service = await ThemeService.getInstance();

        expect(service.themeMode, GameThemeMode.light);
        expect(service.isDarkMode, false);
      });

      test('loads dark mode from preferences', () async {
        SharedPreferences.setMockInitialValues({'game_theme_mode': 'dark'});
        final service = await ThemeService.getInstance();

        expect(service.themeMode, GameThemeMode.dark);
        expect(service.isDarkMode, true);
      });

      test('getInstance returns same instance on subsequent calls', () async {
        SharedPreferences.setMockInitialValues({});
        final service1 = await ThemeService.getInstance();
        final service2 = await ThemeService.getInstance();

        expect(identical(service1, service2), true);
      });

      test('synchronous instance getter works after initialization', () async {
        SharedPreferences.setMockInitialValues({});
        final asyncInstance = await ThemeService.getInstance();
        final syncInstance = ThemeService.instance;

        expect(identical(asyncInstance, syncInstance), true);
      });
    });

    group('setThemeMode', () {
      test('sets theme to light mode', () async {
        SharedPreferences.setMockInitialValues({});
        final service = await ThemeService.getInstance();

        await service.setThemeMode(GameThemeMode.light);

        expect(service.themeMode, GameThemeMode.light);
        expect(service.isDarkMode, false);
      });

      test('sets theme to dark mode', () async {
        SharedPreferences.setMockInitialValues({'game_theme_mode': 'light'});
        final service = await ThemeService.getInstance();

        await service.setThemeMode(GameThemeMode.dark);

        expect(service.themeMode, GameThemeMode.dark);
        expect(service.isDarkMode, true);
      });

      test('persists theme preference', () async {
        SharedPreferences.setMockInitialValues({});
        final service = await ThemeService.getInstance();

        await service.setThemeMode(GameThemeMode.light);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('game_theme_mode'), 'light');
      });

      test('notifies listeners when theme changes', () async {
        SharedPreferences.setMockInitialValues({});
        final service = await ThemeService.getInstance();
        int notificationCount = 0;
        service.addListener(() => notificationCount++);

        await service.setThemeMode(GameThemeMode.light);

        expect(notificationCount, 1);
      });
    });

    group('toggleTheme', () {
      test('toggles from dark to light', () async {
        SharedPreferences.setMockInitialValues({'game_theme_mode': 'dark'});
        final service = await ThemeService.getInstance();

        await service.toggleTheme();

        expect(service.themeMode, GameThemeMode.light);
      });

      test('toggles from light to dark', () async {
        SharedPreferences.setMockInitialValues({'game_theme_mode': 'light'});
        final service = await ThemeService.getInstance();

        await service.toggleTheme();

        expect(service.themeMode, GameThemeMode.dark);
      });
    });
  });
}
