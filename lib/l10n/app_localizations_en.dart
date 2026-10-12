// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Centrifuge Balance';

  @override
  String get modeLevels => 'Levels';

  @override
  String get modeLab => 'Lab';

  @override
  String get modeFree => 'Free';

  @override
  String get infoTooltip => 'About';

  @override
  String get licenseTooltip => 'Licence';

  @override
  String levelTitle(int n) {
    return 'Level $n';
  }

  @override
  String labTitle(int n) {
    return 'Lab $n';
  }

  @override
  String freeTitle(int n) {
    return 'Free · $n holes';
  }

  @override
  String sparesChip(int n) {
    return '$n spare tubes';
  }

  @override
  String holes(int n) {
    return '$n holes';
  }

  @override
  String get fewerHoles => 'Fewer holes';

  @override
  String get moreHoles => 'More holes';

  @override
  String progress(int done, int total) {
    return '$done / $total';
  }

  @override
  String segmentLabel(String title, String status) {
    return '$title$status';
  }

  @override
  String get statusCleared => ', cleared';

  @override
  String get statusCurrent => ', current';

  @override
  String get hintBtn => 'Hint';

  @override
  String get hintBtnShow => 'Show';

  @override
  String get clearBtn => 'Clear';

  @override
  String get startBtn => 'Start';

  @override
  String get spinning => 'Running';

  @override
  String missing(int n) {
    return '$n more';
  }

  @override
  String msgTooMany(int k) {
    return 'Only $k tubes. Remove one first.';
  }

  @override
  String get msgNoSpares => 'No spare tubes left.';

  @override
  String get msgGuide => 'The dashed shape is one solution.';

  @override
  String get celebrate => 'Balanced';

  @override
  String get celebrateAll => 'All clear!';

  @override
  String get firstTry => 'First try';

  @override
  String attempts(int n) {
    return 'Done in $n';
  }

  @override
  String best(int n) {
    return 'best $n';
  }

  @override
  String freeResult(int n, int t) {
    return '$t tubes in $n holes';
  }

  @override
  String get rulesHeading => 'How to play';

  @override
  String get rule1 => 'Tap holes to place tubes, then press Start.';

  @override
  String get rule3 => 'Lab: specimens stay put; balance with spare tubes.';

  @override
  String get legendHeading => 'Legend';

  @override
  String get legendYours => 'Your tube';

  @override
  String get legendFixed => 'Fixed tube';

  @override
  String get legendSpecimen => 'Specimen';

  @override
  String get legendSpare => 'Spare tube';

  @override
  String get legendBroken => 'Broken hole';

  @override
  String get scoresHeading => 'Scores';

  @override
  String get mathHeading => 'The maths';

  @override
  String get math1 =>
      'Each tube is a vector from the centre to its hole; balanced means they sum to zero.';

  @override
  String get math2 =>
      'An n-hole rotor balances k tubes exactly when both k and n−k are sums of n\'s prime factors.';

  @override
  String mathNow(int n, String factors, String counts) {
    return '$n holes (prime factors $factors): $counts.';
  }

  @override
  String get mathOnlyFull => 'only a full rotor balances';

  @override
  String mathAndFull(String counts) {
    return '$counts, and full';
  }

  @override
  String get listSeparator => ', ';

  @override
  String get privacyHeading => 'Privacy policy';

  @override
  String get privacyTitle => 'Centrifuge Balance Privacy Policy';

  @override
  String lastUpdated(String date) {
    return 'Last updated: $date';
  }

  @override
  String get privacyIntro =>
      'The Centrifuge Balance app (“the App”) is provided by UNION CLINICAL LABORATORY (大安聯合醫事檢驗所).';

  @override
  String get privacy1Title => 'We do not collect any personal data';

  @override
  String get privacy1 =>
      'The App requires no account, does not connect to the internet, shows no ads, and contains no analytics or tracking tools. No data is shared with any third party.';

  @override
  String get privacy2Title => 'Data kept only on your device';

  @override
  String get privacy2 =>
      'Your level progress, best scores, last game state and the optional nickname you type for the licence are stored only on your device and are never uploaded. Uninstalling the App or clearing its data deletes them.';

  @override
  String get privacy3Title => 'Permissions';

  @override
  String get privacy3 =>
      'The App only uses the vibration permission, for haptic feedback during play. Sharing the licence image uses the system share sheet and sends nothing anywhere by itself.';

  @override
  String get privacy4Title => 'Children';

  @override
  String get privacy4 =>
      'The App is suitable for all ages and collects no data from children.';

  @override
  String get privacy5Title => 'Changes';

  @override
  String get privacy5 =>
      'If we add any feature that affects how data is used (for example, ads), we will update this policy first and mention it in the App\'s release notes.';

  @override
  String get contactHeading => 'Contact';

  @override
  String get contactBlock =>
      'UNION CLINICAL LABORATORY, IT Office\nNo. 33, Ln. 151, Sec. 2, Fuxing S. Rd., Da’an Dist., Taipei City, Taiwan\nPhone: 02-2704-9977\nEmail: SUPPORT@ucl.com.tw';

  @override
  String get webVersion => 'Web version';

  @override
  String get licenseTitle => 'Medical Technologist Licence';

  @override
  String get licenseSubtitle =>
      'Centrifuge Balance · Certificate of Competence';

  @override
  String get holder => 'Holder';

  @override
  String get holderUnnamed => 'Unnamed';

  @override
  String get issued => 'Issued';

  @override
  String get licenseNo => 'Licence no.';

  @override
  String get statLevels => 'Levels';

  @override
  String get statLaunches => 'Launches';

  @override
  String get statFirstTry => 'First-try clears';

  @override
  String get stampLab => 'LAB ENDORSED';

  @override
  String get labPending => 'Clear all 10 lab levels to add the endorsement.';

  @override
  String get editName => 'Edit name';

  @override
  String get share => 'Share';

  @override
  String get nicknameHint => 'Nickname';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get shareText =>
      'I earned my Centrifuge Balance Medical Technologist Licence!';

  @override
  String get shareFailed => 'Sharing is not available here.';

  @override
  String get licenseEarned => 'Licence earned!';

  @override
  String get endorsementEarned => 'Lab endorsement earned!';

  @override
  String get viewLicense => 'View licence';

  @override
  String get hintL1 => 'Put them face to face.';

  @override
  String get hintL2 => 'Every other hole: a triangle.';

  @override
  String get hintL3 => 'Mirror each fixed tube.';

  @override
  String get hintL4 => 'Opposite is broken; make a triangle (every 4th hole).';

  @override
  String get hintL5 => '5 = 3 + 2: a triangle plus a pair.';

  @override
  String get hintL6 => 'Watch the gaps: balance the 5 empty holes.';

  @override
  String get hintL7 => 'Every other hole: a pentagon.';

  @override
  String get hintL8 => 'Mirror one; make the other a triangle\'s corner.';

  @override
  String get hintL9 => '7 = 5 + 2: a pentagon plus a pair.';

  @override
  String get hintL10 => 'Pentagon every 6th hole, plus a pair.';

  @override
  String get hintLab1 => 'Add one opposite.';

  @override
  String get hintLab2 => 'Mirror each specimen.';

  @override
  String get hintLab3 => '120° apart: fill the triangle\'s third corner.';

  @override
  String get hintLab4 => 'Opposite is broken: two spares make a triangle.';

  @override
  String get hintLab5 => 'The pair already mirrored needs nothing.';

  @override
  String get hintLab6 => 'Three spares complete a pentagon.';

  @override
  String get hintLab7 => 'One pair plus one triangle: two spares.';

  @override
  String get hintLab8 => 'Two pairs plus a triangle.';

  @override
  String get hintLab9 => '15 holes have no opposite: make a pentagon.';

  @override
  String get hintLab10 => 'A pentagon missing two corners, plus one mirror.';
}
