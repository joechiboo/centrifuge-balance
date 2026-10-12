import 'package:flutter/material.dart';

import '../data/levels.dart';
import '../l10n/app_localizations.dart';
import '../state/game_state.dart';
import '../theme/palette.dart';
import 'privacy_screen.dart';

/// Rules, legend, scores and the maths, tucked away behind the info button.
Future<void> showInfoSheet(BuildContext context, GameState state) {
  final p = Palette.of(context);
  final l = AppLocalizations.of(context);
  final counts = state.balanceable();
  final sep = l.listSeparator;
  final countsText = counts.isEmpty
      ? l.mathOnlyFull
      : l.mathAndFull(counts.join(sep));
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: p.panel,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _h(p, l.rulesHeading),
            _bullet(p, l.rule1),
            if (state.isLab) _bullet(p, l.rule3),
            const SizedBox(height: 18),
            _h(p, l.legendHeading),
            // Only the kinds of tube and hole that this rotor actually shows.
            Wrap(
              spacing: 18,
              runSpacing: 8,
              children: [
                if (state.isLab) ...[
                  _legend(p, p.fixed, l.legendSpecimen),
                  _legend(p, p.spare, l.legendSpare),
                ] else ...[
                  _legend(p, p.cap, l.legendYours),
                  if (state.fixed.isNotEmpty) _legend(p, p.fixed, l.legendFixed),
                ],
                if (state.broken.isNotEmpty)
                  _legend(p, p.steelLo, l.legendBroken, dashed: true),
              ],
            ),
            const SizedBox(height: 18),
            if (state.done.isNotEmpty || state.labDone.isNotEmpty) ...[
              _h(p, l.scoresHeading),
              _scores(p, l, state, Campaign.classic),
              const SizedBox(height: 8),
              _scores(p, l, state, Campaign.lab),
              const SizedBox(height: 18),
            ],
            Divider(color: p.line, height: 1),
            // Collapsed by default: most players never need the maths.
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 12),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                leading: Icon(Icons.functions_rounded, size: 20, color: p.muted),
                iconColor: p.muted,
                collapsedIconColor: p.muted,
                title: Text(l.mathHeading, style: _linkStyle(p)),
                children: [
                  _para(p, l.math1),
                  _para(p, l.math2),
                  _para(
                    p,
                    l.mathNow(state.n, state.factors().join(sep), countsText),
                  ),
                ],
              ),
            ),
            Divider(color: p.line, height: 1),
            _link(
              p,
              icon: Icons.privacy_tip_outlined,
              label: l.privacyHeading,
              onTap: () => Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute<void>(builder: (_) => const PrivacyScreen()),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _h(Palette p, String t) => Padding(
  padding: const EdgeInsets.only(bottom: 8),
  child: Text(
    t,
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: p.ink),
  ),
);

TextStyle _body(Palette p) =>
    TextStyle(fontSize: 14.5, color: p.muted, height: 1.6);

Widget _para(Palette p, String t) => Padding(
  padding: const EdgeInsets.only(bottom: 6),
  child: Text(t, style: _body(p)),
);

Widget _bullet(Palette p, String t) => Padding(
  padding: const EdgeInsets.only(bottom: 4),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('• ', style: _body(p)),
      Expanded(child: Text(t, style: _body(p))),
    ],
  ),
);

Widget _legend(Palette p, Color fill, String t, {bool dashed = false}) => Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fill,
        border: dashed ? Border.all(color: p.muted) : null,
      ),
    ),
    const SizedBox(width: 6),
    Text(t, style: _body(p)),
  ],
);

/// One strip per campaign: a numbered dot for every level, filled once it is
/// cleared and gold when it was cleared in a single launch. The per-level
/// best count lives on the game screen, so it is not repeated here.
Widget _scores(Palette p, AppLocalizations l, GameState state, Campaign c) {
  final all = c == Campaign.lab ? labLevels : levels;
  final done = c == Campaign.lab ? state.labDone : state.done;
  if (done.isEmpty) return const SizedBox.shrink();
  final fill = c == Campaign.lab ? p.spare : p.ok;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          c == Campaign.lab ? l.modeLab : l.modeLevels,
          style: TextStyle(fontSize: 12, color: p.muted),
        ),
      ),
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (var i = 0; i < all.length; i++)
            _dot(
              p,
              i + 1,
              cleared: done.contains(i),
              firstTry: state.bestOf(c, i) == 1,
              fill: fill,
            ),
        ],
      ),
    ],
  );
}

Widget _dot(
  Palette p,
  int n, {
  required bool cleared,
  required bool firstTry,
  required Color fill,
}) => Container(
  width: 24,
  height: 24,
  alignment: Alignment.center,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: !cleared
        ? Colors.transparent
        : firstTry
        ? p.fixed
        : fill,
    border: cleared ? null : Border.all(color: p.line),
  ),
  child: Text(
    '$n',
    style: TextStyle(
      fontSize: 11,
      fontWeight: cleared ? FontWeight.w700 : FontWeight.w400,
      color: cleared ? p.panel : p.muted,
    ),
  ),
);

TextStyle _linkStyle(Palette p) =>
    TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: p.ink);

/// A row that opens another page, Settings-style.
Widget _link(
  Palette p, {
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) => InkWell(
  onTap: onTap,
  child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Row(
      children: [
        Icon(icon, size: 20, color: p.muted),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: _linkStyle(p))),
        Icon(Icons.chevron_right_rounded, color: p.muted),
      ],
    ),
  ),
);
