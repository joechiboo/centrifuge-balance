import 'package:centrifuge_balance/game/balance.dart';
import 'package:centrifuge_balance/game/levels.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('prime factors are distinct and ascending', () {
    expect(primeFactors(12), [2, 3]);
    expect(primeFactors(30), [2, 3, 5]);
    expect(primeFactors(7), [7]);
  });

  test('balanceable counts follow the prime-sum theorem', () {
    expect(balanceableCounts(12), [2, 3, 4, 5, 6, 7, 8, 9, 10]);
    expect(balanceableCounts(10), [2, 4, 5, 6, 8]);
    expect(balanceableCounts(7), isEmpty);
    expect(balanceableCounts(6), [2, 3, 4]);
  });

  test('isBalanced detects balanced and unbalanced layouts', () {
    expect(isBalanced(12, [0, 4, 8, 1, 7]), isTrue);
    expect(isBalanced(6, [0, 3]), isTrue);
    expect(isBalanced(6, [0, 1]), isFalse);
    expect(isBalanced(12, [0]), isFalse);
  });

  test('every level guide is a valid solution', () {
    for (final level in levels) {
      final tubes = level.guide.expand((g) => g).toList();
      expect(tubes.length, level.tubes);
      expect(tubes.toSet().length, level.tubes);
      expect(tubes.toSet().containsAll(level.fixed), isTrue);
      expect(tubes.any(level.broken.contains), isFalse);
      expect(isBalanced(level.holes, tubes), isTrue);
      for (final group in level.guide) {
        expect(isBalanced(level.holes, group), isTrue);
      }
    }
  });
}
