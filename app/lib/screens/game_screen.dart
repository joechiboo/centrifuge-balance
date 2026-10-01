import 'package:flutter/material.dart';

import '../data/levels.dart';
import '../state/game_state.dart';
import '../theme/palette.dart';
import '../widgets/rotor.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameState state = GameState();

  @override
  void initState() {
    super.initState();
    state.init();
  }

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: state,
          builder: (context, _) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(state: state),
                    const SizedBox(height: 16),
                    if (state.isLevels)
                      _LevelPicker(state: state)
                    else
                      _HoleStepper(state: state),
                    const SizedBox(height: 16),
                    _Task(state: state),
                    const SizedBox(height: 16),
                    RotorView(state: state),
                    const SizedBox(height: 16),
                    _Lcd(state: state),
                    const SizedBox(height: 16),
                    _Controls(state: state),
                    const SizedBox(height: 16),
                    _Message(state: state),
                    const SizedBox(height: 16),
                    _Legend(palette: p),
                    const SizedBox(height: 16),
                    _Math(state: state),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.state});
  final GameState state;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('離心機配平',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
        SegmentedButton<GameMode>(
          showSelectedIcon: false,
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            foregroundColor: WidgetStateProperty.resolveWith((s) =>
                s.contains(WidgetState.selected) ? p.bg : p.muted),
            backgroundColor: WidgetStateProperty.resolveWith((s) =>
                s.contains(WidgetState.selected) ? p.ink : Colors.transparent),
            side: WidgetStatePropertyAll(BorderSide(color: p.line)),
          ),
          segments: const [
            ButtonSegment(value: GameMode.levels, label: Text('關卡')),
            ButtonSegment(value: GameMode.free, label: Text('自由')),
          ],
          selected: {state.mode},
          onSelectionChanged: (s) => state.setMode(s.first),
        ),
      ],
    );
  }
}

class _LevelPicker extends StatelessWidget {
  const _LevelPicker({required this.state});
  final GameState state;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (var i = 0; i < levels.length; i++)
          _LevelDot(
            index: i,
            current: i == state.levelIndex,
            done: state.done.contains(i),
            palette: p,
            onTap: () => state.selectLevel(i),
          ),
      ],
    );
  }
}

class _LevelDot extends StatelessWidget {
  const _LevelDot({
    required this.index,
    required this.current,
    required this.done,
    required this.palette,
    required this.onTap,
  });
  final int index;
  final bool current, done;
  final Palette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final border = current ? p.ink : done ? p.ok : p.line;
    final fg = current ? p.bg : done ? p.ok : p.muted;
    return Semantics(
      button: true,
      selected: current,
      label: '第 ${index + 1} 關${done ? '（已過關）' : ''}',
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: current ? p.ink : p.panel,
            border: Border.all(color: border),
          ),
          alignment: Alignment.center,
          child: Text('${index + 1}',
              style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()])),
        ),
      ),
    );
  }
}

class _HoleStepper extends StatelessWidget {
  const _HoleStepper({required this.state});
  final GameState state;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    Widget btn(String label, int delta, bool enabled, String semantics) =>
        Semantics(
          button: true,
          label: semantics,
          child: OutlinedButton(
            onPressed: enabled ? () => state.changeHoles(delta) : null,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(44, 44),
              padding: EdgeInsets.zero,
              foregroundColor: p.ink,
              side: BorderSide(color: p.line),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(label,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700)),
          ),
        );
    return Row(
      children: [
        btn('−', -1, state.n > minHoles, '減少孔數'),
        SizedBox(
          width: 96,
          child: Text('${state.n} 孔',
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
        ),
        btn('＋', 1, state.n < maxHoles, '增加孔數'),
      ],
    );
  }
}

class _Task extends StatelessWidget {
  const _Task({required this.state});
  final GameState state;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(state.taskTitle,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
        Text(state.taskSub, style: TextStyle(fontSize: 14, color: p.muted)),
      ],
    );
  }
}

