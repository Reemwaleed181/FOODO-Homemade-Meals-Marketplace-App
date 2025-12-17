
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:foodo/main.dart';
import 'package:foodo/models/app_state.dart';

void main() {
  testWidgets('App starts with welcome screen', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => AppState(),
        child: MyApp(),
      ),
    );

    // Verify that the welcome screen is shown
    expect(find.text('HomeCook'), findsOneWidget);
    expect(find.text('Delicious Homemade Meals'), findsOneWidget);
  });

  testWidgets('Navigation to login screen works', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => AppState(),
        child: MyApp(),
      ),
    );

    // Tap the login button
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Verify that login screen is shown
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('Navigation to signup screen works', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => AppState(),
        child: MyApp(),
      ),
    );

    // Tap the signup button
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    // Verify that signup screen is shown
    expect(find.text('Create Account'), findsOneWidget);
  });
}