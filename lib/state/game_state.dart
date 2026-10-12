import 'package:flutter/foundation.dart';

import '../data/levels.dart';
import '../logic/balance.dart';
import 'progress_store.dart';

export 'progress_store.dart' show Campaign;

enum GameMode { levels, lab, free }

enum RunState { idle, spinning, balanced, unbalanced }

/// What the message strip should say. The UI turns these into localized
/// text; the state never holds user-facing strings.
enum GameMessage {
  none,

  /// Classic: the level allows only [GameState.k] tubes.
  tooManyTubes,

  /// Lab: the spare budget is used up.
  noSparesLeft,

  /// First hint stage: the level's text hint.
  hintText,

  /// Second hint stage: the dashed layout is drawn; text repeats the hint.
  hintGuide,

  /// Two failed launches: the hint is offered unasked.
  hintAfterFails,
}

const int minHoles = 2;
const int maxHoles = 30;

/// All game state and rules. The rotor widget drives the spin animation and
/// reports back through [completeSpin]; everything else lives here.
class GameState extends ChangeNotifier {
  GameState() {
    load();
  }

  GameMode mode = GameMode.levels;
  int levelIndex = 0;
  int labIndex = 0;
  int n = 6;
  int k = 2;
  Set<int> fixed = {};
  Set<int> broken = {};
  Set<int> placed = {};
  Set<int> done = {};
  Set<int> labDone = {};
  int fails = 0;
  int hintStage = 0;
  bool busy = false;
  RunState run = RunState.idle;
  Vec2? imbalance;
  GameMessage message = GameMessage.none;
  bool showNext = false;
  String nickname = '';
  String? licensedAt;
  String? labLicensedAt;

  /// Set by [completeSpin] when that clear earned the licence or the lab
  /// endorsement, so the UI can open the certificate. Cleared by [load].
  bool justLicensed = false;

  /// Live rpm readout during a spin. Separate notifier so the hub can
  /// repaint at animation rate without rebuilding the whole screen.
  final ValueNotifier<int> rpm = ValueNotifier<int>(0);

  int _freeN = 12;
  ProgressStore? _store;

  /// Restore records and the last session from disk: cleared levels, best
  /// attempt counts, licence, and exactly where the player was (mode, level,
  /// tubes already placed). With no saved session, start at the first
  /// unfinished classic level.
  Future<void> init() async {
    ProgressStore? store;
    try {
      store = await ProgressStore.open();
    } catch (_) {
      store = null;
    }
    if (store == null) {
      load();
      return;
    }
    done = store.done(Campaign.classic).where((i) => i < levels.length).toSet();
    labDone = store
        .done(Campaign.lab)
        .where((i) => i < labLevels.length)
        .toSet();
    nickname = store.nickname;
    licensedAt = store.licensedAt;
    labLicensedAt = store.labLicensedAt;
    final savedMode = store.mode;
    final savedLevel = store.level;
    final savedLab = store.labLevel;
    final savedFreeN = store.freeN;
    final savedPlaced = store.placed;
    final savedFails = store.fails;

    mode = switch (savedMode) {
      'free' => GameMode.free,
      'lab' => GameMode.lab,
      _ => GameMode.levels,
    };
    _freeN = (savedFreeN ?? 12).clamp(minHoles, maxHoles);
    levelIndex =
        _validIndex(savedLevel, levels.length) ??
        _firstUnfinished(done, levels.length);
    labIndex =
        _validIndex(savedLab, labLevels.length) ??
        _firstUnfinished(labDone, labLevels.length);
    // Only now start writing, so a half-read session never clobbers disk.
    _store = store;
    load();
    // Put the tubes back where they were, dropping anything that no longer
    // fits (a fixed or broken hole, or more tubes than the level allows).
    final valid = savedPlaced
        .where(
          (i) => i >= 0 && i < n && !fixed.contains(i) && !broken.contains(i),
        )
        .toSet();
    if (isFree || fixed.length + valid.length <= k) {
      placed = valid;
      fails = savedFails;
    }
    _saveSession();
    notifyListeners();
  }

