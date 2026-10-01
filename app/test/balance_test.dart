import 'package:centrifuge_balance/data/levels.dart';
import 'package:centrifuge_balance/logic/balance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('prime factors', () {
    expect(primeFactors(12), [2, 3]);
    expect(primeFactors(30), [2, 3, 5]);
    expect(primeFactors(7), [7]);
    expect(primeFactors(2), [2]);
  });

  test('balanceable counts follow the prime-sum theorem', () {
    expect(balanceableCounts(12), [2, 3, 4, 5, 6, 7, 8, 9, 10]);
    expect(balanceableCounts(6), [2, 3, 4]);
    expect(balanceableCounts(7), isEmpty);
    expect(balanceableCounts(10), [2, 4, 5, 6, 8]);
  });

  test('vector balance matches the theorem for small rotors', () {
    expect(isBalanced(6, {0, 3}), isTrue);
    expect(isBalanced(6, {0, 2, 4}), isTrue);
    expect(isBalanced(6, {0, 1}), isFalse);
    expect(isBalanced(12, {0, 4, 8, 1, 7}), isTrue);
    expect(isBalanced(12, {0, 1, 2, 3, 4}), isFalse);
  });

  test('every level guide is a valid solution', () {
    for (var i = 0; i < levels.length; i++) {
      final l = levels[i];
      final holes = l.guide.expand((g) => g).toSet();
      expect(holes.length, l.k, reason: 'level ${i + 1} guide size');
      expect(holes.containsAll(l.fixed), isTrue,
          reason: 'level ${i + 1} guide covers fixed tubes');
      expect(holes.any(l.broken.contains), isFalse,
          reason: 'level ${i + 1} guide avoids broken holes');
      expect(isBalanced(l.n, holes), isTrue,
          reason: 'level ${i + 1} guide balances');
      for (final g in l.guide) {
        expect(isBalanced(l.n, g), isTrue,
            reason: 'level ${i + 1} sub-group $g balances on its own');
      }
    }
  });
}
