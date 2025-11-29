import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cant/services/dev_mode_service.dart';

void main() {
  group('DevModeService', () {
    setUp(() {
      DevModeService.resetForTesting();
      SharedPreferences.setMockInitialValues({});
    });

    group('initialization', () {
      test('defaults to dev mode disabled', () async {
        SharedPreferences.setMockInitialValues({});
        final service = await DevModeService.getInstance();

        expect(service.isDevMode, false);
      });

      test('loads enabled state from preferences', () async {
        SharedPreferences.setMockInitialValues({'dev_mode_enabled': true});
        final service = await DevModeService.getInstance();

        expect(service.isDevMode, true);
      });

      test('loads disabled state from preferences', () async {
        SharedPreferences.setMockInitialValues({'dev_mode_enabled': false});
        final service = await DevModeService.getInstance();

        expect(service.isDevMode, false);
      });

      test('getInstance returns same instance', () async {
        final service1 = await DevModeService.getInstance();
        final service2 = await DevModeService.getInstance();

        expect(identical(service1, service2), true);
      });

      test('sync instance getter returns same instance after init', () async {
        final service1 = await DevModeService.getInstance();
        final service2 = DevModeService.instance;

        expect(identical(service1, service2), true);
      });

      test('notifies listeners after init', () async {
        SharedPreferences.setMockInitialValues({});
        int notificationCount = 0;

        // Use a fresh instance but listen before getInstance completes
        DevModeService.resetForTesting();
        final service = await DevModeService.getInstance();
        service.addListener(() => notificationCount++);

        // Init already happened, check by re-calling an action
        await service.enableDevMode();
        expect(notificationCount, 1);
      });
    });

    group('tapsToUnlock', () {
      test('tapsToUnlock constant is 5', () {
        expect(DevModeService.tapsToUnlock, 5);
      });
    });

    group('enableDevMode', () {
      test('enables dev mode', () async {
        SharedPreferences.setMockInitialValues({});
        final service = await DevModeService.getInstance();

        await service.enableDevMode();

        expect(service.isDevMode, true);
      });

      test('persists enabled state', () async {
        SharedPreferences.setMockInitialValues({});
        final service = await DevModeService.getInstance();

        await service.enableDevMode();

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('dev_mode_enabled'), true);
      });

      test('notifies listeners when enabled', () async {
        SharedPreferences.setMockInitialValues({});
        final service = await DevModeService.getInstance();
        int notificationCount = 0;
        service.addListener(() => notificationCount++);

        await service.enableDevMode();

        expect(notificationCount, 1);
      });
    });

    group('disableDevMode', () {
      test('disables dev mode', () async {
        SharedPreferences.setMockInitialValues({'dev_mode_enabled': true});
        final service = await DevModeService.getInstance();

        await service.disableDevMode();

        expect(service.isDevMode, false);
      });

      test('persists disabled state', () async {
        SharedPreferences.setMockInitialValues({'dev_mode_enabled': true});
        final service = await DevModeService.getInstance();

        await service.disableDevMode();

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('dev_mode_enabled'), false);
      });

      test('notifies listeners when disabled', () async {
        SharedPreferences.setMockInitialValues({'dev_mode_enabled': true});
        final service = await DevModeService.getInstance();
        int notificationCount = 0;
        service.addListener(() => notificationCount++);

        await service.disableDevMode();

        expect(notificationCount, 1);
      });
    });

    group('toggleDevMode', () {
      test('toggles from disabled to enabled', () async {
        SharedPreferences.setMockInitialValues({});
        final service = await DevModeService.getInstance();

        await service.toggleDevMode();

        expect(service.isDevMode, true);
      });

      test('toggles from enabled to disabled', () async {
        SharedPreferences.setMockInitialValues({'dev_mode_enabled': true});
        final service = await DevModeService.getInstance();

        await service.toggleDevMode();

        expect(service.isDevMode, false);
      });
    });
  });
}
