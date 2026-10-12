import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// appTitle
  ///
  /// In en, this message translates to:
  /// **'Centrifuge Balance'**
  String get appTitle;

  /// modeLevels
  ///
  /// In en, this message translates to:
  /// **'Levels'**
  String get modeLevels;

  /// modeLab
  ///
  /// In en, this message translates to:
  /// **'Lab'**
  String get modeLab;

  /// modeFree
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get modeFree;

  /// infoTooltip
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get infoTooltip;

  /// licenseTooltip
  ///
  /// In en, this message translates to:
  /// **'Licence'**
  String get licenseTooltip;

  /// levelTitle
  ///
  /// In en, this message translates to:
  /// **'Level {n}'**
  String levelTitle(int n);

  /// labTitle
  ///
  /// In en, this message translates to:
  /// **'Lab {n}'**
  String labTitle(int n);

  /// freeTitle
  ///
  /// In en, this message translates to:
  /// **'Free · {n} holes'**
  String freeTitle(int n);

  /// sparesChip
  ///
  /// In en, this message translates to:
  /// **'{n} spare tubes'**
  String sparesChip(int n);

  /// holes
  ///
  /// In en, this message translates to:
  /// **'{n} holes'**
  String holes(int n);

  /// fewerHoles
  ///
  /// In en, this message translates to:
  /// **'Fewer holes'**
  String get fewerHoles;

  /// moreHoles
  ///
  /// In en, this message translates to:
  /// **'More holes'**
  String get moreHoles;

  /// progress
  ///
  /// In en, this message translates to:
  /// **'{done} / {total}'**
  String progress(int done, int total);

  /// segmentLabel
  ///
  /// In en, this message translates to:
  /// **'{title}{status}'**
  String segmentLabel(String title, String status);

  /// statusCleared
  ///
  /// In en, this message translates to:
  /// **', cleared'**
  String get statusCleared;

  /// statusCurrent
  ///
  /// In en, this message translates to:
  /// **', current'**
  String get statusCurrent;

  /// hintBtn
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get hintBtn;

  /// hintBtnShow
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get hintBtnShow;

  /// clearBtn
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearBtn;

  /// startBtn
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startBtn;

  /// spinning
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get spinning;

  /// missing
  ///
  /// In en, this message translates to:
  /// **'{n} more'**
  String missing(int n);

  /// msgTooMany
  ///
  /// In en, this message translates to:
  /// **'Only {k} tubes. Remove one first.'**
  String msgTooMany(int k);

  /// msgNoSpares
  ///
  /// In en, this message translates to:
  /// **'No spare tubes left.'**
  String get msgNoSpares;

  /// msgGuide
  ///
  /// In en, this message translates to:
  /// **'The dashed shape is one solution.'**
  String get msgGuide;

  /// celebrate
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get celebrate;

  /// celebrateAll
  ///
  /// In en, this message translates to:
  /// **'All clear!'**
  String get celebrateAll;

  /// firstTry
  ///
  /// In en, this message translates to:
  /// **'First try'**
  String get firstTry;

  /// attempts
  ///
  /// In en, this message translates to:
  /// **'Done in {n}'**
  String attempts(int n);

  /// best
  ///
  /// In en, this message translates to:
  /// **'best {n}'**
  String best(int n);

  /// freeResult
  ///
  /// In en, this message translates to:
  /// **'{t} tubes in {n} holes'**
  String freeResult(int n, int t);

  /// rulesHeading
  ///
  /// In en, this message translates to:
  /// **'How to play'**
  String get rulesHeading;

  /// rule1
  ///
  /// In en, this message translates to:
  /// **'Tap holes to place tubes, then press Start.'**
  String get rule1;

  /// rule3
  ///
  /// In en, this message translates to:
  /// **'Lab: specimens stay put; balance with spare tubes.'**
  String get rule3;

  /// legendHeading
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get legendHeading;

  /// legendYours
  ///
  /// In en, this message translates to:
  /// **'Your tube'**
  String get legendYours;

  /// legendFixed
  ///
  /// In en, this message translates to:
  /// **'Fixed tube'**
  String get legendFixed;

  /// legendSpecimen
  ///
  /// In en, this message translates to:
  /// **'Specimen'**
  String get legendSpecimen;

  /// legendSpare
  ///
  /// In en, this message translates to:
  /// **'Spare tube'**
  String get legendSpare;

  /// legendBroken
  ///
  /// In en, this message translates to:
  /// **'Broken hole'**
  String get legendBroken;

  /// scoresHeading
  ///
  /// In en, this message translates to:
  /// **'Scores'**
  String get scoresHeading;

  /// mathHeading
  ///
  /// In en, this message translates to:
  /// **'The maths'**
  String get mathHeading;

  /// math1
  ///
  /// In en, this message translates to:
  /// **'Each tube is a vector from the centre to its hole; balanced means they sum to zero.'**
  String get math1;

  /// math2
  ///
  /// In en, this message translates to:
  /// **'An n-hole rotor balances k tubes exactly when both k and n−k are sums of n\'s prime factors.'**
  String get math2;

  /// mathNow
  ///
  /// In en, this message translates to:
  /// **'{n} holes (prime factors {factors}): {counts}.'**
  String mathNow(int n, String factors, String counts);

  /// mathOnlyFull
  ///
  /// In en, this message translates to:
  /// **'only a full rotor balances'**
  String get mathOnlyFull;

  /// mathAndFull
  ///
  /// In en, this message translates to:
  /// **'{counts}, and full'**
  String mathAndFull(String counts);

  /// listSeparator
  ///
  /// In en, this message translates to:
  /// **', '**
  String get listSeparator;

  /// privacyHeading
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyHeading;

  /// privacyTitle
  ///
  /// In en, this message translates to:
  /// **'Centrifuge Balance Privacy Policy'**
  String get privacyTitle;

  /// lastUpdated
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date}'**
  String lastUpdated(String date);

  /// privacyIntro
  ///
  /// In en, this message translates to:
  /// **'The Centrifuge Balance app (“the App”) is provided by UNION CLINICAL LABORATORY (大安聯合醫事檢驗所).'**
  String get privacyIntro;

  /// privacy1Title
  ///
  /// In en, this message translates to:
  /// **'We do not collect any personal data'**
  String get privacy1Title;

  /// privacy1
  ///
  /// In en, this message translates to:
  /// **'The App requires no account, does not connect to the internet, shows no ads, and contains no analytics or tracking tools. No data is shared with any third party.'**
  String get privacy1;

  /// privacy2Title
  ///
  /// In en, this message translates to:
  /// **'Data kept only on your device'**
  String get privacy2Title;

  /// privacy2
  ///
  /// In en, this message translates to:
  /// **'Your level progress, best scores, last game state and the optional nickname you type for the licence are stored only on your device and are never uploaded. Uninstalling the App or clearing its data deletes them.'**
  String get privacy2;

  /// privacy3Title
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get privacy3Title;

  /// privacy3
  ///
  /// In en, this message translates to:
  /// **'The App only uses the vibration permission, for haptic feedback during play. Sharing the licence image uses the system share sheet and sends nothing anywhere by itself.'**
  String get privacy3;

  /// privacy4Title
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get privacy4Title;

  /// privacy4
  ///
  /// In en, this message translates to:
  /// **'The App is suitable for all ages and collects no data from children.'**
  String get privacy4;

  /// privacy5Title
  ///
  /// In en, this message translates to:
  /// **'Changes'**
  String get privacy5Title;

  /// privacy5
  ///
  /// In en, this message translates to:
  /// **'If we add any feature that affects how data is used (for example, ads), we will update this policy first and mention it in the App\'s release notes.'**
  String get privacy5;

  /// contactHeading
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contactHeading;

  /// contactBlock
  ///
  /// In en, this message translates to:
  /// **'UNION CLINICAL LABORATORY, IT Office\nNo. 33, Ln. 151, Sec. 2, Fuxing S. Rd., Da’an Dist., Taipei City, Taiwan\nPhone: 02-2704-9977\nEmail: SUPPORT@ucl.com.tw'**
  String get contactBlock;

  /// webVersion
  ///
  /// In en, this message translates to:
  /// **'Web version'**
  String get webVersion;

  /// licenseTitle
  ///
  /// In en, this message translates to:
  /// **'Medical Technologist Licence'**
  String get licenseTitle;

  /// licenseSubtitle
  ///
  /// In en, this message translates to:
  /// **'Centrifuge Balance · Certificate of Competence'**
  String get licenseSubtitle;

  /// holder
  ///
  /// In en, this message translates to:
  /// **'Holder'**
  String get holder;

  /// holderUnnamed
  ///
  /// In en, this message translates to:
  /// **'Unnamed'**
  String get holderUnnamed;

  /// issued
  ///
  /// In en, this message translates to:
  /// **'Issued'**
  String get issued;

  /// licenseNo
  ///
  /// In en, this message translates to:
  /// **'Licence no.'**
  String get licenseNo;

  /// statLevels
  ///
  /// In en, this message translates to:
  /// **'Levels'**
  String get statLevels;

  /// statLaunches
  ///
  /// In en, this message translates to:
  /// **'Launches'**
  String get statLaunches;

  /// statFirstTry
  ///
  /// In en, this message translates to:
  /// **'First-try clears'**
  String get statFirstTry;

  /// stampLab
  ///
  /// In en, this message translates to:
  /// **'LAB ENDORSED'**
  String get stampLab;

  /// labPending
  ///
  /// In en, this message translates to:
  /// **'Clear all 10 lab levels to add the endorsement.'**
  String get labPending;

  /// editName
  ///
  /// In en, this message translates to:
  /// **'Edit name'**
  String get editName;

  /// share
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// nicknameHint
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nicknameHint;

  /// save
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// shareText
  ///
  /// In en, this message translates to:
  /// **'I earned my Centrifuge Balance Medical Technologist Licence!'**
  String get shareText;

  /// shareFailed
  ///
  /// In en, this message translates to:
  /// **'Sharing is not available here.'**
  String get shareFailed;

  /// licenseEarned
  ///
  /// In en, this message translates to:
  /// **'Licence earned!'**
  String get licenseEarned;

  /// endorsementEarned
  ///
  /// In en, this message translates to:
  /// **'Lab endorsement earned!'**
  String get endorsementEarned;

  /// viewLicense
  ///
  /// In en, this message translates to:
  /// **'View licence'**
  String get viewLicense;

  /// hintL1
  ///
  /// In en, this message translates to:
  /// **'Put them face to face.'**
  String get hintL1;

  /// hintL2
  ///
  /// In en, this message translates to:
  /// **'Every other hole: a triangle.'**
  String get hintL2;

  /// hintL3
  ///
  /// In en, this message translates to:
  /// **'Mirror each fixed tube.'**
  String get hintL3;

  /// hintL4
  ///
  /// In en, this message translates to:
  /// **'Opposite is broken; make a triangle (every 4th hole).'**
  String get hintL4;

  /// hintL5
  ///
  /// In en, this message translates to:
  /// **'5 = 3 + 2: a triangle plus a pair.'**
  String get hintL5;

  /// hintL6
  ///
  /// In en, this message translates to:
  /// **'Watch the gaps: balance the 5 empty holes.'**
  String get hintL6;

  /// hintL7
  ///
  /// In en, this message translates to:
  /// **'Every other hole: a pentagon.'**
  String get hintL7;

  /// hintL8
  ///
  /// In en, this message translates to:
  /// **'Mirror one; make the other a triangle\'s corner.'**
  String get hintL8;

  /// hintL9
  ///
  /// In en, this message translates to:
  /// **'7 = 5 + 2: a pentagon plus a pair.'**
  String get hintL9;

  /// hintL10
  ///
  /// In en, this message translates to:
  /// **'Pentagon every 6th hole, plus a pair.'**
  String get hintL10;

  /// hintLab1
  ///
  /// In en, this message translates to:
  /// **'Add one opposite.'**
  String get hintLab1;

  /// hintLab2
  ///
  /// In en, this message translates to:
  /// **'Mirror each specimen.'**
  String get hintLab2;

  /// hintLab3
  ///
  /// In en, this message translates to:
  /// **'120° apart: fill the triangle\'s third corner.'**
  String get hintLab3;

  /// hintLab4
  ///
  /// In en, this message translates to:
  /// **'Opposite is broken: two spares make a triangle.'**
  String get hintLab4;

  /// hintLab5
  ///
  /// In en, this message translates to:
  /// **'The pair already mirrored needs nothing.'**
  String get hintLab5;

  /// hintLab6
  ///
  /// In en, this message translates to:
  /// **'Three spares complete a pentagon.'**
  String get hintLab6;

  /// hintLab7
  ///
  /// In en, this message translates to:
  /// **'One pair plus one triangle: two spares.'**
  String get hintLab7;

  /// hintLab8
  ///
  /// In en, this message translates to:
  /// **'Two pairs plus a triangle.'**
  String get hintLab8;

  /// hintLab9
  ///
  /// In en, this message translates to:
  /// **'15 holes have no opposite: make a pentagon.'**
  String get hintLab9;

  /// hintLab10
  ///
  /// In en, this message translates to:
  /// **'A pentagon missing two corners, plus one mirror.'**
  String get hintLab10;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
