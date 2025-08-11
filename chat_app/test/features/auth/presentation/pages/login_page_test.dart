import 'package:bloc_test/bloc_test.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/features/auth/presentation/pages/login_page.dart';
import 'package:chat_app/features/auth/presentation/pages/signup_page.dart';
import 'package:chat_app/features/auth/presentation/widgets/auth_form_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockNavigatorObserver mockNavigatorObserver;

  setUpAll(() {
    registerFallbackValue(FakeRoute());
    registerFallbackValue(const LoginEvent(email: '', password: ''));
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockNavigatorObserver = MockNavigatorObserver();
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest() {
    return BlocProvider<AuthBloc>.value(
      value: mockAuthBloc,
      child: MaterialApp(
        home: const LoginPage(),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  group('LoginPage', () {
    testWidgets('renders AuthForm in login mode', (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthInitial());

      await tester.pumpWidget(createWidgetUnderTest());

      final authFormFinder = find.byType(AuthForm);
      expect(authFormFinder, findsOneWidget);

      final authForm = tester.widget<AuthForm>(authFormFinder);
      expect(authForm.authMode, AuthMode.login);
      expect(authForm.isLoading, isFalse);
    });

    testWidgets('shows loading indicator when state is AuthLoading', (
      WidgetTester tester,
    ) async {
      when(() => mockAuthBloc.state).thenReturn(AuthLoading());

      await tester.pumpWidget(createWidgetUnderTest());

      final authForm = tester.widget<AuthForm>(find.byType(AuthForm));
      expect(authForm.isLoading, isTrue);
    });

    testWidgets('navigates to SignupPage on switch mode', (
      WidgetTester tester,
    ) async {
      when(() => mockAuthBloc.state).thenReturn(AuthInitial());
      await tester.pumpWidget(createWidgetUnderTest());

      final authForm = tester.widget<AuthForm>(find.byType(AuthForm));
      authForm.onSwitchMode();
      await tester.pumpAndSettle();

      verify(() => mockNavigatorObserver.didPush(any(), any()));
      expect(find.byType(SignupPage), findsOneWidget);
    });

    testWidgets('adds LoginEvent on form submission', (
      WidgetTester tester,
    ) async {
      when(() => mockAuthBloc.state).thenReturn(AuthInitial());
      await tester.pumpWidget(createWidgetUnderTest());

      final authForm = tester.widget<AuthForm>(find.byType(AuthForm));
      authForm.onSubmit({'email': 'test@test.com', 'password': 'password'});
      await tester.pump();

      final captured = verify(
        () => mockAuthBloc.add(captureAny()),
      ).captured.last;
      expect(captured, isA<LoginEvent>());
      expect((captured as LoginEvent).email, 'test@test.com');
      expect(captured.password, 'password');
    });

    testWidgets('shows error SnackBar on AuthFailure', (
      WidgetTester tester,
    ) async {
      whenListen(
        mockAuthBloc,
        Stream.fromIterable([
          AuthInitial(),
          const AuthFailure('Error occurred'),
        ]),
        initialState: AuthInitial(),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Pump for state change
      await tester.pump(); // Pump for SnackBar animation

      expect(find.text('Error occurred'), findsOneWidget);
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(
        snackBar.backgroundColor,
        Theme.of(tester.element(find.byType(SnackBar))).colorScheme.error,
      );
    });
  });
}
