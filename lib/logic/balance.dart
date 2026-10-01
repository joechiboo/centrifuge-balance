import 'dart:math' as math;

/// Pure math behind the puzzle. No Flutter imports so it is trivially testable.

/// Distinct prime factors of [m] in ascending order.
List<int> primeFactors(int m) {
  final out = <int>[];
  var rest = m;
  for (var d = 2; d * d <= rest; d++) {
    if (rest % d == 0) {
      out.add(d);
      while (rest % d == 0) {
        rest ~/= d;
      }
    }
  }
  if (rest > 1) out.add(rest);
  return out;
}

/// Whether [m] can be written as a sum of numbers taken from [parts]
/// (with repetition). Zero counts as the empty sum.
bool isSumOf(int m, List<int> parts) {
  final ok = List<bool>.filled(m + 1, false);
  ok[0] = true;
  for (var i = 1; i <= m; i++) {
    for (final p in parts) {
      if (i >= p && ok[i - p]) {
        ok[i] = true;
        break;
      }
    }
  }
  return ok[m];
}

/// Tube counts strictly between 0 and [n] that can be balanced on an
/// [n]-hole rotor. Theorem: k works iff both k and n-k are sums of n's
/// prime factors.
List<int> balanceableCounts(int n) {
  final ps = primeFactors(n);
  return [
    for (var c = 1; c < n; c++)
      if (isSumOf(c, ps) && isSumOf(n - c, ps)) c,
  ];
}

class Vec2 {
  const Vec2(this.x, this.y);
  final double x;
  final double y;
  double get magnitude => math.sqrt(x * x + y * y);
  Vec2 get unit {
    final m = magnitude;
    return m == 0 ? const Vec2(0, 0) : Vec2(x / m, y / m);
  }
}

/// Angle of hole [i] on an [n]-hole rotor, measured clockwise from 12 o'clock.
double holeAngle(int n, int i) => 2 * math.pi * i / n;

/// Sum of unit vectors pointing from the centre to each occupied hole.
/// Screen coordinates: +x right, +y down, hole 0 at the top.
Vec2 vectorSum(int n, Iterable<int> holes) {
  var x = 0.0, y = 0.0;
  for (final i in holes) {
    final a = holeAngle(n, i);
    x += math.sin(a);
    y -= math.cos(a);
  }
  return Vec2(x, y);
}

const double _epsilon = 1e-6;

bool isBalanced(int n, Iterable<int> holes) =>
    vectorSum(n, holes).magnitude < _epsilon;
