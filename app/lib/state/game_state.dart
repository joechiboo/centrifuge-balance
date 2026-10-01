import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/levels.dart';
import '../logic/balance.dart';

enum GameMode { levels, free }

enum RunState { idle, spinning, balanced, unbalanced }

enum MessageKind { neutral, ok, bad }

const int minHoles = 2;
const int maxHoles = 30;
const String _doneKey = 'cfg-done';

/// All game state and rules. The rotor widget drives the spin animation and
/// reports back through [completeSpin]; everything else lives here.
class GameState extends ChangeNotifier {
  GameState() {
    load();
  }

  GameMode mode = GameMode.levels;
  int levelIndex = 0;
  int n = 6;
  int k = 2;
  Set<int> fixed = {};
  Set<int> broken = {};
  Set<int> placed = {};
  Set<int> done = {};
  int fails = 0;
  int hintStage = 0;
  bool busy = false;
  RunState run = RunState.idle;
  Vec2? imbalance;
  String message = '';
  MessageKind messageKind = MessageKind.neutral;
  bool showNext = false;

  /// Live rpm readout during a spin. Separate notifier so the LCD can
  /// repaint at animation rate without rebuilding the whole screen.
  final ValueNotifier<int> rpm = ValueNotifier<int>(0);

  int _freeN = 12;
  SharedPreferences? _prefs;

