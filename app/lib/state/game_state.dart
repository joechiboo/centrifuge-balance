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

  bool get canLaunch => !busy && (isLevels ? total == k : total > 0);
  bool get canClear => !busy && (placed.isNotEmpty || hintStage > 0);
  bool get canHint => !busy && isLevels;

  String get launchLabel =>
      isLevels && total < k ? '還差 ${k - total} 支' : '啟動';
  String get hintLabel => hintStage == 1 ? '看擺法' : '提示';
  String get countLabel => isLevels ? '試管 $total / $k' : '試管 $total / $n 孔';

  String get stateLabel => switch (run) {
        RunState.idle => '待機',
        RunState.spinning => '加速中',
        RunState.balanced => '運轉平穩',
        RunState.unbalanced => '震動過大，已停機',
      };

  String get taskTitle => isLevels
      ? '第 ${levelIndex + 1} 關：$n 孔轉盤，放滿 $k 支試管後啟動'
      : '自由模式：$n 孔轉盤';

  String get taskSub {
    if (!isLevels) return '隨意擺放後啟動，驗證你的猜想。';
    final extra = <String>[
      if (fixed.isNotEmpty) '其中 ${fixed.length} 支已固定',
      if (broken.isNotEmpty) '${broken.length} 個孔故障',
    ];
    return '${extra.isEmpty ? '' : '${extra.join('，')}。'}點孔位放入或取出試管。';
  }

  String get mathTable {
    final b = balanceableCounts(n);
    final ps = primeFactors(n).join('、');
    return '目前 $n 孔（質因數 $ps）能配平的支數：'
        '${b.isEmpty ? '無，只有放滿' : '${b.join('、')}，以及放滿'}。';
  }

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
      _flash('把試管擺到整個轉盤重量平衡，再按啟動。');
    } else {
      n = _freeN;
      k = n;
      fixed = {};
      broken = {};
      final b = balanceableCounts(n);
      _flash(b.isEmpty
          ? '$n 孔除了全空或全滿，怎麼放都配不平。'
          : '$n 孔能配平的支數：${b.join('、')}。');
    }
    notifyListeners();
  }

  void toggle(int i) {
    if (busy || fixed.contains(i) || broken.contains(i)) return;
    // New set instances so painters comparing by setEquals see the change.
    if (placed.contains(i)) {
      placed = placed.difference({i});
    } else {
      if (isLevels && total >= k) {
        _flash('這一關只有 $k 支試管，先拿走一支再放。');
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
    _flash('已清空。');
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
      _flash('加速中…');
      notifyListeners();
      return true;
    }
    fails++;
    run = RunState.unbalanced;
    imbalance = v;
    var t = '重心偏向紅色箭頭那一側，調整後再試。';
    if (isLevels && fails >= 2) t += ' 提示：${level.hint}';
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
      if (isLastLevel) {
        _flash('全部過關。切到自由模式，換個孔數繼續驗證你的直覺。', MessageKind.ok);
      } else {
        _flash('配平成功，運轉平穩。', MessageKind.ok);
        showNext = true;
      }
    } else {
      _flash('配平成功：$n 孔放 $total 支可以平衡。', MessageKind.ok);
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
