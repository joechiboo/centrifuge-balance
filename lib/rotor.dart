import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'palette.dart';

const double _ring = 138;
const double _accel = 0.35;
const int _turns = 14;

double _smooth(double x) => x * x * (3 - 2 * x);
double _smoothIntegral(double x) => x * x * x - x * x * x * x / 2;

/// Normalised rotor speed (0..1) at animation progress [p]:
/// ramp up, hold, ramp down.
double spinSpeed(double p) {
  if (p < _accel) return _smooth(p / _accel);
  if (p > 1 - _accel) return _smooth((1 - p) / _accel);
  return 1;
}

/// Rotor angle in radians at progress [p]. Exact integral of [spinSpeed],
/// scaled so the rotor ends on a whole number of turns.
double spinAngle(double p) {
  const total = 1 - _accel;
  double area;
  if (p < _accel) {
    area = _accel * _smoothIntegral(p / _accel);
  } else if (p > 1 - _accel) {
    area = total - _accel * _smoothIntegral((1 - p) / _accel);
  } else {
    area = _accel / 2 + (p - _accel);
  }
  return area / total * _turns * 2 * math.pi;
}

double holeRadius(int holes) => math.min(27.0, math.pi * _ring / holes * 0.78);

Offset holeCenter(int i, int holes) {
  final a = 2 * math.pi * i / holes;
  return Offset(200 + _ring * math.sin(a), 200 - _ring * math.cos(a));
}

/// Top-down view of the rotor. Drawn in a 400x400 coordinate space.
class Rotor extends StatelessWidget {
  const Rotor({
    super.key,
    required this.holes,
    required this.fixed,
    required this.broken,
    required this.placed,
    required this.guide,
    required this.arrow,
    required this.spin,
    required this.onTapHole,
  });

  final int holes;
  final Set<int> fixed;
  final Set<int> broken;
  final Set<int> placed;
  final List<List<int>> guide;

  /// Imbalance vector to display after a failed launch, or null.
  final Offset? arrow;
  final Animation<double> spin;
  final ValueChanged<int> onTapHole;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) {
            final p = details.localPosition * (400 / side);
            final reach = math.max(holeRadius(holes), 16.0) + 4;
            var best = -1;
            var bestDist = double.infinity;
            for (var i = 0; i < holes; i++) {
              final d = (holeCenter(i, holes) - p).distance;
              if (d < bestDist) {
                bestDist = d;
                best = i;
              }
            }
            if (best >= 0 && bestDist <= reach) onTapHole(best);
          },
          child: CustomPaint(
            size: Size.square(side),
            painter: _RotorPainter(
              holes: holes,
              fixed: fixed,
              broken: broken,
              placed: placed,
              guide: guide,
              arrow: arrow,
              spin: spin,
              palette: palette,
            ),
          ),
        );
      },
    );
  }
}

class _RotorPainter extends CustomPainter {
  _RotorPainter({
    required this.holes,
    required this.fixed,
    required this.broken,
    required this.placed,
    required this.guide,
    required this.arrow,
    required this.spin,
    required this.palette,
  }) : super(repaint: spin);

  final int holes;
  final Set<int> fixed;
  final Set<int> broken;
  final Set<int> placed;
  final List<List<int>> guide;
  final Offset? arrow;
  final Animation<double> spin;
  final Palette palette;

  static const _c = Offset(200, 200);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 400);

    // Housing.
    canvas.drawCircle(_c, 196, Paint()..color = palette.panel);
    canvas.drawCircle(
      _c,
      196,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = palette.line,
    );

    final p = spin.value;
    final speed = spinSpeed(p);
    final blur = math.max(0.0, (speed - 0.45) / 0.55);
    final r = holeRadius(holes);

    canvas.save();
    canvas.translate(200, 200);
    canvas.rotate(spinAngle(p));
    canvas.translate(-200, -200);

    // Disc and hub.
    final discRect = Rect.fromCircle(center: _c, radius: 184);
    canvas.drawCircle(
      _c,
      184,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.24, -0.36),
          radius: 0.75,
          colors: [palette.steelHi, palette.steelLo],
        ).createShader(discRect),
    );
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = palette.wellRing;
    canvas.drawCircle(_c, 184, edge);
    canvas.drawCircle(_c, 34, Paint()..color = palette.steelLo);
    canvas.drawCircle(_c, 34, edge);
    canvas.drawCircle(_c, 12, Paint()..color = palette.well);

    // Hint outline.
    final guidePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = palette.cap.withValues(alpha: 0.85);
    for (final group in guide) {
      final pts = [for (final i in group) holeCenter(i, holes)];
      final segments = pts.length == 2 ? 1 : pts.length;
      for (var i = 0; i < segments; i++) {
        _dashed(canvas, pts[i], pts[(i + 1) % pts.length], guidePaint);
      }
    }

    // Holes and tubes fade into the blur ring at speed.
    final alpha = 1 - blur * 0.85;
    Color fade(Color c) => c.withValues(alpha: alpha);
    for (var i = 0; i < holes; i++) {
      final c = holeCenter(i, holes);
      final isBroken = broken.contains(i);
      final isFixed = fixed.contains(i);
      canvas.drawCircle(
        c,
        r,
        Paint()..color = fade(isBroken ? palette.steelLo : palette.well),
      );
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = fade(palette.wellRing),
      );
      if (isBroken) {
        final d = r * 0.45;
        final x = Paint()
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round
          ..color = fade(palette.muted);
        canvas.drawLine(c + Offset(-d, -d), c + Offset(d, d), x);
        canvas.drawLine(c + Offset(-d, d), c + Offset(d, -d), x);
      }
      if (isFixed || placed.contains(i)) {
        canvas.drawCircle(
          c,
          r * 0.8,
          Paint()..color = fade(isFixed ? palette.fixed : palette.cap),
        );
        canvas.drawCircle(
          c + Offset(-r * 0.25, -r * 0.25),
          r * 0.28,
          Paint()..color = fade(isFixed ? palette.fixedHi : palette.capHi),
        );
      }
    }
    canvas.restore();

    // Motion blur ring.
    if (blur > 0) {
      final density = 0.3 + 0.6 * (fixed.length + placed.length) / holes;
      canvas.drawCircle(
        _c,
        _ring,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 1.6
          ..color = palette.cap.withValues(alpha: blur * density),
      );
    }

    // Imbalance arrow.
    final v = arrow;
    if (v != null && v.distance > 0) {
      final u = v / v.distance;
      final len = math.min(110.0, 40 + v.distance * 30);
      final end = _c + u * len;
      canvas.drawLine(
        _c,
        end,
        Paint()
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round
          ..color = palette.bad,
      );
      final n = Offset(-u.dy, u.dx);
      final tip = end + u * 16;
      final a = end + n * 11;
      final b = end - n * 11;
      canvas.drawPath(
        Path()
          ..moveTo(tip.dx, tip.dy)
          ..lineTo(a.dx, a.dy)
          ..lineTo(b.dx, b.dy)
          ..close(),
        Paint()..color = palette.bad,
      );
    }

    canvas.restore();
  }

  void _dashed(Canvas canvas, Offset from, Offset to, Paint paint) {
    const dash = 7.0;
    const gap = 6.0;
    final total = (to - from).distance;
    if (total == 0) return;
    final dir = (to - from) / total;
    var at = 0.0;
    while (at < total) {
      final end = math.min(at + dash, total);
      canvas.drawLine(from + dir * at, from + dir * end, paint);
      at += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _RotorPainter oldDelegate) => true;
}
