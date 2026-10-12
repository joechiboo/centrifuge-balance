/// One puzzle. Two campaigns share this shape:
///
/// * Classic ([levels]): the player places [k] tubes anywhere; [fixed] tubes
///   are already on the rotor and count toward [k].
/// * Lab ([labLevels]): [fixed] are specimen tubes the player must not move;
///   up to [spares] water-filled balance tubes may be added.
///
/// Hints live in the ARB files keyed by campaign and index, not here.
class Level {
  const Level({
    required this.n,
    required this.guide,
    this.k = 0,
    this.spares = 0,
    this.fixed = const [],
    this.broken = const [],
  });

  /// Number of holes on the rotor.
  final int n;

  /// Classic: total tubes that must be on the rotor, fixed ones included.
  final int k;

  /// Lab: maximum balance tubes the player may add.
  final int spares;

  /// Holes that already hold a tube the player cannot remove.
  final List<int> fixed;

  /// Holes that cannot take a tube.
  final List<int> broken;

  /// One known solution, as groups of holes. Classic groups are polygons or
  /// pairs that each balance on their own; lab groups are single holes
  /// where a balance tube goes. Drawn as dashed shapes on request.
  final List<List<int>> guide;

  bool get isLab => spares > 0;
}

const levels = <Level>[
  Level(
    n: 6,
    k: 2,
    guide: [
      [0, 3],
    ],
  ),
  Level(
    n: 6,
    k: 3,
    guide: [
      [0, 2, 4],
    ],
  ),
  Level(
    n: 6,
    k: 4,
    fixed: [0, 1],
    guide: [
      [0, 3],
      [1, 4],
    ],
  ),
  Level(
    n: 12,
    k: 3,
    fixed: [0],
    broken: [6],
    guide: [
      [0, 4, 8],
    ],
  ),
  Level(
    n: 12,
    k: 5,
    guide: [
      [0, 4, 8],
      [1, 7],
    ],
  ),
  Level(
    n: 12,
    k: 7,
    guide: [
      [0, 4, 8],
      [1, 7],
      [3, 9],
    ],
  ),
  Level(
    n: 10,
    k: 5,
    guide: [
      [0, 2, 4, 6, 8],
    ],
  ),
  Level(
    n: 12,
    k: 5,
    fixed: [0, 1],
    guide: [
      [0, 6],
      [1, 5, 9],
    ],
  ),
  Level(
    n: 20,
    k: 7,
    guide: [
      [0, 4, 8, 12, 16],
      [1, 11],
    ],
  ),
  Level(
    n: 30,
    k: 7,
    guide: [
      [0, 6, 12, 18, 24],
      [1, 16],
    ],
  ),
];

/// Lab campaign. Each level's spare budget equals the minimum number of
/// balance tubes that can balance it, and that minimum has exactly one
/// solution (verified by brute force), so the budget is the puzzle.
const labLevels = <Level>[
  Level(
    n: 6,
    fixed: [0],
    spares: 1,
    guide: [
      [3],
    ],
  ),
  Level(
    n: 6,
    fixed: [0, 1],
    spares: 2,
    guide: [
      [3],
      [4],
    ],
  ),
  Level(
    n: 12,
    fixed: [0, 4],
    spares: 1,
    guide: [
      [8],
    ],
  ),
  Level(
    n: 12,
    fixed: [0],
    broken: [6],
    spares: 2,
    guide: [
      [4],
      [8],
    ],
  ),
  Level(
    n: 6,
    fixed: [0, 2, 3],
    spares: 1,
    guide: [
      [5],
    ],
  ),
  Level(
    n: 10,
    fixed: [0, 4],
    broken: [9],
    spares: 3,
    guide: [
      [2],
      [6],
      [8],
    ],
  ),
  Level(
    n: 12,
    fixed: [0, 1, 4],
    broken: [3],
    spares: 2,
    guide: [
      [7],
      [8],
    ],
  ),
  Level(
    n: 12,
    fixed: [0, 1, 2, 5],
    broken: [4, 7, 11],
    spares: 3,
    guide: [
      [6],
      [8],
      [9],
    ],
  ),
  Level(
    n: 15,
    fixed: [0, 3],
    spares: 3,
    guide: [
      [6],
      [9],
      [12],
    ],
  ),
  Level(
    n: 30,
    fixed: [0, 5, 6, 12],
    spares: 3,
    guide: [
      [18],
      [20],
      [24],
    ],
  ),
];