  /// Restore cleared levels from disk and jump to the first unfinished one.
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final saved = _prefs!.getStringList(_doneKey) ?? const [];
      done = saved.map(int.parse).where((i) => i < levels.length).toSet();
    } catch (_) {
      done = {};
    }
    if (mode == GameMode.levels) {
      levelIndex = _firstUnfinished();
      load();
    } else {
      notifyListeners();
    }
  }

  int _firstUnfinished() {
    for (var i = 0; i < levels.length; i++) {
      if (!done.contains(i)) return i;
    }
    return 0;
  }

  void _save() {
    _prefs?.setStringList(_doneKey, done.map((i) => '$i').toList());
  }

  Level get level => levels[levelIndex];
  int get total => fixed.length + placed.length;
  bool get isLevels => mode == GameMode.levels;
  bool get isLastLevel => levelIndex == levels.length - 1;
  Iterable<int> get occupied => fixed.followedBy(placed);

  bool get canLaunch =>
      !busy &&
      run != RunState.balanced &&
      (isLevels ? total == k : total > 0);
  bool get canClear => !busy && (placed.isNotEmpty || hintStage > 0);
  bool get canHint => !busy && isLevels && run != RunState.balanced;

  String get launchLabel =>
      isLevels && total < k ? '還差 ${k - total} 支' : '啟動';

  /// Celebration over the rotor once the spin has coasted to a stop.
  bool get showCelebration => run == RunState.balanced;

  /// Levels advance by themselves after the celebration; free mode waits.
  bool get autoAdvance => isLevels && !isLastLevel;

  /// Text drawn in the rotor hub while idle: tubes placed over the goal.
  String get hubLabel => isLevels ? '$total/$k' : '$total';

  /// What a tap on the celebration does.
  void acknowledge() {
    if (!showCelebration) return;
    if (isLevels) {
      isLastLevel ? setMode(GameMode.free) : nextLevel();
    } else {
      _resetRun();
      _flash('');
      notifyListeners();
    }
  }
  String get hintLabel => hintStage == 1 ? '看擺法' : '提示';
  String get countLabel => isLevels ? '試管 $total / $k' : '試管 $total / $n 孔';

  String get stateLabel => switch (run) {
        RunState.idle => '待機',
        RunState.spinning => '加速中',
        RunState.balanced => '運轉平穩',
        RunState.unbalanced => '震動過大，已停機',
      };

  String get taskTitle =>
      isLevels ? '第 ${levelIndex + 1} 關 · 放 $k 支' : '自由模式 · $n 孔';

  /// Only the constraints worth a glance; empty when there are none.
  String get taskSub {
    if (!isLevels) return '';
    return [
      if (fixed.isNotEmpty) '${fixed.length} 支已固定',
      if (broken.isNotEmpty) '${broken.length} 孔故障',
    ].join('，');
  }

  /// Counts that balance on the current rotor, for the info sheet.
  String get balanceableText {
    final b = balanceableCounts(n);
    return b.isEmpty ? '只有放滿' : '${b.join('、')}，以及放滿';
  }

  String get primeFactorText => primeFactors(n).join('、');

  /// Dashed guide shapes to draw, or empty when the player has not asked.
  List<List<int>> get guide =>
      isLevels && hintStage == 2 ? level.guide : const [];

  void _flash(String text, [MessageKind kind = MessageKind.neutral]) {
    message = text;
    messageKind = kind;
    showNext = false;
  }

  void _resetRun() {
    run = RunState.idle;
    imbalance = null;
    rpm.value = 0;
    showNext = false;
  }

  void load() {
    placed = {};
    fails = 0;
    busy = false;
    hintStage = 0;
    _resetRun();
    if (isLevels) {
      final l = level;
      n = l.n;
      k = l.k;
      fixed = l.fixed.toSet();
      broken = l.broken.toSet();
    } else {
      n = _freeN;
      k = n;
      fixed = {};
      broken = {};
    }
    _flash('');
    notifyListeners();
  }

  void toggle(int i) {
    if (busy || fixed.contains(i) || broken.contains(i)) return;
    // New set instances so painters comparing by setEquals see the change.
    if (placed.contains(i)) {
      placed = placed.difference({i});
    } else {
      if (isLevels && total >= k) {
        _flash('只有 $k 支試管，先拿走一支。');
        notifyListeners();
        return;
      }
      placed = {...placed, i};
    }
    _resetRun();
    notifyListeners();
  }

  void clear() {
    if (busy) return;
    placed = {};
    hintStage = 0;
    fails = 0;
    _resetRun();
    _flash('');
    notifyListeners();
  }

  void showHint() {
    if (!canHint) return;
    if (hintStage == 0) {
      hintStage = 1;
      _flash('提示：${level.hint}');
    } else {
      hintStage = 2;
      _flash('虛線是其中一種擺法，照著把試管放在虛線的頂點上。${level.hint}');
    }
    notifyListeners();
  }

  void selectLevel(int i) {
    if (busy) return;
    mode = GameMode.levels;
    levelIndex = i;
    load();
  }

  void nextLevel() {
    if (busy || isLastLevel) return;
    levelIndex++;
    load();
  }

  void setMode(GameMode m) {
    if (busy || m == mode) return;
    mode = m;
    if (m == GameMode.free) _freeN = 12;
    load();
  }

  void changeHoles(int delta) {
    if (busy || !mode.isFree) return;
    final next = (_freeN + delta).clamp(minHoles, maxHoles);
    if (next == _freeN) return;
    _freeN = next;
    load();
  }

  /// Returns true when the rotor should spin up. The rotor widget then
  /// animates and calls [completeSpin] when it has coasted to a stop.
  bool launch() {
    if (!canLaunch) return false;
    final v = vectorSum(n, occupied);
    if (v.magnitude < 1e-6) {
      busy = true;
      imbalance = null;
      run = RunState.spinning;
      _flash('');
      notifyListeners();
      return true;
    }
    fails++;
    run = RunState.unbalanced;
    imbalance = v;
    var t = '重心偏向箭頭那一側。';
    if (isLevels && fails >= 2) t += '\n提示：${level.hint}';
    _flash(t, MessageKind.bad);
    notifyListeners();
    return false;
  }

  void completeSpin() {
    busy = false;
    rpm.value = 0;
    run = RunState.balanced;
    if (isLevels) {
      done.add(levelIndex);
      _save();
      _flash('');
      showNext = !isLastLevel;
    } else {
      _flash('');
    }
    notifyListeners();
  }

  @override
  void dispose() {
    rpm.dispose();
    super.dispose();
  }
}

extension on GameMode {
  bool get isFree => this == GameMode.free;
}
