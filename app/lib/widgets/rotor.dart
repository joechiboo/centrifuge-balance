import 'dart:math' as math;

import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter/material.dart';

import '../logic/balance.dart';
import '../state/game_state.dart';
import '../theme/palette.dart';

/// Logical drawing size; everything is laid out in this square then scaled.
const double _box = 400;
const double _centre = 200;
const double _ringR = 138;

double _holeRadius(int n) => math.min(27.0, math.pi * _ringR / n * 0.78);

Offset _holeCentre(int n, int i) {
  final a = holeAngle(n, i);
  return Offset(_centre + _ringR * math.sin(a), _centre - _ringR * math.cos(a));
}

/// Top-down rotor: tappable holes, spin-up animation, wobble on failure,
/// red imbalance arrow, dashed solution guide.
class RotorView extends StatefulWidget {
  const RotorView({super.key, required this.state});
  final GameState state;

  @override
  State<RotorView> createState() => _RotorViewState();
}

class _RotorViewState extends State<RotorView> with TickerProviderStateMixin {
  static const _spinDuration = Duration(milliseconds: 4200);
  static const _ramp = 0.35; // fraction of the spin spent accelerating / braking
  static const _peakDegPerSec = 1846.0;

  late final AnimationController _spin =
      AnimationController(vsync: this, duration: _spinDuration)
        ..addListener(_onSpinTick)
        ..addStatusListener(_onSpinStatus);
  late final AnimationController _wobble = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700));

  double _angle = 0; // degrees
  double _lastT = 0;
  double _speed = 0; // 0..1 fraction of peak
  RunState _seenRun = RunState.idle;

  @override
  void initState() {
    super.initState();
    widget.state.addListener(_onState);
    _seenRun = widget.state.run;
  }

  @override
  void didUpdateWidget(RotorView old) {
    super.didUpdateWidget(old);
    if (old.state != widget.state) {
      old.state.removeListener(_onState);
      widget.state.addListener(_onState);
    }
  }

  @override
  void dispose() {
    widget.state.removeListener(_onState);
    _spin.dispose();
    _wobble.dispose();
    super.dispose();
  }

  void _onState() {
    final run = widget.state.run;
    if (run == _seenRun) return;
    _seenRun = run;
    if (run == RunState.spinning) {
      _angle = 0;
      _lastT = 0;
      _spin.forward(from: 0);
    } else if (run == RunState.unbalanced) {
      _wobble.forward(from: 0);
    }
  }

  static double _smooth(double x) => x * x * (3 - 2 * x);

  void _onSpinTick() {
    final p = _spin.value;
    final u = p < _ramp
        ? _smooth(p / _ramp)
        : p > 1 - _ramp
            ? _smooth((1 - p) / _ramp)
            : 1.0;
    final dt = (p - _lastT) * _spinDuration.inMilliseconds / 1000;
    _lastT = p;
    _angle = (_angle + u * _peakDegPerSec * dt) % 360;
    _speed = u;
    widget.state.rpm.value = (u * 400).round() * 10;
    setState(() {});
  }

  void _onSpinStatus(AnimationStatus s) {
    if (s == AnimationStatus.completed) {
      _angle = 0;
      _speed = 0;
      widget.state.completeSpin();
    }
  }

  void _onTap(TapUpDetails d, double scale) {
    final s = widget.state;
    if (s.busy) return;
    final p = d.localPosition / scale;
    final hit = math.max(_holeRadius(s.n), 16.0) + 4;
    for (var i = 0; i < s.n; i++) {
      if ((p - _holeCentre(s.n, i)).distance <= hit) {
        s.toggle(i);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final palette = Palette.of(context);
    return Semantics(
      label: '離心機轉盤俯視圖，${s.n} 孔，${s.countLabel}',
      child: AspectRatio(
        aspectRatio: 1,
        child: LayoutBuilder(builder: (context, c) {
          final scale = c.maxWidth / _box;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (d) => _onTap(d, scale),
            child: AnimatedBuilder(
              animation: _wobble,
              builder: (context, child) {
                final t = _wobble.value;
                final damp = t >= 1 ? 0.0 : (1 - t);
                final dx = math.sin(t * math.pi * 4) * 7 * damp * scale;
                final dy = math.cos(t * math.pi * 3) * 4 * damp * scale;
                final rot = math.sin(t * math.pi * 4) * 0.06 * damp;
                return Transform.translate(
                  offset: Offset(dx, dy),
                  child: Transform.rotate(angle: rot, child: child),
                );
              },
              child: CustomPaint(
                painter: _RotorPainter(
                  n: s.n,
                  fixed: s.fixed,
                  broken: s.broken,
                  placed: s.placed,
                  guide: s.guide,
                  imbalance: s.imbalance,
                  angle: _angle,
                  speed: _speed,
                  density: 0.3 + 0.6 * s.total / s.n,
                  palette: palette,
                ),
                size: Size.square(c.maxWidth),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _RotorPainter extends CustomPainter {
  _RotorPainter({
    required this.n,
    required this.fixed,
    required this.broken,
    required this.placed,
    required this.guide,
    required this.imbalance,
    required this.angle,
    required this.speed,
    required this.density,
    required this.palette,
  });

  final int n;
  final Set<int> fixed, broken, placed;
  final List<List<int>> guide;
  final Vec2? imbalance;
  final double angle, speed, density;
  final Palette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _box;
    canvas.save();
    canvas.scale(scale);
    const c = Offset(_centre, _centre);
    final p = palette;

    // Housing.
    canvas.drawCircle(c, 196, Paint()..color = p.panel);
    canvas.drawCircle(
        c,
        196,
        Paint()
          ..color = p.line
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);

    // Rotor group rotates during a spin.
    canvas.save();
    canvas.translate(_centre, _centre);
    canvas.rotate(angle * math.pi / 180);
    canvas.translate(-_centre, -_centre);
    _paintRotor(canvas);
    canvas.restore();

    // Motion blur ring fades in as the holes fade out.
    final blur = math.max(0.0, (speed - 0.45) / 0.55);
    if (blur > 0) {
      canvas.drawCircle(
          c,
          _ringR,
          Paint()
            ..color = p.cap.withValues(alpha: blur * density)
            ..style = PaintingStyle.stroke
            ..strokeWidth = _holeRadius(n) * 1.6);
    }

    final v = imbalance;
    if (v != null) _paintArrow(canvas, v);
    canvas.restore();
  }

  void _paintRotor(Canvas canvas) {
    const c = Offset(_centre, _centre);
    final p = palette;
    final ring = Paint()
      ..color = p.wellRing
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(
        c,
        184,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.24, -0.36),
            radius: 0.75,
            colors: [p.steelHi, p.steelLo],
          ).createShader(Rect.fromCircle(center: c, radius: 184)));
    canvas.drawCircle(c, 184, ring);
    canvas.drawCircle(c, 34, Paint()..color = p.steelLo);
    canvas.drawCircle(c, 34, ring);
    canvas.drawCircle(c, 12, Paint()..color = p.well);

    _paintGuide(canvas);

    final r = _holeRadius(n);
    final blur = math.max(0.0, (speed - 0.45) / 0.55);
    final holeAlpha = 1 - blur * 0.85;
    final wellFill = Paint()..color = p.well.withValues(alpha: holeAlpha);
    final wellStroke = Paint()
      ..color = p.wellRing.withValues(alpha: holeAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final brokenFill = Paint()..color = p.steelLo.withValues(alpha: holeAlpha);
    final xmark = Paint()
      ..color = p.muted.withValues(alpha: holeAlpha)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < n; i++) {
      final o = _holeCentre(n, i);
      final isF = fixed.contains(i);
      final isB = broken.contains(i);
      final isP = placed.contains(i);
      if (isB) {
        canvas.drawCircle(o, r, brokenFill);
        _dashedCircle(canvas, o, r, wellStroke);
        final d = r * 0.45;
        canvas.drawLine(o + Offset(-d, -d), o + Offset(d, d), xmark);
        canvas.drawLine(o + Offset(-d, d), o + Offset(d, -d), xmark);
        continue;
      }
      canvas.drawCircle(o, r, wellFill);
      canvas.drawCircle(o, r, wellStroke);
      if (isF || isP) {
        final cap = isF ? p.fixed : p.cap;
        final hi = isF ? p.fixedHi : p.capHi;
        canvas.drawCircle(
            o, r * 0.8, Paint()..color = cap.withValues(alpha: holeAlpha));
        canvas.drawCircle(o + Offset(-r * 0.25, -r * 0.25), r * 0.28,
            Paint()..color = hi.withValues(alpha: holeAlpha));
      }
    }
  }

  void _paintGuide(Canvas canvas) {
    if (guide.isEmpty) return;
    final paint = Paint()
      ..color = palette.cap.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeJoin = StrokeJoin.round;
    for (final group in guide) {
      final path = Path();
      for (var j = 0; j < group.length; j++) {
        final o = _holeCentre(n, group[j]);
        j == 0 ? path.moveTo(o.dx, o.dy) : path.lineTo(o.dx, o.dy);
      }
      if (group.length > 2) path.close();
      canvas.drawPath(_dash(path, 7, 6), paint);
    }
  }

  void _paintArrow(Canvas canvas, Vec2 v) {
    final u = v.unit;
    final len = math.min(110.0, 40 + v.magnitude * 30);
    const c = Offset(_centre, _centre);
    final end = c + Offset(u.x, u.y) * len;
    canvas.drawLine(
        c,
        end,
        Paint()
          ..color = palette.bad
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round);
    final tip = end + Offset(u.x, u.y) * 16;
    final side = Offset(-u.y, u.x) * 11;
    canvas.drawPath(
        Path()
          ..moveTo(tip.dx, tip.dy)
          ..lineTo(end.dx + side.dx, end.dy + side.dy)
          ..lineTo(end.dx - side.dx, end.dy - side.dy)
          ..close(),
        Paint()..color = palette.bad);
  }

  static void _dashedCircle(Canvas canvas, Offset o, double r, Paint paint) {
    final path = Path()..addOval(Rect.fromCircle(center: o, radius: r));
    canvas.drawPath(_dash(path, 3, 3), paint);
  }

  static Path _dash(Path source, double dash, double gap) {
    final out = Path();
    for (final m in source.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        out.addPath(m.extractPath(d, math.min(d + dash, m.length)), Offset.zero);
        d += dash + gap;
      }
    }
    return out;
  }

  @override
  bool shouldRepaint(_RotorPainter old) =>
      old.n != n ||
      old.angle != angle ||
      old.speed != speed ||
      old.imbalance != imbalance ||
      old.palette != palette ||
      old.guide != guide ||
      !setEquals(old.fixed, fixed) ||
      !setEquals(old.broken, broken) ||
      !setEquals(old.placed, placed);
}