  static int? _validIndex(int? i, int length) =>
      i != null && i >= 0 && i < length ? i : null;

  static int _firstUnfinished(Set<int> done, int length) {
    for (var i = 0; i < length; i++) {
      if (!done.contains(i)) return i;
    }
    return 0;
  }

  void _saveSession() {
    _store?.saveSession(
      mode: switch (mode) {
        GameMode.levels => 'levels',
        GameMode.lab => 'lab',
        GameMode.free => 'free',
      },
      level: levelIndex,
      labLevel: labIndex,
      freeN: _freeN,
      placed: placed,
      fails: fails,
    );
  }

  // ---- Campaign helpers -------------------------------------------------

  bool get isLevels => mode == GameMode.levels;
  bool get isLab => mode == GameMode.lab;
  bool get isFree => mode == GameMode.free;

  /// The campaign being played, or null in free mode.
  Campaign? get campaign => switch (mode) {
    GameMode.levels => Campaign.classic,
    GameMode.lab => Campaign.lab,
    GameMode.free => null,
  };

  List<Level> get campaignLevels => isLab ? labLevels : levels;
  Set<int> get campaignDone => isLab ? labDone : done;
  int get index => isLab ? labIndex : levelIndex;
  set index(int i) => isLab ? labIndex = i : levelIndex = i;

  Level get level => campaignLevels[index];
  bool get isLastLevel => index == campaignLevels.length - 1;

  /// Fewest launches it took to clear level [i] of [c]; null if never.
  int? bestOf(Campaign c, int i) => _store?.best(c, i);

  // ---- Derived state ----------------------------------------------------

  int get total => fixed.length + placed.length;
  Iterable<int> get occupied => fixed.followedBy(placed);

  /// Lab: balance tubes still available.
  int get sparesLeft => isLab ? level.spares - placed.length : 0;

  bool get canLaunch =>
      !busy &&
      run != RunState.balanced &&
      switch (mode) {
        GameMode.levels => total == k,
        GameMode.lab => placed.isNotEmpty,
        GameMode.free => total > 0,
      };
  bool get canClear => !busy && (placed.isNotEmpty || hintStage > 0);
  bool get canHint => !busy && !isFree && run != RunState.balanced;

  /// Classic only: tubes still missing before launch is allowed.
  int get missing => isLevels ? k - total : 0;

  /// Celebration over the rotor once the spin has coasted to a stop.
  bool get showCelebration => run == RunState.balanced;

  /// Campaign levels advance by themselves after the celebration; the last
  /// one and free mode wait for a tap.
  bool get autoAdvance => !isFree && !isLastLevel;

  /// Launches so far on this layout, counting the one that just succeeded.
  int get attempts => fails + 1;

  bool get licensed => licensedAt != null;
  bool get labEndorsed => labLicensedAt != null;

  /// Total launches across all best scores, for the licence.
  int get totalBestAttempts {
    var sum = 0;
    for (var i = 0; i < levels.length; i++) {
      sum += bestOf(Campaign.classic, i) ?? 0;
    }
    return sum;
  }

  int get firstTryClears {
    var c = 0;
    for (var i = 0; i < levels.length; i++) {
      if (bestOf(Campaign.classic, i) == 1) c++;
    }
    return c;
  }

  /// Dashed guide shapes to draw, or empty when the player has not asked.
  List<List<int>> get guide =>
      !isFree && hintStage == 2 ? level.guide : const [];

  List<int> balanceable() => balanceableCounts(n);
  List<int> factors() => primeFactors(n);

