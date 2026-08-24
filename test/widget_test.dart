import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_app/app/app.dart';

void main() {
  testWidgets('App initializes and displays login screen', (WidgetTester tester) async {
    // Build our app wrapped in ProviderScope and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MainApp(),
      ),
    );

    // Allow GoRouter and animations to settle
    await tester.pumpAndSettle();

    // Verify that the login screen header and button are present
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Proceed to Home (Bypass)'), findsOneWidget);
  });
}