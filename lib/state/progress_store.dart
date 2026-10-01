import 'package:shared_preferences/shared_preferences.dart';

/// Everything the game remembers between launches, in one place.
///
/// Cleared levels and per-level best attempt counts are records; the rest
/// is the session snapshot so the player comes back to exactly where they
/// left off. All writes are fire-and-forget.
class ProgressStore {
  ProgressStore(this._p);
  final SharedPreferences _p;

  static Future<ProgressStore> open() async =>
      ProgressStore(await SharedPreferences.getInstance());

  static const _done = 'cfg-done';
  static const _best = 'cfg-best-';
  static const _mode = 'cfg-mode';
  static const _level = 'cfg-level';
  static const _freeN = 'cfg-free-n';
  static const _placed = 'cfg-placed';
  static const _fails = 'cfg-fails';

  // Records.

  Set<int> get done =>
      (_p.getStringList(_done) ?? const []).map(int.tryParse).nonNulls.toSet();
  set done(Set<int> v) => _p.setStringList(_done, v.map((i) => '$i').toList());

  /// Fewest launches it took to clear level [i], or null if never cleared.
  int? best(int i) => _p.getInt('$_best$i');
  void setBest(int i, int attempts) => _p.setInt('$_best$i', attempts);

  // Session snapshot.

  String? get mode => _p.getString(_mode);
  int? get level => _p.getInt(_level);
  int? get freeN => _p.getInt(_freeN);
  List<int> get placed => (_p.getStringList(_placed) ?? const [])
      .map(int.tryParse)
      .nonNulls
      .toList();
  int get fails => _p.getInt(_fails) ?? 0;

  void saveSession({
    required String mode,
    required int level,
    required int freeN,
    required Iterable<int> placed,
    required int fails,
  }) {
    _p.setString(_mode, mode);
    _p.setInt(_level, level);
    _p.setInt(_freeN, freeN);
    _p.setStringList(_placed, placed.map((i) => '$i').toList());
    _p.setInt(_fails, fails);
  }
}
