import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'haptics.dart';
import 'l10n/app_localizations.dart';
import 'screens/game_screen.dart';
import 'theme/palette.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Haptics.init();
  runApp(const CentrifugeApp());
}

class CentrifugeApp extends StatelessWidget {
  const CentrifugeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: Palette.light.toTheme(),
      darkTheme: Palette.dark.toTheme(),
      // English first: any non-Chinese system language falls back to it.
      supportedLocales: const [Locale('en'), Locale('zh')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      home: const GameScreen(),
    );
  }
}
