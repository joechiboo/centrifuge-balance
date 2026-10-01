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
    expect(s.message, contains('只有 2 支'));
  });

  test('unbalanced launch sets an imbalance arrow and counts a failure', () {
    final s = GameState()
      ..toggle(0)
      ..toggle(1);
    expect(s.launch(), isFalse);
    expect(s.run, RunState.unbalanced);
    expect(s.imbalance, isNotNull);
    expect(s.fails, 1);
    expect(s.messageKind, MessageKind.bad);
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
    expect(s.bestOf(0), 2);

    // Replay and do it in one: best improves.
    s.selectLevel(0);
    s
      ..toggle(0)
      ..toggle(3);
    s.launch();
    s.completeSpin();
    expect(s.bestOf(0), 1);
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

  test('init resumes at the first unfinished level', () async {
    SharedPreferences.setMockInitialValues({
      'cfg-done': ['0', '1'],
    });
    final s = GameState();
    await s.init();
    expect(s.levelIndex, 2);
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
    expect(s.guide, isEmpty);
    s.showHint();
    expect(s.hintStage, 2);
    expect(s.guide, isNotEmpty);
    s.clear();
    expect(s.guide, isEmpty);
  });
}
