import 'package:flutter/material.dart';

import 'game_page.dart';
import 'palette.dart';

void main() {
  runApp(const CentrifugeApp());
}

class CentrifugeApp extends StatelessWidget {
  const CentrifugeApp({super.key});

  ThemeData _theme(Palette p, Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: p.cap,
        brightness: brightness,
      ),
      scaffoldBackgroundColor: p.bg,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '離心機配平',
      debugShowCheckedModeBanner: false,
      theme: _theme(Palette.light, Brightness.light),
      darkTheme: _theme(Palette.dark, Brightness.dark),
      home: const GamePage(),
    );
  }
}
