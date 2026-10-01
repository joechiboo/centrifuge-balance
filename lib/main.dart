import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/game_screen.dart';
import 'theme/palette.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const CentrifugeApp());
}

class CentrifugeApp extends StatelessWidget {
  const CentrifugeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '離心機配平',
      debugShowCheckedModeBanner: false,
      theme: Palette.light.toTheme(),
      darkTheme: Palette.dark.toTheme(),
      locale: const Locale('zh', 'TW'),
      supportedLocales: const [Locale('zh', 'TW'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const GameScreen(),
    );
  }
}
