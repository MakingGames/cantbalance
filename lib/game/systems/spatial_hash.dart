import 'package:flame_forge2d/flame_forge2d.dart';

/// Spatial hash for efficient proximity queries.
///
/// Divides the world into a grid of cells and allows fast lookup of
/// bodies within a given region. This reduces O(n²) comparisons to O(n*k)
/// where k is the average number of bodies per cell region.
class SpatialHash {
  final double cellSize;
  final Map<int, List<Body>> _cells = {};

  /// Creates a spatial hash with the given cell size.
  /// Cell size should typically match or slightly exceed the interaction range.
  SpatialHash({required this.cellSize});

  /// Hash function using large primes for good distribution
  int _hash(int cellX, int cellY) {
    return cellX * 73856093 ^ cellY * 19349663;
  }

  /// Clear all cells - call at start of each frame
  void clear() {
    _cells.clear();
  }

  /// Insert a body into the spatial hash
  void insert(Body body) {
    final pos = body.position;
    final cellX = (pos.x / cellSize).floor();
    final cellY = (pos.y / cellSize).floor();
    final hash = _hash(cellX, cellY);
    _cells.putIfAbsent(hash, () => []).add(body);
  }

  /// Get all bodies in the same cell and adjacent cells as the given position.
  /// Checks a 3x3 grid of cells centered on the position's cell.
  Iterable<Body> getNearby(Vector2 pos) sync* {
    final cellX = (pos.x / cellSize).floor();
    final cellY = (pos.y / cellSize).floor();

    // Check 3x3 grid of cells
    for (int dx = -1; dx <= 1; dx++) {
      for (int dy = -1; dy <= 1; dy++) {
        final hash = _hash(cellX + dx, cellY + dy);
        final cell = _cells[hash];
        if (cell != null) {
          yield* cell;
        }
      }
    }
  }
}
