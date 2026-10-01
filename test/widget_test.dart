import 'package:centrifuge_balance/main.dart';
import 'package:centrifuge_balance/widgets/rotor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('first level: place two opposite tubes and spin up',
      (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const CentrifugeApp());
    await tester.pumpAndSettle();

    expect(find.text('離心機配平'), findsOneWidget);
    expect(find.text('第 1 關 · 放 2 支'), findsOneWidget);

    final rotor = find.byType(RotorView);
    final rect = tester.getRect(rotor);
    final scale = rect.width / 400;
    // Hole 0 is at the top (200,62), hole 3 at the bottom (200,338).
    await tester.tapAt(rect.topLeft + Offset(200 * scale, 62 * scale));
    await tester.pump();
    await tester.tapAt(rect.topLeft + Offset(200 * scale, 338 * scale));
    await tester.pump();

    await tester.tap(find.text('啟動'));
    await tester.pump();
    expect(find.text('運轉中'), findsOneWidget);

    // Spin lasts 4.2 s; the celebration is up right after.
    await tester.pump(const Duration(milliseconds: 4300));
    await tester.pump();
    expect(find.text('配平成功'), findsOneWidget);

    // Levels advance by themselves after the celebration.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('第 2 關 · 放 3 支'), findsOneWidget);
  });
}
