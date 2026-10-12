import 'dart:math' as math;

import 'package:centrifuge_balance/main.dart';
import 'package:centrifuge_balance/screens/privacy_screen.dart';
import 'package:centrifuge_balance/widgets/rotor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pumpApp(WidgetTester tester, Locale locale) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.localesTestValue = [locale];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await tester.pumpWidget(const CentrifugeApp());
    await tester.pumpAndSettle();
  }

  Future<void> tapHole(WidgetTester tester, int n, int i) async {
    final rect = tester.getRect(find.byType(RotorView));
    final scale = rect.width / 400;
    final a = 2 * math.pi * i / n;
    final dx = 200 + 138 * math.sin(a);
    final dy = 200 - 138 * math.cos(a);
    await tester.tapAt(rect.topLeft + Offset(dx * scale, dy * scale));
    await tester.pump();
  }

  testWidgets('first level in Chinese: place two opposite tubes and spin up', (
    tester,
  ) async {
    await pumpApp(tester, const Locale('zh', 'TW'));

    expect(find.text('離心機配平'), findsOneWidget);
    expect(find.text('第 1 關'), findsOneWidget);

    await tapHole(tester, 6, 0);
    await tapHole(tester, 6, 3);

    await tester.tap(find.text('啟動'));
    await tester.pump();
    expect(find.text('運轉中'), findsOneWidget);

    // Spin lasts 4.2 s; the celebration is up right after.
    await tester.pump(const Duration(milliseconds: 4300));
    await tester.pump();
    expect(find.text('配平成功'), findsOneWidget);
    expect(find.text('一次就過'), findsOneWidget);

    // Levels advance by themselves after the celebration.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('第 2 關'), findsOneWidget);
  });

  testWidgets('English system language shows English everywhere', (
    tester,
  ) async {
    await pumpApp(tester, const Locale('en', 'US'));

    // No title check: the header hides it on a phone-width viewport.
    expect(find.text('Level 1'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Hint'), findsOneWidget);

    await tester.tap(find.text('Lab'));
    await tester.pumpAndSettle();
    expect(find.text('Lab 1'), findsOneWidget);
    expect(find.text('1 spare tubes'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pumpAndSettle();
    expect(find.text('How to play'), findsOneWidget);
    expect(find.text('Spare tube'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('Privacy policy'),
      find.byType(BottomSheet),
      const Offset(0, -200),
    );
    await tester.tap(find.text('Privacy policy'));
    await tester.pumpAndSettle();
    expect(find.textContaining('UNION CLINICAL LABORATORY'), findsWidgets);
    expect(find.text(privacyPolicyUrl), findsOneWidget);
    // No Chinese-only strings leaked onto the English privacy page.
    expect(find.textContaining('隱私'), findsNothing);
  });

  testWidgets('info sheet shows only what the current rotor needs', (
    tester,
  ) async {
    await pumpApp(tester, const Locale('en', 'US'));

    // Level 1: no fixed tubes, no broken holes, not the lab.
    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pumpAndSettle();
    expect(find.text('Your tube'), findsOneWidget);
    expect(find.text('Fixed tube'), findsNothing);
    expect(find.text('Spare tube'), findsNothing);
    expect(find.text('Broken hole'), findsNothing);
    expect(find.textContaining('Lab:'), findsNothing);

    // The maths stays folded until asked for.
    expect(find.text('The maths'), findsOneWidget);
    expect(find.textContaining('6 holes (prime factors 2, 3)'), findsNothing);
    await tester.tap(find.text('The maths'));
    await tester.pumpAndSettle();
    expect(find.textContaining('6 holes (prime factors 2, 3)'), findsOneWidget);
  });

  testWidgets('info sheet opens the in-app privacy policy in Chinese', (
    tester,
  ) async {
    await pumpApp(tester, const Locale('zh', 'TW'));

    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
      find.text('隱私權政策'),
      find.byType(BottomSheet),
      const Offset(0, -200),
    );
    await tester.tap(find.text('隱私權政策'));
    await tester.pumpAndSettle();

    expect(find.textContaining('由大安聯合醫事檢驗所提供'), findsOneWidget);
    expect(find.textContaining('暱稱'), findsOneWidget);
    expect(find.textContaining('SUPPORT@ucl.com.tw'), findsOneWidget);
    expect(find.text(privacyPolicyUrl), findsOneWidget);
  });

  testWidgets('clearing the last level opens the licence with a badge', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'cfg-done': [for (var i = 0; i < 9; i++) '$i'],
      for (var i = 0; i < 9; i++) 'cfg-best-$i': 1,
    });
    await pumpApp(tester, const Locale('zh', 'TW'));
    expect(find.text('第 10 關'), findsOneWidget);
    expect(find.byIcon(Icons.workspace_premium_rounded), findsNothing);

    // Level 10: pentagon every 6th hole plus the pair 1 / 16 on 30 holes.
    for (final h in [0, 6, 12, 18, 24, 1, 16]) {
      await tapHole(tester, 30, h);
    }
    await tester.tap(find.text('啟動'));
    await tester.pump(); // first tick starts the spin clock
    await tester.pump(const Duration(milliseconds: 4300));
    await tester.pump();
    expect(find.text('取得執照！'), findsOneWidget);

    await tester.tap(find.text('取得執照！'));
    await tester.pumpAndSettle();
    expect(find.text('醫檢師執照'), findsWidgets);
    expect(find.text('未具名'), findsOneWidget);
    expect(find.textContaining('CB-'), findsOneWidget);

    // Name the holder; it is printed on the certificate.
    await tester.tap(find.text('編輯暱稱'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '小美');
    await tester.tap(find.text('儲存'));
    await tester.pumpAndSettle();
    expect(find.text('小美'), findsOneWidget);

    // Back on the board the badge is now in the header.
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.workspace_premium_rounded), findsOneWidget);
  });
}