class _Lcd extends StatelessWidget {
  const _Lcd({required this.state});
  final GameState state;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final bad = state.run == RunState.unbalanced;
    final style = TextStyle(
      color: bad ? p.lcdBad : p.lcdFg,
      fontSize: 15,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.6,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
          color: p.lcd, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(state.countLabel, style: style.copyWith(color: p.lcdFg)),
          ValueListenableBuilder<int>(
            valueListenable: state.rpm,
            builder: (context, rpm, _) => Text(
              state.run == RunState.spinning
                  ? '${_group(rpm)} rpm'
                  : state.stateLabel,
              style: style,
            ),
          ),
        ],
      ),
    );
  }

  static String _group(int v) {
    final s = v.toString();
    return s.length <= 3 ? s : '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.state});
  final GameState state;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final plain = OutlinedButton.styleFrom(
      minimumSize: const Size(0, 50),
      foregroundColor: p.ink,
      backgroundColor: p.panel,
      side: BorderSide(color: p.line),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: plain,
            onPressed: state.canClear ? state.clear : null,
            child: const Text('清空'),
          ),
        ),
        if (state.isLevels) ...[
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              style: plain,
              onPressed: state.canHint ? state.showHint : null,
              child: Text(state.hintLabel),
            ),
          ),
        ],
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 50),
              backgroundColor: p.ink,
              foregroundColor: p.bg,
              disabledBackgroundColor: p.ink.withValues(alpha: 0.45),
              disabledForegroundColor: p.bg,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              textStyle: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 3),
            ),
            onPressed: state.canLaunch ? state.launch : null,
            child: Text(state.launchLabel),
          ),
        ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.state});
  final GameState state;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final accent = switch (state.messageKind) {
      MessageKind.ok => p.ok,
      MessageKind.bad => p.bad,
      MessageKind.neutral => p.line,
    };
    final fg = state.messageKind == MessageKind.neutral ? p.muted : p.ink;
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
          border: Border(left: BorderSide(color: accent, width: 3))),
      child: Semantics(
        liveRegion: true,
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: [
            Text(state.message, style: TextStyle(fontSize: 15, color: fg)),
            if (state.showNext)
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: p.ok,
                  foregroundColor: p.bg,
                  visualDensity: VisualDensity.compact,
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
                onPressed: state.nextLevel,
                child: const Text('下一關'),
              ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.palette});
  final Palette palette;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    Widget item(Color fill, String text, {bool dashed = false}) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: fill,
                border: dashed ? Border.all(color: p.muted) : null,
              ),
            ),
            const SizedBox(width: 5),
            Text(text, style: TextStyle(fontSize: 13, color: p.muted)),
          ],
        );
    return Wrap(
      spacing: 16,
      runSpacing: 6,
      children: [
        item(p.cap, '你放的試管'),
        item(p.fixed, '已固定，不能拿走'),
        item(p.steelLo, '故障孔，不能放', dashed: true),
      ],
    );
  }
}

class _Math extends StatelessWidget {
  const _Math({required this.state});
  final GameState state;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final body = TextStyle(fontSize: 14.5, color: p.muted, height: 1.6);
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 8),
        shape: Border(top: BorderSide(color: p.line)),
        collapsedShape: Border(top: BorderSide(color: p.line)),
        title: const Text('背後的數學',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('把每支試管看成從圓心指向孔位的一個向量。配平的意思是：所有向量相加等於零。',
              style: body),
          const SizedBox(height: 8),
          Text(
              '定理：n 孔的離心機能配平 k 支試管，條件是 k 與 n−k 都能寫成 n 的質因數之和。'
              '12 孔的質因數是 2 與 3，所以 5 = 2 + 3 可以配平，1 與 11 則不行。',
              style: body),
          const SizedBox(height: 8),
          Text(state.mathTable, style: body),
        ],
      ),
    );
  }
}
