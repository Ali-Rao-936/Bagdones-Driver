import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaytoon_rider/l10n/app_localizations.dart';
import 'package:zaytoon_rider/features/auth/presentation/screens/login_screen.dart';

void main() {
  Future<void> pumpLoginScreen(WidgetTester tester) => tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: LoginScreen(),
          ),
        ),
      );

  testWidgets('shows no validation errors before the first submit', (tester) async {
    await pumpLoginScreen(tester);

    await tester.enterText(find.byType(TextFormField).first, '1');
    await tester.pump();

    expect(find.text('Phone number is required'), findsNothing);
    expect(find.text('Enter a valid phone number'), findsNothing);
    expect(find.text('Password is required'), findsNothing);
  });

  testWidgets('validates both fields when Log in is pressed', (tester) async {
    await pumpLoginScreen(tester);

    await tester.tap(find.text('Log in'));
    await tester.pump();

    expect(find.text('Phone number is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('rejects a too-short password and a malformed phone', (tester) async {
    await pumpLoginScreen(tester);

    await tester.enterText(find.byType(TextFormField).first, 'abc');
    await tester.enterText(find.byType(TextFormField).last, '123');
    await tester.tap(find.text('Log in'));
    await tester.pump();

    expect(find.text('Enter a valid phone number'), findsOneWidget);
    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
  });
}
