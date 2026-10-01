import 'package:centrifuge_balance/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('opens on the first level', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const CentrifugeApp());
    await tester.pumpAndSettle();

    expect(find.text('離心機配平'), findsOneWidget);
    expect(find.text('還差 2 支'), findsOneWidget);
    expect(find.text('試管 0 / 2'), findsOneWidget);
  });
}