  // ---- Actions ----------------------------------------------------------

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
    justLicensed = false;
    _resetRun();
    if (isFree) {
      n = _freeN;
      k = n;
      fixed = {};
      broken = {};
    } else {
      final l = level;
      n = l.n;
      k = isLab ? l.fixed.length + l.spares : l.k;
      fixed = l.fixed.toSet();
      broken = l.broken.toSet();
    }
    message = GameMessage.none;
    _saveSession();
    notifyListeners();
  }

  void toggle(int i) {
    if (busy || fixed.contains(i) || broken.contains(i)) return;
    // New set instances so painters comparing by setEquals see the change.
    if (placed.contains(i)) {
      placed = placed.difference({i});
    } else {
      if (!isFree && total >= k) {
        message = isLab ? GameMessage.noSparesLeft : GameMessage.tooManyTubes;
        notifyListeners();
        return;
      }
      placed = {...placed, i};
    }
    _resetRun();
    _saveSession();
    notifyListeners();
  }

  void clear() {
    if (busy) return;
    placed = {};
    hintStage = 0;
    fails = 0;
    _resetRun();
    message = GameMessage.none;
    _saveSession();
    notifyListeners();
  }

  void showHint() {
    if (!canHint) return;
    if (hintStage == 0) {
      hintStage = 1;
      message = GameMessage.hintText;
    } else {
      hintStage = 2;
      message = GameMessage.hintGuide;
    }
    notifyListeners();
  }

  /// Cleared levels and the current one can be revisited; nothing ahead.
  bool canVisit(int i) =>
      !isFree &&
      i >= 0 &&
      i < campaignLevels.length &&
      (i <= index || campaignDone.contains(i));

  void selectLevel(int i) {
    if (busy || !canVisit(i)) return;
    index = i;
    load();
  }

  void nextLevel() {
    if (busy || isFree || isLastLevel) return;
    index = index + 1;
    load();
  }

  void setMode(GameMode m) {
    if (busy || m == mode) return;
    mode = m;
    if (m == GameMode.free) _freeN = 12;
    load();
  }

  /// What a tap on the celebration does. Returns true when the caller
  /// should show the licence instead of staying on the board.
  bool acknowledge() {
    if (!showCelebration) return false;
    if (justLicensed) {
      justLicensed = false;
      _resetRun();
      message = GameMessage.none;
      notifyListeners();
      return true;
    }
    if (isFree || isLastLevel) {
      _resetRun();
      message = GameMessage.none;
      notifyListeners();
    } else {
      nextLevel();
    }
    return false;
  }

  void changeHoles(int delta) {
    if (busy || !isFree) return;
    final next = (_freeN + delta).clamp(minHoles, maxHoles);
    if (next == _freeN) return;
    _freeN = next;
    load();
  }

  void setNickname(String v) {
    nickname = v.trim();
    _store?.nickname = nickname;
    notifyListeners();
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
      message = GameMessage.none;
      notifyListeners();
      return true;
    }
    fails++;
    run = RunState.unbalanced;
    imbalance = v;
    message = !isFree && fails >= 2 && hintStage == 0
        ? GameMessage.hintAfterFails
        : GameMessage.none;
    _saveSession();
    notifyListeners();
    return false;
  }

  void completeSpin() {
    busy = false;
    rpm.value = 0;
    run = RunState.balanced;
    message = GameMessage.none;
    final c = campaign;
    if (c != null) {
      final all = campaignDone..add(index);
      _store?.setDone(c, all);
      final prev = bestOf(c, index);
      if (prev == null || attempts < prev) _store?.setBest(c, index, attempts);
      showNext = !isLastLevel;
      if (all.length == campaignLevels.length) _award(c);
    }
    notifyListeners();
  }

  void _award(Campaign c) {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (c == Campaign.classic && licensedAt == null) {
      licensedAt = today;
      _store?.licensedAt = today;
      justLicensed = true;
    } else if (c == Campaign.lab && labLicensedAt == null) {
      labLicensedAt = today;
      _store?.labLicensedAt = today;
      justLicensed = licensed;
    }
  }

  @override
  void dispose() {
    rpm.dispose();
    super.dispose();
  }
}
