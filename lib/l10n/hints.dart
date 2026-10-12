import '../state/game_state.dart';
import 'app_localizations.dart';

/// Localized hint for level [i] (0-based) of campaign [c].
String hintFor(AppLocalizations l, Campaign c, int i) => switch ((c, i)) {
  (Campaign.classic, 0) => l.hintL1,
  (Campaign.classic, 1) => l.hintL2,
  (Campaign.classic, 2) => l.hintL3,
  (Campaign.classic, 3) => l.hintL4,
  (Campaign.classic, 4) => l.hintL5,
  (Campaign.classic, 5) => l.hintL6,
  (Campaign.classic, 6) => l.hintL7,
  (Campaign.classic, 7) => l.hintL8,
  (Campaign.classic, 8) => l.hintL9,
  (Campaign.classic, 9) => l.hintL10,
  (Campaign.lab, 0) => l.hintLab1,
  (Campaign.lab, 1) => l.hintLab2,
  (Campaign.lab, 2) => l.hintLab3,
  (Campaign.lab, 3) => l.hintLab4,
  (Campaign.lab, 4) => l.hintLab5,
  (Campaign.lab, 5) => l.hintLab6,
  (Campaign.lab, 6) => l.hintLab7,
  (Campaign.lab, 7) => l.hintLab8,
  (Campaign.lab, 8) => l.hintLab9,
  (Campaign.lab, 9) => l.hintLab10,
  _ => '',
};
