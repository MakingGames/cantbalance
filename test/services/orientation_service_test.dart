import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cant/services/orientation_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OrientationService', () {
    setUp(() {
      OrientationService.resetForTesting();
      SharedPreferences.setMockInitialValues({});
    });

    group('initialization', () {
      test('defaults to portrait when no preference exists', () async {
        SharedPreferences.setMockInitialValues({});
        final service = await OrientationService.getInstance();

        expect(service.orientation, GameOrientation.portrait);
        expect(service.isPortrait, true);
        expect(service.isLandscape, false);
      });

      test('loads landscape from preferences', () async {
        SharedPreferences.setMockInitialValues({'game_orientation': 'landscape'});
        final service = await OrientationService.getInstance();

        expect(service.orientation, GameOrientation.landscape);
        expect(service.isLandscape, true);
        expect(service.isPortrait, false);
      });

      test('loads portrait from preferences', () async {
        SharedPreferences.setMockInitialValues({'game_orientation': 'portrait'});
        final service = await OrientationService.getInstance();

        expect(service.orientation, GameOrientation.portrait);
        expect(service.isPortrait, true);
      });

      test('getInstance returns same instance on subsequent calls', () async {
        SharedPreferences.setMockInitialValues({});
        final service1 = await OrientationService.getInstance();
        final service2 = await OrientationService.getInstance();

        expect(identical(service1, service2), true);
      });

      test('synchronous instance getter works after initialization', () async {
        SharedPreferences.setMockInitialValues({});
        final asyncInstance = await OrientationService.getInstance();
        final syncInstance = OrientationService.instance;

        expect(identical(asyncInstance, syncInstance), true);
      });
    });

    group('setOrientation', () {
      test('sets orientation to landscape', () async {
        SharedPreferences.setMockInitialValues({});
        final service = await OrientationService.getInstance();

        await service.setOrientation(GameOrientation.landscape);

        expect(service.orientation, GameOrientation.landscape);
        expect(service.isLandscape, true);
      });

      test('sets orientation to portrait', () async {
        SharedPreferences.setMockInitialValues({'game_orientation': 'landscape'});
        final service = await OrientationService.getInstance();

        await service.setOrientation(GameOrientation.portrait);

        expect(service.orientation, GameOrientation.portrait);
        expect(service.isPortrait, true);
      });

      test('persists orientation preference', () async {
        SharedPreferences.setMockInitialValues({});
        final service = await OrientationService.getInstance();

        await service.setOrientation(GameOrientation.landscape);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('game_orientation'), 'landscape');
      });

      test('notifies listeners when orientation changes', () async {
        SharedPreferences.setMockInitialValues({});
        final service = await OrientationService.getInstance();
        int notificationCount = 0;
        service.addListener(() => notificationCount++);

        await service.setOrientation(GameOrientation.landscape);

        expect(notificationCount, 1);
      });

      test('does not notify listeners when orientation is unchanged', () async {
        SharedPreferences.setMockInitialValues({});
        final service = await OrientationService.getInstance();
        int notificationCount = 0;
        service.addListener(() => notificationCount++);

        await service.setOrientation(GameOrientation.portrait);

        expect(notificationCount, 0);
      });
    });

    group('toggleOrientation', () {
      test('toggles from portrait to landscape', () async {
        SharedPreferences.setMockInitialValues({'game_orientation': 'portrait'});
        final service = await OrientationService.getInstance();

        await service.toggleOrientation();

        expect(service.orientation, GameOrientation.landscape);
      });

      test('toggles from landscape to portrait', () async {
        SharedPreferences.setMockInitialValues({'game_orientation': 'landscape'});
        final service = await OrientationService.getInstance();

        await service.toggleOrientation();

        expect(service.orientation, GameOrientation.portrait);
      });
    });

    group('lockOrientation', () {
      test('locks to landscape orientations when in landscape mode', () async {
        SharedPreferences.setMockInitialValues({'game_orientation': 'landscape'});
        final service = await OrientationService.getInstance();

        // Mock the platform channel
        final List<List<String>> capturedOrientations = [];
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'SystemChrome.setPreferredOrientations') {
            capturedOrientations.add(List<String>.from(call.arguments as List));
          }
          return null;
        });

        await service.lockOrientation();

        expect(capturedOrientations.last, contains('DeviceOrientation.landscapeLeft'));
        expect(capturedOrientations.last, contains('DeviceOrientation.landscapeRight'));
      });

      test('locks to portrait orientations when in portrait mode', () async {
        SharedPreferences.setMockInitialValues({'game_orientation': 'portrait'});
        final service = await OrientationService.getInstance();

        final List<List<String>> capturedOrientations = [];
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'SystemChrome.setPreferredOrientations') {
            capturedOrientations.add(List<String>.from(call.arguments as List));
          }
          return null;
        });

        await service.lockOrientation();

        expect(capturedOrientations.last, contains('DeviceOrientation.portraitUp'));
        expect(capturedOrientations.last, contains('DeviceOrientation.portraitDown'));
      });
    });

    group('unlockOrientation', () {
      test('unlocks to all orientations', () async {
        SharedPreferences.setMockInitialValues({});
        final service = await OrientationService.getInstance();

        final List<List<String>> capturedOrientations = [];
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'SystemChrome.setPreferredOrientations') {
            capturedOrientations.add(List<String>.from(call.arguments as List));
          }
          return null;
        });

        await service.unlockOrientation();

        expect(capturedOrientations.last, contains('DeviceOrientation.portraitUp'));
        expect(capturedOrientations.last, contains('DeviceOrientation.portraitDown'));
        expect(capturedOrientations.last, contains('DeviceOrientation.landscapeLeft'));
        expect(capturedOrientations.last, contains('DeviceOrientation.landscapeRight'));
      });
    });

    group('getAdjustedTilt', () {
      test('returns accelX in portrait mode', () async {
        SharedPreferences.setMockInitialValues({'game_orientation': 'portrait'});
        final service = await OrientationService.getInstance();

        final tilt = service.getAdjustedTilt(2.5, 1.0);

        expect(tilt, 2.5);
      });

      test('returns negative accelY in landscape mode', () async {
        SharedPreferences.setMockInitialValues({'game_orientation': 'landscape'});
        final service = await OrientationService.getInstance();

        final tilt = service.getAdjustedTilt(2.5, 1.0);

        expect(tilt, -1.0);
      });

      test('correctly handles negative values in portrait', () async {
        SharedPreferences.setMockInitialValues({'game_orientation': 'portrait'});
        final service = await OrientationService.getInstance();

        final tilt = service.getAdjustedTilt(-3.0, 2.0);

        expect(tilt, -3.0);
      });

      test('correctly handles negative values in landscape', () async {
        SharedPreferences.setMockInitialValues({'game_orientation': 'landscape'});
        final service = await OrientationService.getInstance();

        final tilt = service.getAdjustedTilt(1.0, -2.5);

        expect(tilt, 2.5);
      });
    });
  });
}
