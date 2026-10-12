import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../haptics.dart';
import '../l10n/app_localizations.dart';
import '../l10n/hints.dart';
import '../state/game_state.dart';
import '../theme/palette.dart';
import '../widgets/rotor.dart';
import 'info_sheet.dart';
import 'license_screen.dart';

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

  void _openLicense() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LicenseScreen(state: state, celebrate: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
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
                              if (state.isFree)
                                _HoleStepper(state: state)
                              else
                                _Progress(state: state),
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
                                      RotorView(
                                        state: state,
                                        hubLabel: _hubLabel(state),
                                      ),
                                      if (state.showCelebration)
                                        Positioned.fill(
                                          child: _Celebration(
                                            state: state,
                                            onLicense: _openLicense,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              _Message(state: state, l: l),
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

  /// Hub readout: tubes over goal, spares used over budget, or a count.
  static String _hubLabel(GameState s) => switch (s.mode) {
    GameMode.levels => '${s.total}/${s.k}',
    GameMode.lab => '${s.placed.length}/${s.level.spares}',
    GameMode.free => '${s.total}',
  };
}

class _Header extends StatelessWidget {
  const _Header({required this.state});
  final GameState state;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final l = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) {
              const style = TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              );
              final natural = (TextPainter(
                text: TextSpan(text: l.appTitle, style: style),
                maxLines: 1,
                textDirection: Directionality.of(context),
              )..layout()).width;
              // The three-pill toggle plus the licence and info buttons leave
              // little room on a phone. A title squeezed below ~80% reads as
              // a defect, so hide it instead; the launcher names the app.
              if (natural > box.maxWidth / 0.8) return const SizedBox.shrink();
              return Align(
                alignment: Alignment.centerLeft,
                child: Text(l.appTitle, maxLines: 1, style: style),
              );
            },
          ),
        ),
        _ModeToggle(state: state),
        if (state.licensed)
          IconButton(
            tooltip: l.licenseTooltip,
            icon: Icon(Icons.workspace_premium_rounded, color: p.fixed),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => LicenseScreen(state: state),
              ),
            ),
          ),
        IconButton(
          tooltip: l.infoTooltip,
          icon: Icon(Icons.info_outline, color: p.muted),
          onPressed: () => showInfoSheet(context, state),
        ),
      ],
    );
  }
}

