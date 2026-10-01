import 'package:flutter/material.dart';

class Palette {
  const Palette({
    required this.bg,
    required this.panel,
    required this.ink,
    required this.muted,
    required this.line,
    required this.steelHi,
    required this.steelLo,
    required this.well,
    required this.wellRing,
    required this.cap,
    required this.capHi,
    required this.fixed,
    required this.fixedHi,
    required this.ok,
    required this.bad,
    required this.lcd,
    required this.lcdFg,
  });

  final Color bg, panel, ink, muted, line;
  final Color steelHi, steelLo, well, wellRing;
  final Color cap, capHi, fixed, fixedHi;
  final Color ok, bad, lcd, lcdFg;

  static const light = Palette(
    bg: Color(0xFFE9EDF1),
    panel: Color(0xFFF7F9FB),
    ink: Color(0xFF18222D),
    muted: Color(0xFF5B6876),
    line: Color(0xFFC9D2DB),
    steelHi: Color(0xFFDFE5EA),
    steelLo: Color(0xFFAAB5C0),
    well: Color(0xFF2A3440),
    wellRing: Color(0xFF8C98A5),
    cap: Color(0xFF7B56C2),
    capHi: Color(0xFFB79CF0),
    fixed: Color(0xFFC08A1E),
    fixedHi: Color(0xFFF0CD7A),
    ok: Color(0xFF157F5B),
    bad: Color(0xFFC2372E),
    lcd: Color(0xFF10202B),
    lcdFg: Color(0xFF8FF0C4),
  );

  static const dark = Palette(
    bg: Color(0xFF11171D),
    panel: Color(0xFF1A222B),
    ink: Color(0xFFE6ECF2),
    muted: Color(0xFF93A1AF),
    line: Color(0xFF2F3B47),
    steelHi: Color(0xFF4A5764),
    steelLo: Color(0xFF2C3742),
    well: Color(0xFF0C1117),
    wellRing: Color(0xFF66737F),
    cap: Color(0xFF9A78E6),
    capHi: Color(0xFFD2C0FF),
    fixed: Color(0xFFD6A23A),
    fixedHi: Color(0xFFFFE2A0),
    ok: Color(0xFF4FD0A0),
    bad: Color(0xFFFF7A6E),
    lcd: Color(0xFF070D12),
    lcdFg: Color(0xFF8FF0C4),
  );

  static Palette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}
