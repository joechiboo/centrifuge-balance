import 'package:centrifuge_balance/data/levels.dart';
import 'package:centrifuge_balance/logic/balance.dart';
import 'package:centrifuge_balance/state/game_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('level mode caps tubes at k and launches only when full', () {
    final s = GameState();
    expect(s.n, 6);
    expect(s.k, 2);
    expect(s.canLaunch, isFalse);
    s.toggle(0);
    s.toggle(1);
    expect(s.canLaunch, isTrue);
    s.toggle(2);
    expect(s.placed, {0, 1});
    expect(s.message, GameMessage.tooManyTubes);
  });

  test('unbalanced launch sets an imbalance arrow and counts a failure', () {
    final s = GameState()
      ..toggle(0)
      ..toggle(1);
    expect(s.launch(), isFalse);
    expect(s.run, RunState.unbalanced);
    expect(s.imbalance, isNotNull);
    expect(s.fails, 1);
    expect(s.message, GameMessage.none);
    // Second failure offers the hint unasked.
    s.toggle(1);
    s.toggle(2);
    s.launch();
    expect(s.message, GameMessage.hintAfterFails);
  });

  test('balanced launch spins, then completing marks the level done', () async {
    final s = GameState();
    await s.init();
    s
      ..toggle(0)
      ..toggle(3);
    expect(s.launch(), isTrue);
    expect(s.busy, isTrue);
    expect(s.run, RunState.spinning);
    s.completeSpin();
    expect(s.busy, isFalse);
    expect(s.done, contains(0));
    expect(s.showNext, isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('cfg-done'), ['0']);
  });

  test('session resumes where the player left off', () async {
    final s = GameState();
    await s.init();
    s.setMode(GameMode.free);
    s.changeHoles(3); // 15 holes
    s.toggle(0);
    s.toggle(5);

    final again = GameState();
    await again.init();
    expect(again.mode, GameMode.free);
    expect(again.n, 15);
    expect(again.placed, {0, 5});
  });

  test(
    'resume drops tubes that no longer fit and keeps the attempt count',
    () async {
      SharedPreferences.setMockInitialValues({
        'cfg-mode': 'levels',
        'cfg-level': 3, // 12 holes, k=3, fixed {0}, broken {6}
        'cfg-placed': ['0', '6', '4', '13'],
        'cfg-fails': 2,
      });
      final s = GameState();
      await s.init();
      expect(s.levelIndex, 3);
      expect(s.placed, {4});
      expect(s.fails, 2);
    },
  );

  test('clearing a level records the fewest launches as its best', () async {
    final s = GameState();
    await s.init();
    s
      ..toggle(0)
      ..toggle(1);
    s.launch(); // unbalanced
    s.toggle(1);
    s.toggle(3);
    expect(s.launch(), isTrue);
    s.completeSpin();
    expect(s.attempts, 2);
    expect(s.bestOf(Campaign.classic, 0), 2);

    // Replay and do it in one: best improves.
    s.selectLevel(0);
    s
      ..toggle(0)
      ..toggle(3);
    s.launch();
    s.completeSpin();
    expect(s.bestOf(Campaign.classic, 0), 1);
  });

  test('only cleared levels and the current one can be revisited', () async {
    SharedPreferences.setMockInitialValues({
      'cfg-done': ['0', '1'],
    });
    final s = GameState();
    await s.init();
    expect(s.levelIndex, 2);
    expect(s.canVisit(0), isTrue);
    expect(s.canVisit(2), isTrue);
    expect(s.canVisit(3), isFalse);
    s.selectLevel(5);
    expect(s.levelIndex, 2);
    s.selectLevel(0);
    expect(s.levelIndex, 0);
    // Going back never loses progress; the later cleared level stays open.
    expect(s.canVisit(1), isTrue);
  });

  test('fixed and broken holes cannot be toggled', () {
    final s = GameState()
      ..levelIndex = 3
      ..load();
    expect(s.fixed, {0});
    expect(s.broken, {6});
    s.toggle(0);
    s.toggle(6);
    expect(s.placed, isEmpty);
  });

  test('free mode clamps hole count and allows any non-empty launch', () {
    final s = GameState()..setMode(GameMode.free);
    expect(s.n, 12);
    for (var i = 0; i < 40; i++) {
      s.changeHoles(1);
    }
    expect(s.n, maxHoles);
    for (var i = 0; i < 40; i++) {
      s.changeHoles(-1);
    }
    expect(s.n, minHoles);
    s.toggle(0);
    expect(s.canLaunch, isTrue);
  });

  test('hint escalates from text to drawn guide', () {
    final s = GameState();
    expect(s.guide, isEmpty);
    s.showHint();
    expect(s.hintStage, 1);
    expect(s.message, GameMessage.hintText);
    expect(s.guide, isEmpty);
    s.showHint();
    expect(s.hintStage, 2);
    expect(s.message, GameMessage.hintGuide);
    expect(s.guide, isNotEmpty);
    s.clear();
    expect(s.guide, isEmpty);
  });

  group('lab mode', () {
    test('specimens are fixed and the spare budget is enforced', () {
      final s = GameState()..setMode(GameMode.lab);
      expect(s.n, 6);
      expect(s.fixed, {0});
      expect(s.level.spares, 1);
      expect(s.sparesLeft, 1);
      expect(s.canLaunch, isFalse);
      s.toggle(0); // specimen: ignored
      expect(s.placed, isEmpty);
      s.toggle(2);
      expect(s.sparesLeft, 0);
      expect(s.canLaunch, isTrue);
      s.toggle(4);
      expect(s.placed, {2});
      expect(s.message, GameMessage.noSparesLeft);
    });

    test('lab progress is kept apart from classic progress', () async {
      final s = GameState();
      await s.init();
      s.setMode(GameMode.lab);
      s.toggle(3);
      expect(s.launch(), isTrue);
      s.completeSpin();
      expect(s.labDone, {0});
      expect(s.done, isEmpty);
      expect(s.bestOf(Campaign.lab, 0), 1);
      expect(s.bestOf(Campaign.classic, 0), isNull);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('cfg-done-lab'), ['0']);
      expect(prefs.getStringList('cfg-done'), isNull);

      // The celebration's tap moves on to lab 2; a relaunch lands there.
      expect(s.acknowledge(), isFalse);
      expect(s.labIndex, 1);
      final again = GameState();
      await again.init();
      expect(again.mode, GameMode.lab);
      expect(again.labIndex, 1);
      expect(again.labDone, {0});
    });

    test(
      'every lab level is solved by its guide and needs the full budget',
      () {
        for (var i = 0; i < labLevels.length; i++) {
          final l = labLevels[i];
          final spares = l.guide.expand((g) => g).toSet();
          expect(spares.length, l.spares, reason: 'lab ${i + 1} budget');
          expect(
            spares.any(l.fixed.contains),
            isFalse,
            reason: 'lab ${i + 1} guide on a specimen',
          );
          expect(
            spares.any(l.broken.contains),
            isFalse,
            reason: 'lab ${i + 1} guide on a broken hole',
          );
          expect(
            isBalanced(l.n, [...l.fixed, ...spares]),
            isTrue,
            reason: 'lab ${i + 1} guide balances',
          );
          // The budget is the puzzle: no smaller set of spares balances it.
          final free = [
            for (var h = 0; h < l.n; h++)
              if (!l.fixed.contains(h) && !l.broken.contains(h)) h,
          ];
          for (var m = 0; m < l.spares; m++) {
            for (final combo in _combinations(free, m)) {
              expect(
                isBalanced(l.n, [...l.fixed, ...combo]),
                isFalse,
                reason: 'lab ${i + 1} solvable with $m spares: $combo',
              );
            }
          }
        }
      },
    );
  });

  group('licence', () {
    test('clearing the tenth classic level awards the licence once', () async {
      SharedPreferences.setMockInitialValues({
        'cfg-done': [for (var i = 0; i < 9; i++) '$i'],
      });
      final s = GameState();
      await s.init();
      expect(s.levelIndex, 9);
      expect(s.licensed, isFalse);
      for (final h in levels[9].guide.expand((g) => g)) {
        s.toggle(h);
      }
      expect(s.launch(), isTrue);
      s.completeSpin();
      expect(s.licensed, isTrue);
      expect(s.justLicensed, isTrue);
      expect(s.acknowledge(), isTrue, reason: 'tap opens the licence');
      expect(s.justLicensed, isFalse);
      final issued = s.licensedAt;

      // Replaying does not re-issue.
      s.selectLevel(9);
      for (final h in levels[9].guide.expand((g) => g)) {
        s.toggle(h);
      }
      s.launch();
      s.completeSpin();
      expect(s.justLicensed, isFalse);
      expect(s.licensedAt, issued);
    });

    test('nickname is stored locally', () async {
      final s = GameState();
      await s.init();
      s.setNickname('  小明 ');
      expect(s.nickname, '小明');
      final again = GameState();
      await again.init();
      expect(again.nickname, '小明');
    });
  });
}

Iterable<List<int>> _combinations(List<int> items, int k) sync* {
  if (k == 0) {
    yield const [];
    return;
  }
  for (var i = 0; i <= items.length - k; i++) {
    for (final rest in _combinations(items.sublist(i + 1), k - 1)) {
      yield [items[i], ...rest];
    }
  }
}
