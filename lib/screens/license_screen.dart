import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

import '../data/levels.dart';
import '../haptics.dart';
import '../l10n/app_localizations.dart';
import '../state/game_state.dart';
import '../theme/palette.dart';

/// The certificate earned by clearing all ten classic levels. Opens with
/// confetti the first time; afterwards it is reachable from the header
/// badge. The lab campaign adds an endorsement stamp.
class LicenseScreen extends StatefulWidget {
  const LicenseScreen({super.key, required this.state, this.celebrate = false});
  final GameState state;
  final bool celebrate;

  @override
  State<LicenseScreen> createState() => _LicenseScreenState();
}

class _LicenseScreenState extends State<LicenseScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey _cardKey = GlobalKey();
  late final AnimationController _confetti = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  );
  bool _sharing = false;

  @override
  void initState() {
    super.initState();
    if (widget.celebrate) {
      _confetti.forward();
      Haptics.stop();
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  Future<void> _editName() async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => _NameDialog(initial: widget.state.nickname),
    );
    if (name != null) widget.state.setNickname(name);
  }

  Future<void> _share() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _sharing = true);
    try {
      final boundary =
          _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) throw StateError('no image');
      await SharePlus.instance.share(
        ShareParams(
          text: l.shareText,
          files: [
            XFile.fromData(
              bytes.buffer.asUint8List(),
              mimeType: 'image/png',
              name: 'centrifuge-balance-licence.png',
            ),
          ],
        ),
      );
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l.shareFailed)));
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.licenseTitle),
        backgroundColor: p.bg,
        foregroundColor: p.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: ListenableBuilder(
              listenable: widget.state,
              builder: (context, _) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      children: [
                        RepaintBoundary(
                          key: _cardKey,
                          child: _Certificate(state: widget.state),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _editName,
                                icon: const Icon(Icons.edit_outlined),
                                label: Text(l.editName),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: p.ink,
                                  side: BorderSide(color: p.line),
                                  minimumSize: const Size(0, 48),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _sharing ? null : _share,
                                icon: const Icon(Icons.ios_share_rounded),
                                label: Text(l.share),
                                style: FilledButton.styleFrom(
                                  backgroundColor: p.ink,
                                  foregroundColor: p.bg,
                                  minimumSize: const Size(0, 48),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (widget.celebrate)
            IgnorePointer(
              child: AnimatedBuilder(
                animation: _confetti,
                builder: (context, _) => CustomPaint(
                  size: Size.infinite,
                  painter: _ConfettiPainter(_confetti.value, p),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Owns its text controller so the dialog's exit animation can still build
/// the field after the result has been returned.
class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.initial});
  final String initial;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = Palette.of(context);
    return AlertDialog(
      backgroundColor: p.panel,
      title: Text(l.editName),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 20,
        decoration: InputDecoration(hintText: l.nicknameHint),
        onSubmitted: (v) => Navigator.of(context).pop(v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(l.save),
        ),
      ],
    );
  }
}

/// The printable part: everything inside the gold frame.
class _Certificate extends StatelessWidget {
  const _Certificate({required this.state});
  final GameState state;

  String _licenceNo() {
    final date = (state.licensedAt ?? '').replaceAll('-', '');
    final serial =
        (state.totalBestAttempts * 7919 + state.firstTryClears * 131) % 10000;
    return 'CB-$date-${serial.toString().padLeft(4, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final l = AppLocalizations.of(context);
    final gold = p.fixed;
    final name = state.nickname.isEmpty ? l.holderUnnamed : state.nickname;
    final labelStyle = TextStyle(
      fontSize: 11,
      letterSpacing: 1.2,
      fontWeight: FontWeight.w600,
      color: p.muted,
    );
    final valueStyle = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: p.ink,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    Widget field(String label, String value) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: labelStyle),
        const SizedBox(height: 2),
        Text(value, style: valueStyle),
      ],
    );

    Widget stat(String label, String value) => Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: p.ink,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Text(label, style: TextStyle(fontSize: 11, color: p.muted)),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: p.panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gold, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: gold.withValues(alpha: 0.5)),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: gold,
                        boxShadow: [
                          BoxShadow(
                            color: gold.withValues(alpha: 0.4),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.workspace_premium_rounded,
                        color: p.bg,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.licenseTitle,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: p.ink,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            l.licenseSubtitle,
                            style: TextStyle(fontSize: 12, color: p.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text(l.holder.toUpperCase(), style: labelStyle),
                const SizedBox(height: 4),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: state.nickname.isEmpty ? p.muted : p.ink,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(child: field(l.issued, state.licensedAt ?? '')),
                    Expanded(child: field(l.licenseNo, _licenceNo())),
                  ],
                ),
                const SizedBox(height: 18),
                Divider(color: gold.withValues(alpha: 0.4), height: 1),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    stat(l.statLevels, '${state.done.length}/${levels.length}'),
                    stat(l.statLaunches, '${state.totalBestAttempts}'),
                    stat(l.statFirstTry, '${state.firstTryClears}'),
                  ],
                ),
                const SizedBox(height: 16),
                if (!state.labEndorsed)
                  Text(
                    l.labPending,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11.5, color: p.muted),
                  )
                else
                  const SizedBox(height: 14),
                const SizedBox(height: 6),
                Text(
                  l.appTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 2,
                    color: p.muted,
                  ),
                ),
              ],
            ),
            if (state.labEndorsed)
              Positioned(
                right: 0,
                bottom: 28,
                child: Transform.rotate(
                  angle: -0.22,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: p.bad, width: 2.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      l.stampLab,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: p.bad,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Paper confetti falling from the top edge, deterministic per piece.
class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.t, this.p);
  final double t;
  final Palette p;

  static const _count = 70;

  @override
  void paint(Canvas canvas, Size size) {
    if (t >= 1) return;
    final rnd = math.Random(42);
    final colors = [p.cap, p.ok, p.fixed, p.spare, p.bad];
    for (var i = 0; i < _count; i++) {
      final x0 = rnd.nextDouble() * size.width;
      final delay = rnd.nextDouble() * 0.35;
      final speed = 0.8 + rnd.nextDouble() * 0.6;
      final drift = (rnd.nextDouble() - 0.5) * 120;
      final spin = rnd.nextDouble() * 8;
      final w = 6 + rnd.nextDouble() * 6;
      final h = 10 + rnd.nextDouble() * 8;
      final color = colors[i % colors.length];
      final u = ((t - delay) / (1 - delay)).clamp(0.0, 1.0).toDouble() * speed;
      if (u <= 0) continue;
      final y = -20 + u * (size.height + 40);
      if (y > size.height + 20) continue;
      final x = x0 + math.sin(u * 6 + i) * 14 + drift * u;
      final fade = (1 - math.max(0.0, (t - 0.75) / 0.25))
          .clamp(0.0, 1.0)
          .toDouble();
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(u * spin + i);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: w, height: h),
          const Radius.circular(2),
        ),
        Paint()..color = color.withValues(alpha: fade),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
