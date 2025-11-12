// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safa_app/main.dart';

void main() {
  testWidgets('Travel tab loads hero section', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      SafaApp(
        prefs: prefs,
        enableMessaging: false,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Садака'), findsOneWidget);
    expect(find.text('Путешествия'), findsOneWidget);

    await tester.tap(find.text('Путешествия'));
    await tester.pumpAndSettle();

    expect(find.text('Путешествия'), findsWidgets);
    expect(
      find.text('Откройте для себя уникальные путешествия'),
      findsOneWidget,
    );
  });
}
