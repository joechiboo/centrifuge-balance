class Level {
  const Level({
    required this.n,
    required this.k,
    required this.hint,
    required this.guide,
    this.fixed = const [],
    this.broken = const [],
  });

  /// Number of holes on the rotor.
  final int n;

  /// Total tubes that must be on the rotor (fixed ones included).
  final int k;

  /// Holes that already hold a tube the player cannot remove.
  final List<int> fixed;

  /// Holes that cannot take a tube.
  final List<int> broken;

  /// Text hint shown on request or after repeated failures.
  final String hint;

  /// One known solution, as groups of holes that each balance on their own.
  /// Drawn as dashed shapes when the player asks to see the layout.
  final List<List<int>> guide;
}

const levels = <Level>[
  Level(n: 6, k: 2, hint: '兩支試管面對面放，重量就互相抵銷。', guide: [
    [0, 3]
  ]),
  Level(n: 6, k: 3, hint: '三支試管隔一個孔放一支，排成正三角形。', guide: [
    [0, 2, 4]
  ]),
  Level(
      n: 6,
      k: 4,
      fixed: [0, 1],
      hint: '每一支固定的試管，都替它在正對面找個伴。',
      guide: [
        [0, 3],
        [1, 4]
      ]),
  Level(
      n: 12,
      k: 3,
      fixed: [0],
      broken: [6],
      hint: '對面的孔壞了，不能對放。試試以它為頂點排正三角形（每隔 4 孔）。',
      guide: [
        [0, 4, 8]
      ]),
  Level(
      n: 12,
      k: 5,
      hint: '把 5 支拆成 3 + 2。先每隔 4 孔放一支，排成正三角形；剩下 2 支找兩個面對面的空孔對放。兩組各自平衡，合起來也平衡。',
      guide: [
        [0, 4, 8],
        [1, 7]
      ]),
  Level(
      n: 12,
      k: 7,
      hint: '看空孔。7 支放好後剩 5 個空孔，空孔平衡，試管也就平衡。',
      guide: [
        [0, 4, 8],
        [1, 7],
        [3, 9]
      ]),
  Level(n: 10, k: 5, hint: '5 是奇數，湊不成對放。10 孔每隔一孔放一支，是正五邊形。', guide: [
    [0, 2, 4, 6, 8]
  ]),
  Level(
      n: 12,
      k: 5,
      fixed: [0, 1],
      hint: '一支固定管配對面，另一支當三角形的頂點。',
      guide: [
        [0, 6],
        [1, 5, 9]
      ]),
  Level(
      n: 20,
      k: 7,
      hint: '7 = 5 + 2。每隔 4 孔排正五邊形，再找一組不相撞的對放。',
      guide: [
        [0, 4, 8, 12, 16],
        [1, 11]
      ]),
  Level(
      n: 30,
      k: 7,
      hint: '30 孔的質因數有 2、3、5。7 = 5 + 2，五邊形每隔 6 孔一支。',
      guide: [
        [0, 6, 12, 18, 24],
        [1, 16]
      ]),
];
