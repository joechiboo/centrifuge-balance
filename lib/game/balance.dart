import 'dart:math' as math;

/// Distinct prime factors of [n], ascending.
List<int> primeFactors(int n) {
  final result = <int>[];
  var m = n;
  for (var d = 2; d * d <= m; d++) {
    if (m % d == 0) {
      result.add(d);
      while (m % d == 0) {
        m ~/= d;
      }
    }
  }
  if (m > 1) result.add(m);
  return result;
}

/// Whether [m] can be written as a sum of numbers taken from [parts]
/// (each usable any number of times).
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

/// Tube counts k (0 < k < n) that can be balanced in an n-hole rotor:
/// both k and n-k must be sums of prime factors of n.
List<int> balanceableCounts(int holes) {
  final primes = primeFactors(holes);
  return [
    for (var k = 1; k < holes; k++)
      if (isSumOf(k, primes) && isSumOf(holes - k, primes)) k,
  ];
}

/// Sum of unit vectors pointing at each occupied hole. Hole 0 is at the top,
/// indices run clockwise, y grows downward (screen coordinates).
math.Point<double> imbalance(int holes, Iterable<int> occupied) {
  var x = 0.0;
  var y = 0.0;
  for (final i in occupied) {
    final a = 2 * math.pi * i / holes;
    x += math.sin(a);
    y -= math.cos(a);
  }
  return math.Point<double>(x, y);
}

bool isBalanced(int holes, Iterable<int> occupied) =>
    imbalance(holes, occupied).magnitude < 1e-9;