/// Three-pill mode switch; sized by its own text so CJK labels never wrap.
class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.state});
  final GameState state;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final l = AppLocalizations.of(context);
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: on ? p.ink : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              label,
              softWrap: false,
              style: TextStyle(
                fontSize: 13,
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
        children: [
          pill(GameMode.levels, l.modeLevels),
          pill(GameMode.lab, l.modeLab),
          pill(GameMode.free, l.modeFree),
        ],
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
    final l = AppLocalizations.of(context);
    final total = state.campaignLevels.length;
    final cleared = state.campaignDone.length;
    return Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            child: _Segment(index: i, state: state, palette: p),
          ),
        ],
        const SizedBox(width: 12),
        Text(
          l.progress(cleared, total),
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
    final l = AppLocalizations.of(context);
    final current = index == state.index;
    final done = state.campaignDone.contains(index);
    final tappable = !current && state.canVisit(index) && !state.busy;
    final accent = state.isLab ? p.spare : p.cap;
    final bar = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: current ? 10 : 6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: done
            ? p.ok
            : current
            ? accent
            : p.line,
      ),
    );
    final title = state.isLab ? l.labTitle(index + 1) : l.levelTitle(index + 1);
    return Semantics(
      button: tappable,
      selected: current,
      label: l.segmentLabel(
        title,
        done
            ? l.statusCleared
            : current
            ? l.statusCurrent
            : '',
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: tappable
            ? () {
                Haptics.tap();
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
    final l = AppLocalizations.of(context);
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
        btn(Icons.remove, -1, state.n > minHoles, l.fewerHoles),
        SizedBox(
          width: 96,
          child: Text(
            l.holes(state.n),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        btn(Icons.add, 1, state.n < maxHoles, l.moreHoles),
      ],
    );
  }
}

/// Level title plus, in lab mode, the spare-tube budget as a chip. Fixed
/// tubes and broken holes are visible on the rotor itself.
class _Task extends StatelessWidget {
  const _Task({required this.state});
  final GameState state;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final l = AppLocalizations.of(context);
    final title = switch (state.mode) {
      GameMode.levels => l.levelTitle(state.index + 1),
      GameMode.lab => l.labTitle(state.index + 1),
      GameMode.free => l.freeTitle(state.n),
    };
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        if (state.isLab) ...[
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: p.spare.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.water_drop_rounded, size: 14, color: p.spare),
                const SizedBox(width: 4),
                Text(
                  l.sparesChip(state.level.spares),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: p.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Only appears when there is something to say; collapses otherwise.
class _Message extends StatelessWidget {
  const _Message({required this.state, required this.l});
  final GameState state;
  final AppLocalizations l;

  String? _text() {
    final c = state.campaign;
    final hint = c == null ? '' : hintFor(l, c, state.index);
    return switch (state.message) {
      GameMessage.none => null,
      GameMessage.tooManyTubes => l.msgTooMany(state.k),
      GameMessage.noSparesLeft => l.msgNoSpares,
      GameMessage.hintText || GameMessage.hintAfterFails => hint,
      GameMessage.hintGuide => '${l.msgGuide} $hint',
    };
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final text = _text();
    final warning =
        state.message == GameMessage.tooManyTubes ||
        state.message == GameMessage.noSparesLeft;
    final accent = warning ? p.bad : p.cap;
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      alignment: Alignment.topCenter,
      child: text == null
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      warning
                          ? Icons.error_outline_rounded
                          : Icons.lightbulb_outline_rounded,
                      size: 18,
                      color: accent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        text,
                        style: TextStyle(
                          fontSize: 15,
                          color: p.ink,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

/// Game-style clear: a check bursts out of the hub, the level advances on
/// its own a moment later, or at once on a tap. The last level of a
/// campaign and free mode wait for the tap; a clear that earns the licence
/// opens it.
class _Celebration extends StatefulWidget {
  const _Celebration({required this.state, required this.onLicense});
  final GameState state;
  final VoidCallback onLicense;

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
    if (widget.state.acknowledge()) widget.onLicense();
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
    final l = AppLocalizations.of(context);
    final s = widget.state;
    final campaign = s.campaign;
    final last = campaign != null && s.isLastLevel;
    final licence = s.justLicensed;
    final title = licence
        ? (campaign == Campaign.lab ? l.endorsementEarned : l.licenseEarned)
        : last
        ? l.celebrateAll
        : l.celebrate;
    final String sub;
    if (campaign == null) {
      sub = l.freeResult(s.n, s.total);
    } else {
      final best = s.bestOf(campaign, s.index);
      sub = s.attempts == 1
          ? l.firstTry
          : best != null && best < s.attempts
          ? '${l.attempts(s.attempts)} · ${l.best(best)}'
          : l.attempts(s.attempts);
    }
    final firstTry = campaign != null && s.attempts == 1;
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
                        color: licence ? p.fixed : p.ok,
                        boxShadow: [
                          BoxShadow(
                            color: (licence ? p.fixed : p.ok).withValues(
                              alpha: 0.45,
                            ),
                            blurRadius: 30,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        licence
                            ? Icons.workspace_premium_rounded
                            : Icons.check_rounded,
                        color: p.bg,
                        size: 60,
                      ),
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
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (firstTry) ...[
                              Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: p.fixed,
                              ),
                              const SizedBox(width: 3),
                            ],
                            Text(
                              sub,
                              style: TextStyle(fontSize: 13, color: p.muted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Where a tap goes next.
                        Icon(
                          licence
                              ? Icons.badge_outlined
                              : Icons.arrow_forward_rounded,
                          size: 22,
                          color: p.muted,
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
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _RoundTool(
            icon: state.hintStage == 1
                ? Icons.auto_awesome_rounded
                : Icons.lightbulb_outline_rounded,
            label: state.hintStage == 1 ? l.hintBtnShow : l.hintBtn,
            enabled: state.canHint && state.hintStage < 2,
            visible: !state.isFree,
            onTap: state.showHint,
          ),
          _StartButton(state: state),
          _RoundTool(
            icon: Icons.replay_rounded,
            label: l.clearBtn,
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
    final l = AppLocalizations.of(context);
    final on = state.canLaunch;
    final spinning = state.run == RunState.spinning;
    final label = spinning ? l.spinning : l.startBtn;
    final semantics = on
        ? l.startBtn
        : state.missing > 0
        ? l.missing(state.missing)
        : l.startBtn;
    return Semantics(
      button: true,
      enabled: on,
      label: semantics,
      child: GestureDetector(
        onTap: on
            ? () {
                Haptics.press();
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
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
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
                        Haptics.tap();
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
