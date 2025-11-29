import 'package:flutter_test/flutter_test.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:cant/game/systems/spatial_hash.dart';
import 'package:mocktail/mocktail.dart';

class MockBody extends Mock implements Body {}

void main() {
  group('SpatialHash', () {
    late SpatialHash spatialHash;

    MockBody createMockBody(double x, double y) {
      final body = MockBody();
      when(() => body.position).thenReturn(Vector2(x, y));
      return body;
    }

    setUp(() {
      spatialHash = SpatialHash(cellSize: 2.0);
    });

    group('initialization', () {
      test('creates with specified cell size', () {
        final hash = SpatialHash(cellSize: 5.0);
        expect(hash.cellSize, 5.0);
      });
    });

    group('insert', () {
      test('inserts body into spatial hash', () {
        final body = createMockBody(1.0, 1.0);
        spatialHash.insert(body);

        final nearby = spatialHash.getNearby(Vector2(1.0, 1.0)).toList();
        expect(nearby, contains(body));
      });

      test('multiple bodies in same cell', () {
        final body1 = createMockBody(0.5, 0.5);
        final body2 = createMockBody(0.7, 0.7);
        spatialHash.insert(body1);
        spatialHash.insert(body2);

        final nearby = spatialHash.getNearby(Vector2(0.5, 0.5)).toList();
        expect(nearby, containsAll([body1, body2]));
      });

      test('bodies in different cells are stored separately', () {
        final body1 = createMockBody(0.0, 0.0);
        final body2 = createMockBody(10.0, 10.0);
        spatialHash.insert(body1);
        spatialHash.insert(body2);

        final nearbyOrigin = spatialHash.getNearby(Vector2(0.0, 0.0)).toList();
        final nearbyFar = spatialHash.getNearby(Vector2(10.0, 10.0)).toList();

        expect(nearbyOrigin, contains(body1));
        expect(nearbyOrigin, isNot(contains(body2)));
        expect(nearbyFar, contains(body2));
        expect(nearbyFar, isNot(contains(body1)));
      });
    });

    group('getNearby', () {
      test('returns bodies in same cell', () {
        final body = createMockBody(1.0, 1.0);
        spatialHash.insert(body);

        final nearby = spatialHash.getNearby(Vector2(1.5, 1.5)).toList();
        expect(nearby, contains(body));
      });

      test('returns bodies in adjacent cells (3x3 grid)', () {
        // Cell size is 2.0, so body at (0.5, 0.5) is in cell (0, 0)
        final centerBody = createMockBody(0.5, 0.5);
        // Body at (2.5, 0.5) is in cell (1, 0) - adjacent
        final adjacentBody = createMockBody(2.5, 0.5);
        // Body at (-1.5, 0.5) is in cell (-1, 0) - adjacent
        final adjacentBody2 = createMockBody(-1.5, 0.5);

        spatialHash.insert(centerBody);
        spatialHash.insert(adjacentBody);
        spatialHash.insert(adjacentBody2);

        final nearby = spatialHash.getNearby(Vector2(0.5, 0.5)).toList();
        expect(nearby, containsAll([centerBody, adjacentBody, adjacentBody2]));
      });

      test('excludes bodies beyond adjacent cells', () {
        final nearBody = createMockBody(0.5, 0.5);
        // Body at (10.0, 10.0) is 5 cells away - too far
        final farBody = createMockBody(10.0, 10.0);

        spatialHash.insert(nearBody);
        spatialHash.insert(farBody);

        final nearby = spatialHash.getNearby(Vector2(0.5, 0.5)).toList();
        expect(nearby, contains(nearBody));
        expect(nearby, isNot(contains(farBody)));
      });

      test('returns empty when no bodies inserted', () {
        final nearby = spatialHash.getNearby(Vector2(0.0, 0.0)).toList();
        expect(nearby, isEmpty);
      });

      test('returns empty when position is far from all bodies', () {
        final body = createMockBody(0.0, 0.0);
        spatialHash.insert(body);

        final nearby = spatialHash.getNearby(Vector2(100.0, 100.0)).toList();
        expect(nearby, isEmpty);
      });
    });

    group('clear', () {
      test('removes all bodies', () {
        final body1 = createMockBody(0.0, 0.0);
        final body2 = createMockBody(5.0, 5.0);
        spatialHash.insert(body1);
        spatialHash.insert(body2);

        spatialHash.clear();

        final nearby1 = spatialHash.getNearby(Vector2(0.0, 0.0)).toList();
        final nearby2 = spatialHash.getNearby(Vector2(5.0, 5.0)).toList();
        expect(nearby1, isEmpty);
        expect(nearby2, isEmpty);
      });

      test('can insert after clear', () {
        final body1 = createMockBody(0.0, 0.0);
        spatialHash.insert(body1);
        spatialHash.clear();

        final body2 = createMockBody(1.0, 1.0);
        spatialHash.insert(body2);

        final nearby = spatialHash.getNearby(Vector2(1.0, 1.0)).toList();
        expect(nearby, contains(body2));
        expect(nearby, isNot(contains(body1)));
      });
    });

    group('negative coordinates', () {
      test('handles negative x coordinates', () {
        final body = createMockBody(-5.0, 0.0);
        spatialHash.insert(body);

        final nearby = spatialHash.getNearby(Vector2(-5.0, 0.0)).toList();
        expect(nearby, contains(body));
      });

      test('handles negative y coordinates', () {
        final body = createMockBody(0.0, -5.0);
        spatialHash.insert(body);

        final nearby = spatialHash.getNearby(Vector2(0.0, -5.0)).toList();
        expect(nearby, contains(body));
      });

      test('handles negative x and y coordinates', () {
        final body = createMockBody(-3.0, -7.0);
        spatialHash.insert(body);

        final nearby = spatialHash.getNearby(Vector2(-3.0, -7.0)).toList();
        expect(nearby, contains(body));
      });

      test('adjacency works across zero boundary', () {
        // Body in positive cell
        final positiveBody = createMockBody(0.5, 0.5);
        // Body in negative cell (cell -1, -1)
        final negativeBody = createMockBody(-0.5, -0.5);

        spatialHash.insert(positiveBody);
        spatialHash.insert(negativeBody);

        // Query from origin should find both
        final nearby = spatialHash.getNearby(Vector2(0.0, 0.0)).toList();
        expect(nearby, containsAll([positiveBody, negativeBody]));
      });
    });

    group('cell boundaries', () {
      test('body exactly on cell boundary goes to correct cell', () {
        // Cell size is 2.0, so x=2.0 should go to cell (1, 0)
        final body = createMockBody(2.0, 0.0);
        spatialHash.insert(body);

        // Query from cell (1, 0)
        final nearby = spatialHash.getNearby(Vector2(2.5, 0.5)).toList();
        expect(nearby, contains(body));
      });

      test('bodies at adjacent cell boundaries are found', () {
        // Body at exactly 2.0 (cell boundary)
        final body = createMockBody(2.0, 0.0);
        spatialHash.insert(body);

        // Query from cell (0, 0) should still find it (adjacent to cell 1)
        final nearby = spatialHash.getNearby(Vector2(0.5, 0.5)).toList();
        expect(nearby, contains(body));
      });
    });

    group('performance', () {
      test('handles large number of insertions efficiently', () {
        final stopwatch = Stopwatch()..start();

        // Insert 1000 bodies
        for (int i = 0; i < 1000; i++) {
          final body = createMockBody(i * 0.1, (i % 100) * 0.1);
          spatialHash.insert(body);
        }

        stopwatch.stop();

        // Should complete in under 100ms (generous for CI variance)
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });

      test('getNearby is efficient with sparse data', () {
        // Insert bodies spread across wide area
        for (int i = 0; i < 100; i++) {
          final body = createMockBody(i * 10.0, i * 10.0);
          spatialHash.insert(body);
        }

        final stopwatch = Stopwatch()..start();

        // Query 100 times
        for (int i = 0; i < 100; i++) {
          spatialHash.getNearby(Vector2(i * 10.0, i * 10.0)).toList();
        }

        stopwatch.stop();

        // Should complete quickly
        expect(stopwatch.elapsedMilliseconds, lessThan(50));
      });
    });
  });
}
