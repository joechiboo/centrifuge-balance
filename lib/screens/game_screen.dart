import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
                    child: LayoutBuilder(
                      builder: (context, c) {
                        // Header, progress and task take about 170 px; keep the
                        // rotor inside whatever height is left so short or wide
                        // screens still show the whole board.
                        final rotorMax = (c.maxHeight - 170).clamp(
                          200.0,
                          520.0,
                        );
                        return SingleChildScrollView(
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
                              Center(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: rotorMax,
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      RotorView(state: state),
                                      if (state.showCelebration)
                                        Positioned.fill(
                                          child: _Celebration(state: state),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              _Message(state: state),
                            ],
                          ),
                        );
                      },
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
          child: Text(
            '離心機配平',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
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
            child: Text(
              label,
              softWrap: false,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: on ? p.bg : p.muted,
              ),
            ),
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

/// Ten milestone segments in one row. Cleared ones can be tapped to go back
/// and replay; the ones ahead are earned, not picked.
class _Progress extends StatelessWidget {
  const _Progress({required this.state});
  final GameState state;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final cleared = state.done.length;
    return Row(
      children: [
        for (var i = 0; i < levels.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            child: _Segment(index: i, state: state, palette: p),
          ),
        ],
        const SizedBox(width: 12),
        Text(
          '$cleared / ${levels.length}',
          style: TextStyle(
            color: p.muted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.index,
    required this.state,
    required this.palette,
  });
  final int index;
  final GameState state;
  final Palette palette;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final current = index == state.levelIndex;
    final done = state.done.contains(index);
    final tappable = !current && state.canVisit(index) && !state.busy;
    final bar = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: current ? 10 : 6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: done
            ? p.ok
            : current
            ? p.cap
            : p.line,
      ),
    );
    return Semantics(
      button: tappable,
      selected: current,
      label: '第 ${index + 1} 關${done ? '，已過關' : ''}${current ? '，目前' : ''}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: tappable
            ? () {
                HapticFeedback.selectionClick();
                state.selectLevel(index);
              }
            : null,
        // Generous hit area around a thin bar.
        child: SizedBox(height: 28, child: Center(child: bar)),
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
          child: Text(
            '${state.n} 孔',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
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
        Text(
          state.taskTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        if (state.taskSub.isNotEmpty) ...[
          const SizedBox(width: 10),
          Text(state.taskSub, style: TextStyle(fontSize: 14, color: p.muted)),
        ],
      ],
    );
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
                child: Text(
                  state.message,
                  style: TextStyle(fontSize: 15, color: p.ink, height: 1.5),
                ),
              ),
            ),
    );
  }
}

/// Game-style clear: a check bursts out of the hub, the level advances on
/// its own a moment later, or at once on a tap. Free mode waits for the tap.
class _Celebration extends StatefulWidget {
  const _Celebration({required this.state});
  final GameState state;

  @override
  State<_Celebration> createState() => _CelebrationState();
}

class _CelebrationState extends State<_Celebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();
  Timer? _auto;

  @override
  void initState() {
    super.initState();
    if (widget.state.autoAdvance) {
      _auto = Timer(const Duration(milliseconds: 1900), _go);
    }
  }

  void _go() {
    _auto?.cancel();
    _auto = null;
    widget.state.acknowledge();
  }

  @override
  void dispose() {
    _auto?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final s = widget.state;
    final last = s.isLevels && s.isLastLevel;
    final title = last ? '全部過關！' : '配平成功';
    final sub = s.isLevels
        ? (last ? '點一下進入自由模式' : '點一下繼續')
        : '${s.n} 孔放 ${s.total} 支 · 點一下繼續';
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _go,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _c.value;
          final pop = Curves.easeOutBack.transform(math.min(1, t / 0.45));
          final fade = Curves.easeOut.transform(math.min(1, t / 0.3));
          final burst = Curves.easeOutCubic.transform(t);
          return Stack(
            alignment: Alignment.center,
            children: [
              // Dim the rotor slightly so the result reads first.
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: p.bg.withValues(alpha: 0.45 * fade),
                ),
              ),
              // Particle burst.
              for (var i = 0; i < 12; i++)
                Transform.translate(
                  offset: Offset.fromDirection(
                    i * math.pi / 6 + 0.3,
                    40 + 110 * burst,
                  ),
                  child: Opacity(
                    opacity: (1 - burst).clamp(0, 1),
                    child: Container(
                      width: i.isEven ? 10 : 6,
                      height: i.isEven ? 10 : 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i % 3 == 0 ? p.cap : p.ok,
                      ),
                    ),
                  ),
                ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.scale(
                    scale: pop,
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: p.ok,
                        boxShadow: [
                          BoxShadow(
                            color: p.ok.withValues(alpha: 0.45),
                            blurRadius: 30,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(Icons.check_rounded, color: p.bg, size: 60),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Opacity(
                    opacity: fade,
                    child: Column(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: p.ink,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sub,
                          style: TextStyle(fontSize: 13, color: p.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Bottom bar: a round power button flanked by two small round tools.
class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.state});
  final GameState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _RoundTool(
            icon: state.hintStage == 1
                ? Icons.auto_awesome_rounded
                : Icons.lightbulb_outline_rounded,
            label: state.hintLabel,
            enabled: state.canHint && state.hintStage < 2,
            visible: state.isLevels,
            onTap: state.showHint,
          ),
          _StartButton(state: state),
          _RoundTool(
            icon: Icons.replay_rounded,
            label: '清空',
            enabled: state.canClear,
            visible: true,
            onTap: state.clear,
          ),
        ],
      ),
    );
  }
}

/// A chunky physical start key, like the one on a bench centrifuge.
class _StartButton extends StatelessWidget {
  const _StartButton({required this.state});
  final GameState state;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final on = state.canLaunch;
    final spinning = state.run == RunState.spinning;
    final label = spinning ? '運轉中' : '啟動';
    return Semantics(
      button: true,
      enabled: on,
      label: on ? '啟動' : state.launchLabel,
      child: GestureDetector(
        onTap: on
            ? () {
                HapticFeedback.lightImpact();
                state.launch();
              }
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: on ? p.ink : p.line,
            border: Border.all(
              color: on ? p.cap : Colors.transparent,
              width: 3,
            ),
            boxShadow: on
                ? [
                    BoxShadow(
                      color: p.cap.withValues(alpha: 0.45),
                      blurRadius: 22,
                      spreadRadius: 1,
                    ),
                  ]
                : const [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.power_settings_new_rounded,
                size: 28,
                color: on ? p.bg : p.muted,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: on ? p.bg : p.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundTool extends StatelessWidget {
  const _RoundTool({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.visible,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool enabled, visible;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final fg = enabled ? p.ink : p.ink.withValues(alpha: 0.3);
    return Opacity(
      opacity: visible ? 1 : 0,
      child: IgnorePointer(
        ignoring: !visible,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: p.panel,
              shape: CircleBorder(side: BorderSide(color: p.line)),
              child: InkWell(
                onTap: enabled
                    ? () {
                        HapticFeedback.selectionClick();
                        onTap();
                      }
                    : null,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: Icon(icon, size: 24, color: fg),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
