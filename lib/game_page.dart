import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'game/balance.dart';
import 'game/levels.dart';
import 'palette.dart';
import 'rotor.dart';

enum GameMode { levels, free }

enum MsgKind { info, ok, bad }

const _doneKey = 'done_levels';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4200),
  );
  late final AnimationController _wobble = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  GameMode _mode = GameMode.levels;
  int _li = 0;
  int _holes = 6;
  int _tubes = 2;
  Set<int> _fixed = {};
  Set<int> _broken = {};
  Set<int> _placed = {};
  Set<int> _done = {};
  int _hintStage = 0;
  int _fails = 0;
  bool _busy = false;
  bool _showNext = false;
  bool _lcdBad = false;
  String _state = '待機';
  String _msg = '';
  MsgKind _msgKind = MsgKind.info;
  Offset? _arrow;

  int get _total => _fixed.length + _placed.length;

  @override
  void initState() {
    super.initState();
    _load();
    _restore();
  }

  @override
  void dispose() {
    _spin.dispose();
    _wobble.dispose();
    super.dispose();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_doneKey) ?? const <String>[];
    if (!mounted || saved.isEmpty) return;
    setState(() {
      _done = saved.map(int.tryParse).whereType<int>().toSet();
      if (_mode == GameMode.levels && _placed.isEmpty) {
        final next = List.generate(levels.length, (i) => i)
            .firstWhere((i) => !_done.contains(i), orElse: () => 0);
        _li = next;
        _load();
      }
    });
  }

  Future<void> _saveDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _doneKey,
      _done.map((i) => i.toString()).toList(),
    );
  }

  void _say(String text, [MsgKind kind = MsgKind.info]) {
    _msg = text;
    _msgKind = kind;
    _showNext = false;
  }

  void _resetRun() {
    _state = '待機';
    _lcdBad = false;
    _arrow = null;
  }

  /// Sets up the current level or free-mode rotor. Call inside setState.
  void _load() {
    _placed = {};
    _fails = 0;
    _busy = false;
    _hintStage = 0;
    _resetRun();
    if (_mode == GameMode.levels) {
      final level = levels[_li];
      _holes = level.holes;
      _tubes = level.tubes;
      _fixed = level.fixed.toSet();
      _broken = level.broken.toSet();
      _say('把試管擺到整個轉盤重量平衡，再按啟動。');
    } else {
      _fixed = {};
      _broken = {};
      final counts = balanceableCounts(_holes);
      _say(counts.isEmpty
          ? '$_holes 孔除了全空或全滿，怎麼放都配不平。'
          : '$_holes 孔能配平的支數：${counts.join('、')}。');
    }
  }

  void _toggle(int i) {
    if (_busy || _fixed.contains(i) || _broken.contains(i)) return;
    setState(() {
      if (_placed.contains(i)) {
        _placed.remove(i);
      } else {
        if (_mode == GameMode.levels && _total >= _tubes) {
          _say('這一關只有 $_tubes 支試管，先拿走一支再放。');
          return;
        }
        _placed.add(i);
      }
      _resetRun();
    });
  }

  void _clear() {
    if (_busy) return;
    setState(() {
      _placed = {};
      _hintStage = 0;
      _fails = 0;
      _resetRun();
      _say('已清空。');
    });
  }

  void _hint() {
    if (_busy || _mode != GameMode.levels) return;
    final level = levels[_li];
    setState(() {
      if (_hintStage == 0) {
        _hintStage = 1;
        _say('提示：${level.hint}');
      } else {
        _hintStage = 2;
        _say('虛線是其中一種擺法，照著把試管放在虛線的頂點上。${level.hint}');
      }
    });
  }

  void _launch() {
    if (_busy) return;
    final v = imbalance(_holes, [..._fixed, ..._placed]);
    if (v.magnitude < 1e-9) {
      setState(() {
        _busy = true;
        _arrow = null;
        _lcdBad = false;
        _say('加速中…');
      });
      _spin.forward(from: 0).whenComplete(() {
        if (!mounted) return;
        _spin.value = 0;
        setState(() {
          _busy = false;
          _state = '運轉平穩';
          if (_mode == GameMode.levels) {
            _done.add(_li);
            if (_li < levels.length - 1) {
              _say('配平成功，運轉平穩。', MsgKind.ok);
              _showNext = true;
            } else {
              _say('全部過關。切到自由模式，換個孔數繼續驗證你的直覺。', MsgKind.ok);
            }
          } else {
            _say('配平成功：$_holes 孔放 $_total 支可以平衡。', MsgKind.ok);
          }
        });
        _saveDone();
      });
    } else {
      setState(() {
        _fails++;
        _state = '震動過大，已停機';
        _lcdBad = true;
        _arrow = Offset(v.x, v.y);
        var text = '重心偏向紅色箭頭那一側，調整後再試。';
        if (_mode == GameMode.levels && _fails >= 2) {
          text += ' 提示：${levels[_li].hint}';
        }
        _say(text, MsgKind.bad);
      });
      _wobble.forward(from: 0);
    }
  }

  void _setMode(GameMode mode) {
    if (_busy || mode == _mode) return;
    setState(() {
      _mode = mode;
      if (mode == GameMode.free) _holes = 12;
      _load();
    });
  }

  void _goLevel(int i) {
    if (_busy) return;
    setState(() {
      _li = i;
      _load();
    });
  }

  void _stepHoles(int delta) {
    if (_busy) return;
    final next = _holes + delta;
    if (next < 2 || next > 30) return;
    setState(() {
      _holes = next;
      _load();
    });
  }

  String _rpm(double speed) {
    final v = (speed * 400).round() * 10;
    final text = v >= 1000
        ? '${v ~/ 1000},${(v % 1000).toString().padLeft(3, '0')}'
        : '$v';
    return '$text rpm';
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final inLevels = _mode == GameMode.levels;
    final level = inLevels ? levels[_li] : null;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _header(p),
                  const SizedBox(height: 16),
                  if (inLevels) _levelChips(p) else _stepper(p),
                  const SizedBox(height: 16),
                  _task(p),
                  const SizedBox(height: 16),
                  AspectRatio(
                    aspectRatio: 1,
                    child: AnimatedBuilder(
                      animation: _wobble,
                      builder: (context, child) {
                        final t = _wobble.value;
                        final k = math.sin(t * math.pi * 6) * (1 - t);
                        return Transform.translate(
                          offset: Offset(7 * k, -3 * k),
                          child: Transform.rotate(angle: 0.05 * k, child: child),
                        );
                      },
                      child: Rotor(
                        holes: _holes,
                        fixed: _fixed,
                        broken: _broken,
                        placed: _placed,
                        guide: (level != null && _hintStage == 2)
                            ? level.guide
                            : const [],
                        arrow: _arrow,
                        spin: _spin,
                        onTapHole: _toggle,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _lcd(p),
                  const SizedBox(height: 16),
                  _controls(p),
                  const SizedBox(height: 16),
                  _message(p),
                  const SizedBox(height: 16),
                  _legend(p),
                  const SizedBox(height: 8),
                  _maths(p),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(Palette p) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '離心機配平',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: p.ink,
            ),
          ),
        ),
        SegmentedButton<GameMode>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: GameMode.levels, label: Text('關卡')),
            ButtonSegment(value: GameMode.free, label: Text('自由')),
          ],
          selected: {_mode},
          onSelectionChanged: (s) => _setMode(s.first),
        ),
      ],
    );
  }

  Widget _levelChips(Palette p) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (var i = 0; i < levels.length; i++)
          Semantics(
            button: true,
            label: '第 ${i + 1} 關${_done.contains(i) ? '（已過關）' : ''}',
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => _goLevel(i),
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == _li ? p.ink : p.panel,
                  border: Border.all(
                    color: i == _li
                        ? p.ink
                        : _done.contains(i)
                            ? p.ok
                            : p.line,
                  ),
                ),
                child: ExcludeSemantics(
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: i == _li
                          ? p.bg
                          : _done.contains(i)
                              ? p.ok
                              : p.muted,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _stepper(Palette p) {
    return Row(
      children: [
        IconButton.outlined(
          onPressed: () => _stepHoles(-1),
          icon: const Icon(Icons.remove),
          tooltip: '減少孔數',
        ),
        SizedBox(
          width: 96,
          child: Text(
            '$_holes 孔',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: p.ink,
            ),
          ),
        ),
        IconButton.outlined(
          onPressed: () => _stepHoles(1),
          icon: const Icon(Icons.add),
          tooltip: '增加孔數',
        ),
      ],
    );
  }

  Widget _task(Palette p) {
    final String title;
    final String sub;
    if (_mode == GameMode.levels) {
      title = '第 ${_li + 1} 關：$_holes 孔轉盤，放滿 $_tubes 支試管後啟動';
      final extra = <String>[
        if (_fixed.isNotEmpty) '其中 ${_fixed.length} 支已固定',
        if (_broken.isNotEmpty) '${_broken.length} 個孔故障',
      ];
      sub = '${extra.isEmpty ? '' : '${extra.join('，')}。'}點孔位放入或取出試管。';
    } else {
      title = '自由模式：$_holes 孔轉盤';
      sub = '隨意擺放後啟動，驗證你的猜想。';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: p.ink,
          ),
        ),
        const SizedBox(height: 2),
        Text(sub, style: TextStyle(fontSize: 14, color: p.muted)),
      ],
    );
  }

  Widget _lcd(Palette p) {
    final count = _mode == GameMode.levels
        ? '試管 $_total / $_tubes'
        : '試管 $_total / $_holes 孔';
    const style = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.6,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: p.lcd,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(count, style: style.copyWith(color: p.lcdFg)),
          AnimatedBuilder(
            animation: _spin,
            builder: (context, _) => Text(
              _spin.isAnimating ? _rpm(spinSpeed(_spin.value)) : _state,
              style: style.copyWith(
                color: _lcdBad ? const Color(0xFFFF8F85) : p.lcdFg,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _controls(Palette p) {
    final inLevels = _mode == GameMode.levels;
    final ready = inLevels ? _total == _tubes : _total > 0;
    final goLabel =
        inLevels && _total != _tubes ? '還差 ${_tubes - _total} 支' : '啟動';
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    );
    final canClear = !_busy && (_placed.isNotEmpty || _hintStage > 0);
    return SizedBox(
      height: 50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(shape: shape),
              onPressed: canClear ? _clear : null,
              child: const Text('清空'),
            ),
          ),
          const SizedBox(width: 10),
          if (inLevels) ...[
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(shape: shape),
                onPressed: _busy ? null : _hint,
                child: Text(_hintStage == 0 ? '提示' : '看擺法'),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            flex: 2,
            child: FilledButton(
              style: FilledButton.styleFrom(
                shape: shape,
                backgroundColor: p.ink,
                foregroundColor: p.bg,
              ),
              onPressed: ready && !_busy ? _launch : null,
              child: Text(goLabel),
            ),
          ),
        ],
      ),
    );
  }

  Widget _message(Palette p) {
    final accent = switch (_msgKind) {
      MsgKind.ok => p.ok,
      MsgKind.bad => p.bad,
      MsgKind.info => p.line,
    };
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: accent, width: 3)),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 6,
        children: [
          Text(
            _msg,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: _msgKind == MsgKind.info ? p.muted : p.ink,
            ),
          ),
          if (_showNext)
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: p.ok,
                foregroundColor: p.bg,
                visualDensity: VisualDensity.compact,
              ),
              onPressed: () => _goLevel(_li + 1),
              child: const Text('下一關'),
            ),
        ],
      ),
    );
  }

  Widget _legend(Palette p) {
    Widget item(Color color, String label) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 13, color: p.muted)),
        ],
      );
    }

    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        item(p.cap, '你放的試管'),
        item(p.fixed, '已固定，不能拿走'),
        item(p.steelLo, '故障孔，不能放'),
      ],
    );
  }

  Widget _maths(Palette p) {
    final counts = balanceableCounts(_holes);
    final body = TextStyle(fontSize: 14.5, height: 1.6, color: p.muted);
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 12),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      title: Text(
        '背後的數學',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: p.ink,
        ),
      ),
      children: [
        Text('把每支試管看成從圓心指向孔位的一個向量。配平的意思是：所有向量相加等於零。', style: body),
        const SizedBox(height: 8),
        Text(
          '定理：n 孔的離心機能配平 k 支試管，條件是 k 與 n−k 都能寫成 n 的質因數之和。'
          '12 孔的質因數是 2 與 3，所以 5 = 2 + 3 可以配平，1 與 11 則不行。',
          style: body,
        ),
        const SizedBox(height: 8),
        Text(
          '目前 $_holes 孔（質因數 ${primeFactors(_holes).join('、')}）能配平的支數：'
          '${counts.isEmpty ? '無，只有放滿' : '${counts.join('、')}，以及放滿'}。',
          style: body,
        ),
      ],
    );
  }
}
