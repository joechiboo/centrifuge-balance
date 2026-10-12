import 'package:shared_preferences/shared_preferences.dart';

/// Which ten-level campaign a record belongs to.
enum Campaign { classic, lab }

/// Everything the game remembers between launches, in one place.
///
/// Cleared levels, per-level best attempt counts, the licence and the
/// nickname printed on it are records; the rest is the session snapshot so
/// the player comes back to exactly where they left off. All writes are
/// fire-and-forget.
class ProgressStore {
  ProgressStore(this._p);
  final SharedPreferences _p;

  static Future<ProgressStore> open() async =>
      ProgressStore(await SharedPreferences.getInstance());

  static const _mode = 'cfg-mode';
  static const _level = 'cfg-level';
  static const _labLevel = 'cfg-lab-level';
  static const _freeN = 'cfg-free-n';
  static const _placed = 'cfg-placed';
  static const _fails = 'cfg-fails';
  static const _nickname = 'cfg-nickname';
  static const _licensedAt = 'cfg-licensed-at';
  static const _labLicensedAt = 'cfg-lab-licensed-at';

  // Classic keys predate the lab campaign and keep their v1.0 names so
  // upgrades carry progress over.
  static String _doneKey(Campaign c) =>
      c == Campaign.classic ? 'cfg-done' : 'cfg-done-lab';
  static String _bestKey(Campaign c, int i) =>
      c == Campaign.classic ? 'cfg-best-$i' : 'cfg-best-lab-$i';

  // Records.

  Set<int> done(Campaign c) => (_p.getStringList(_doneKey(c)) ?? const [])
      .map(int.tryParse)
      .nonNulls
      .toSet();
  void setDone(Campaign c, Set<int> v) =>
      _p.setStringList(_doneKey(c), v.map((i) => '$i').toList());

  /// Fewest launches it took to clear level [i], or null if never cleared.
  int? best(Campaign c, int i) => _p.getInt(_bestKey(c, i));
  void setBest(Campaign c, int i, int attempts) =>
      _p.setInt(_bestKey(c, i), attempts);

  /// ISO date the licence was earned (all classic levels cleared).
  String? get licensedAt => _p.getString(_licensedAt);
  set licensedAt(String? v) =>
      v == null ? _p.remove(_licensedAt) : _p.setString(_licensedAt, v);

  /// ISO date the lab endorsement was earned (all lab levels cleared).
  String? get labLicensedAt => _p.getString(_labLicensedAt);
  set labLicensedAt(String? v) =>
      v == null ? _p.remove(_labLicensedAt) : _p.setString(_labLicensedAt, v);

  /// Name printed on the licence. Stored only on this device.
  String get nickname => _p.getString(_nickname) ?? '';
  set nickname(String v) =>
      v.isEmpty ? _p.remove(_nickname) : _p.setString(_nickname, v);

  // Session snapshot.

  String? get mode => _p.getString(_mode);
  int? get level => _p.getInt(_level);
  int? get labLevel => _p.getInt(_labLevel);
  int? get freeN => _p.getInt(_freeN);
  List<int> get placed => (_p.getStringList(_placed) ?? const [])
      .map(int.tryParse)
      .nonNulls
      .toList();
  int get fails => _p.getInt(_fails) ?? 0;

  void saveSession({
    required String mode,
    required int level,
    required int labLevel,
    required int freeN,
    required Iterable<int> placed,
    required int fails,
  }) {
    _p.setString(_mode, mode);
    _p.setInt(_level, level);
    _p.setInt(_labLevel, labLevel);
    _p.setInt(_freeN, freeN);
    _p.setStringList(_placed, placed.map((i) => '$i').toList());
    _p.setInt(_fails, fails);
  }
}
