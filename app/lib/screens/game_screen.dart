import 'package:flutter/material.dart';

import '../data/levels.dart';
import '../state/game_state.dart';
import '../theme/palette.dart';
import '../widgets/rotor.dart';
import 'info_sheet.dart';

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
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: state,
          builder: (context, _) => Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _Header(state: state),
                          const SizedBox(height: 14),
                          if (state.isLevels)
                            _Progress(state: state)
                          else
                            _HoleStepper(state: state),
                          const SizedBox(height: 18),
                          _Task(state: state),
                          const SizedBox(height: 12),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              RotorView(state: state),
                              if (state.showClearCard) _ClearCard(state: state),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _Lcd(state: state),
                          _Message(state: state),
                        ],
                      ),
                    ),
                  ),
                  _ActionBar(state: state),
                ],
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
      children: [
        const Expanded(
          child: Text('離心機配平',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2)),
        ),
        _ModeToggle(state: state),
        const SizedBox(width: 4),
        IconButton(
          tooltip: '玩法與說明',
          icon: Icon(Icons.info_outline, color: p.muted),
          onPressed: () => showInfoSheet(context, state),
        ),
      ],
    );
  }
}

/// Two-pill mode switch; sized by its own text so CJK labels never wrap.
class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.state});
  final GameState state;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    Widget pill(GameMode m, String label) {
      final on = state.mode == m;
      return GestureDetector(
        onTap: () => state.setMode(m),
        child: Semantics(
          button: true,
          selected: on,
          label: label,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: on ? p.ink : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(label,
                softWrap: false,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: on ? p.bg : p.muted)),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        border: Border.all(color: p.line),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [pill(GameMode.levels, '關卡'), pill(GameMode.free, '自由')],
      ),
    );
  }
}

/// Ten milestone segments in one row. Not tappable: progress is earned.
class _Progress extends StatelessWidget {
  const _Progress({required this.state});
  final GameState state;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final cleared = state.done.length;
    return Semantics(
      label: '進度：已過 $cleared 關，共 ${levels.length} 關，目前第 ${state.levelIndex + 1} 關',
      child: Row(
        children: [
          for (var i = 0; i < levels.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: i == state.levelIndex ? 10 : 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: state.done.contains(i)
                      ? p.ok
                      : i == state.levelIndex
                          ? p.cap
                          : p.line,
                ),
              ),
            ),
          ],
          const SizedBox(width: 12),
          Text('$cleared / ${levels.length}',
              style: TextStyle(
                  color: p.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()])),
        ],
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
    Widget btn(IconData icon, int delta, bool enabled, String label) =>
        IconButton.outlined(
          tooltip: label,
          onPressed: enabled ? () => state.changeHoles(delta) : null,
          icon: Icon(icon),
          style: IconButton.styleFrom(
            foregroundColor: p.ink,
            side: BorderSide(color: p.line),
            minimumSize: const Size(44, 44),
          ),
        );
    return Row(
      children: [
        btn(Icons.remove, -1, state.n > minHoles, '減少孔數'),
        SizedBox(
          width: 88,
          child: Text('${state.n} 孔',
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        ),
        btn(Icons.add, 1, state.n < maxHoles, '增加孔數'),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(state.taskTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        if (state.taskSub.isNotEmpty) ...[
          const SizedBox(width: 10),
          Text(state.taskSub, style: TextStyle(fontSize: 14, color: p.muted)),
        ],
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
          color: p.lcd, borderRadius: BorderRadius.circular(10)),
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
    return s.length <= 3
        ? s
        : '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
  }
}

/// Only appears when there is something to say; collapses otherwise.
class _Message extends StatelessWidget {
  const _Message({required this.state});
  final GameState state;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final accent = switch (state.messageKind) {
      MessageKind.ok => p.ok,
      MessageKind.bad => p.bad,
      MessageKind.neutral => p.cap,
    };
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      alignment: Alignment.topCenter,
      child: state.message.isEmpty
          ? const SizedBox(width: double.infinity)
          : Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Semantics(
                liveRegion: true,
                child: Text(state.message,
                    style: TextStyle(fontSize: 15, color: p.ink, height: 1.5)),
              ),
            ),
    );
  }
}

/// Pops in over the rotor after the spin stops: result plus the next step.
class _ClearCard extends StatelessWidget {
  const _ClearCard({required this.state});
  final GameState state;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final last = state.isLastLevel;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutBack,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0, 1),
        child: Transform.scale(scale: 0.85 + 0.15 * t, child: child),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(28, 22, 28, 22),
        decoration: BoxDecoration(
          color: p.panel,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: p.line),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, color: p.ok, size: 44),
            const SizedBox(height: 8),
            Text(last ? '全部過關！' : '配平成功',
                style: TextStyle(
                    fontSize: 19, fontWeight: FontWeight.w700, color: p.ink)),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: p.ok,
                foregroundColor: p.bg,
                minimumSize: const Size(140, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1),
              ),
              onPressed: last
                  ? () => state.setMode(GameMode.free)
                  : state.nextLevel,
              child: Text(last ? '去自由模式' : '下一關'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom bar: two compact tool buttons and one big primary action.
class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.state});
  final GameState state;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final showHint = state.isLevels;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: [
          _Tool(
            icon: Icons.replay_rounded,
            label: '清空',
            enabled: state.canClear,
            onTap: state.clear,
          ),
          if (showHint) ...[
            const SizedBox(width: 10),
            _Tool(
              icon: state.hintStage == 1
                  ? Icons.auto_awesome_rounded
                  : Icons.lightbulb_outline_rounded,
              label: state.hintLabel,
              enabled: state.canHint && state.hintStage < 2,
              onTap: state.showHint,
            ),
          ],
          const SizedBox(width: 10),
          Expanded(
            child: FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 58),
                backgroundColor: p.ink,
                foregroundColor: p.bg,
                disabledBackgroundColor: p.ink.withValues(alpha: 0.25),
                disabledForegroundColor: p.bg,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                textStyle: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 2),
              ),
              onPressed: state.canLaunch ? state.launch : null,
              child: Text(state.launchLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tool extends StatelessWidget {
  const _Tool({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final fg = enabled ? p.ink : p.ink.withValues(alpha: 0.3);
    return Material(
      color: p.panel,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 64,
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.line),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: fg),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}
