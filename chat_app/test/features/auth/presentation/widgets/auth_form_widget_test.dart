import 'package:chat_app/features/auth/presentation/widgets/auth_form_widget.dart';
import 'package:chat_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:chat_app/features/auth/presentation/widgets/text_field_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthForm Widget Test', () {
    late VoidCallback onSwitchMode;
    late Function(Map<String, String>) onSubmit;
    bool switchModeCalled = false;
    Map<String, String>? submittedData;

    setUp(() {
      switchModeCalled = false;
      submittedData = null;
      onSwitchMode = () => switchModeCalled = true;
      onSubmit = (formData) => submittedData = formData;
    });

    Widget createWidget({required AuthMode authMode, bool isLoading = false}) {
      return MaterialApp(
        home: AuthForm(
          authMode: authMode,
          onSwitchMode: onSwitchMode,
          onSubmit: onSubmit,
          isLoading: isLoading,
        ),
      );
    }

    group('Login Mode', () {
      final bottomTextFinder = find.byKey(const Key('auth_form_bottom_text'));
      testWidgets('should display login UI elements', (tester) async {
        await tester.pumpWidget(createWidget(authMode: AuthMode.login));

        // --- Your other expects are fine ---
        expect(find.text('Sign into your account'), findsOneWidget);
        expect(find.widgetWithText(CustomTextField, 'Email'), findsOneWidget);
        expect(
          find.widgetWithText(CustomTextField, 'Password'),
          findsOneWidget,
        );
        expect(find.widgetWithText(CustomButton, 'SIGN IN'), findsOneWidget);

        expect(bottomTextFinder, findsOneWidget);

        final richText = tester.widget<RichText>(bottomTextFinder);
        final textSpan = richText.text as TextSpan;

        expect(textSpan.children, isNotNull);
        expect(textSpan.children!.length, 2);
        expect(
          (textSpan.children![0] as TextSpan).text,
          "Don't have an account?",
        );
        expect((textSpan.children![1] as TextSpan).text, 'SIGN UP');

        // --- Your "findsNothing" expects are fine ---
        expect(find.widgetWithText(CustomTextField, 'Name'), findsNothing);
        expect(
          find.widgetWithText(CustomTextField, 'Confirm Password'),
          findsNothing,
        );
        expect(find.byType(Checkbox), findsNothing);
      });
      testWidgets('should call onSwitchMode when "SIGN UP" is tapped', (
        tester,
      ) async {
        await tester.pumpWidget(createWidget(authMode: AuthMode.login));

        final richText = tester.widget<RichText>(bottomTextFinder);
        final textSpanWithRecognizer =
            (richText.text as TextSpan).children![1] as TextSpan;
        final recognizer =
            textSpanWithRecognizer.recognizer as TapGestureRecognizer;
        recognizer.onTap!();
        await tester.pump();

        expect(switchModeCalled, isTrue);
      });

      testWidgets('should show validation errors for empty fields', (
        tester,
      ) async {
        await tester.pumpWidget(createWidget(authMode: AuthMode.login));

        await tester.tap(find.widgetWithText(CustomButton, 'SIGN IN'));
        await tester.pump();

        expect(
          find.text('Please enter a valid email address.'),
          findsOneWidget,
        );
        expect(
          find.text('Password must be at least 6 characters long.'),
          findsOneWidget,
        );
        expect(submittedData, isNull);
      });

      testWidgets(
        'should call onSubmit with correct data on valid submission',
        (tester) async {
          await tester.pumpWidget(createWidget(authMode: AuthMode.login));

          await tester.enterText(
            find.widgetWithText(CustomTextField, 'Email'),
            'test@example.com',
          );
          await tester.enterText(
            find.widgetWithText(CustomTextField, 'Password'),
            'password123',
          );
          await tester.tap(find.widgetWithText(CustomButton, 'SIGN IN'));
          await tester.pump();

          expect(submittedData, isNotNull);
          expect(submittedData, {
            'email': 'test@example.com',
            'password': 'password123',
          });
        },
      );
    });

    group('Signup Mode', () {
      final bottomTextFinder = find.byKey(const Key('auth_form_bottom_text'));
      testWidgets('should display signup UI elements', (tester) async {
        await tester.pumpWidget(createWidget(authMode: AuthMode.signup));

        expect(find.text('Create your account'), findsOneWidget);
        expect(find.widgetWithText(CustomTextField, 'Name'), findsOneWidget);
        expect(find.widgetWithText(CustomTextField, 'Email'), findsOneWidget);
        expect(
          find.widgetWithText(CustomTextField, 'Password'),
          findsOneWidget,
        );
        expect(
          find.widgetWithText(CustomTextField, 'Confirm Password'),
          findsOneWidget,
        );
        expect(find.byType(Checkbox), findsOneWidget);

        expect(find.widgetWithText(CustomButton, 'SIGN UP'), findsOneWidget);

        final richText = tester.widget<RichText>(bottomTextFinder);
        final textSpan = richText.text as TextSpan;

        expect(textSpan.children, isNotNull);
        expect(textSpan.children!.length, 2);
        expect((textSpan.children![0] as TextSpan).text, 'Have an account?');
        expect((textSpan.children![1] as TextSpan).text, 'SIGN IN');
      });

      testWidgets('should show validation errors for mismatched passwords', (
        tester,
      ) async {
        await tester.pumpWidget(createWidget(authMode: AuthMode.signup));

        await tester.enterText(
          find.widgetWithText(CustomTextField, 'Password'),
          'password123',
        );
        await tester.enterText(
          find.widgetWithText(CustomTextField, 'Confirm Password'),
          'password456',
        );
        final buttonFinder = find.widgetWithText(CustomButton, 'SIGN UP');

        await tester.ensureVisible(buttonFinder);

        await tester.tap(buttonFinder);
        await tester.pump();

        expect(find.text('Passwords do not match.'), findsOneWidget);
        expect(submittedData, isNull);
      });

      testWidgets('should show snackbar if terms are not accepted', (
        tester,
      ) async {
        await tester.pumpWidget(createWidget(authMode: AuthMode.signup));

        await tester.enterText(
          find.widgetWithText(CustomTextField, 'Name'),
          'Test User',
        );
        await tester.enterText(
          find.widgetWithText(CustomTextField, 'Email'),
          'test@example.com',
        );
        await tester.enterText(
          find.widgetWithText(CustomTextField, 'Password'),
          'password123',
        );
        await tester.enterText(
          find.widgetWithText(CustomTextField, 'Confirm Password'),
          'password123',
        );

        final buttonFinder = find.widgetWithText(CustomButton, 'SIGN UP');

        await tester.ensureVisible(buttonFinder);

        await tester.tap(buttonFinder);
        await tester.pump();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(
          find.text('Please accept the terms and conditions to sign up.'),
          findsOneWidget,
        );
        expect(submittedData, isNull);
      });

      testWidgets(
        'should call onSubmit with correct data on valid submission',
        (tester) async {
          await tester.pumpWidget(createWidget(authMode: AuthMode.signup));

          await tester.enterText(
            find.widgetWithText(CustomTextField, 'Name'),
            'Test User',
          );
          await tester.enterText(
            find.widgetWithText(CustomTextField, 'Email'),
            'test@example.com',
          );
          await tester.enterText(
            find.widgetWithText(CustomTextField, 'Password'),
            'password123',
          );
          await tester.enterText(
            find.widgetWithText(CustomTextField, 'Confirm Password'),
            'password123',
          );
          final checkboxFinder = find.byType(Checkbox);
          await tester.ensureVisible(checkboxFinder);
          await tester.tap(checkboxFinder);
          await tester.pump();

          final buttonFinder = find.widgetWithText(CustomButton, 'SIGN UP');

          await tester.ensureVisible(buttonFinder);

          await tester.tap(buttonFinder);
          await tester.pump();

          expect(submittedData, isNotNull);
          expect(submittedData, {
            'name': 'Test User',
            'email': 'test@example.com',
            'password': 'password123',
          });
        },
      );
    });

    group('Loading State', () {
      testWidgets('should show loading indicator when isLoading is true', (
        tester,
      ) async {
        await tester.pumpWidget(
          createWidget(authMode: AuthMode.login, isLoading: true),
        );

        // Assuming CustomButton shows a CircularProgressIndicator when isLoading is true
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });
  });
}
