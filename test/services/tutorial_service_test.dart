import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cant/services/tutorial_service.dart';

void main() {
  group('TutorialService', () {
    setUp(() {
      TutorialService.resetForTesting();
      SharedPreferences.setMockInitialValues({});
    });

    group('initialization', () {
      test('getInstance returns service instance', () async {
        SharedPreferences.setMockInitialValues({});
        final service = await TutorialService.getInstance();

        expect(service, isNotNull);
        expect(service, isA<TutorialService>());
      });

      test('getInstance returns same instance on subsequent calls', () async {
        SharedPreferences.setMockInitialValues({});
        final service1 = await TutorialService.getInstance();
        final service2 = await TutorialService.getInstance();

        expect(identical(service1, service2), true);
      });

      test('synchronous instance getter works after initialization', () async {
        SharedPreferences.setMockInitialValues({});
        final asyncInstance = await TutorialService.getInstance();
        final syncInstance = TutorialService.instance;

        expect(identical(asyncInstance, syncInstance), true);
      });
    });

    group('hasSeenTutorial', () {
      test('returns false when tutorial not seen', () async {
        SharedPreferences.setMockInitialValues({});
        final service = await TutorialService.getInstance();

        expect(service.hasSeenTutorial, false);
      });

      test('returns true when tutorial was seen', () async {
        SharedPreferences.setMockInitialValues({'tutorial_seen': true});
        final service = await TutorialService.getInstance();

        expect(service.hasSeenTutorial, true);
      });

      test('returns false when preference is explicitly false', () async {
        SharedPreferences.setMockInitialValues({'tutorial_seen': false});
        final service = await TutorialService.getInstance();

        expect(service.hasSeenTutorial, false);
      });
    });

    group('markTutorialSeen', () {
      test('marks tutorial as seen', () async {
        SharedPreferences.setMockInitialValues({});
        final service = await TutorialService.getInstance();

        expect(service.hasSeenTutorial, false);

        await service.markTutorialSeen();

        expect(service.hasSeenTutorial, true);
      });

      test('persists seen state', () async {
        SharedPreferences.setMockInitialValues({});
        final service = await TutorialService.getInstance();

        await service.markTutorialSeen();

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('tutorial_seen'), true);
      });
    });

    group('resetTutorial', () {
      test('resets tutorial seen state', () async {
        SharedPreferences.setMockInitialValues({'tutorial_seen': true});
        final service = await TutorialService.getInstance();

        expect(service.hasSeenTutorial, true);

        await service.resetTutorial();

        expect(service.hasSeenTutorial, false);
      });

      test('removes tutorial key from preferences', () async {
        SharedPreferences.setMockInitialValues({'tutorial_seen': true});
        final service = await TutorialService.getInstance();

        await service.resetTutorial();

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('tutorial_seen'), isNull);
      });
    });
  });
}
