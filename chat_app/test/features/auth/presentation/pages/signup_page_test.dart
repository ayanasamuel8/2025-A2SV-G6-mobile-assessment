import 'package:bloc_test/bloc_test.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/features/auth/presentation/pages/login_page.dart';
import 'package:chat_app/features/auth/presentation/pages/signup_page.dart';
import 'package:chat_app/features/auth/presentation/widgets/auth_form_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockNavigatorObserver mockNavigatorObserver;

  setUpAll(() {
    registerFallbackValue(FakeRoute());
    registerFallbackValue(const SignupEvent(name: '', email: '', password: ''));
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockNavigatorObserver = MockNavigatorObserver();
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
  });
  Widget createWidgetUnderTest() {
    return BlocProvider<AuthBloc>.value(
      // Provider is OUTSIDE all routes
      value: mockAuthBloc,
      child: MaterialApp(
        home: const SignupPage(),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  group('SignupPage', () {
    testWidgets('renders AuthForm in signup mode', (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthInitial());
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(AuthForm), findsOneWidget);
      final authForm = tester.widget<AuthForm>(find.byType(AuthForm));
      expect(authForm.authMode, AuthMode.signup);
      expect(authForm.isLoading, isFalse);
    });

    testWidgets('shows loading indicator when state is SignupLoadingState', (
      WidgetTester tester,
    ) async {
      when(() => mockAuthBloc.state).thenReturn(const SignupLoadingState());
      await tester.pumpWidget(createWidgetUnderTest());

      final authForm = tester.widget<AuthForm>(find.byType(AuthForm));
      expect(authForm.isLoading, isTrue);
    });

    testWidgets('adds SignupEvent when form is submitted', (
      WidgetTester tester,
    ) async {
      when(() => mockAuthBloc.state).thenReturn(AuthInitial());
      await tester.pumpWidget(createWidgetUnderTest());

      final authForm = tester.widget<AuthForm>(find.byType(AuthForm));
      authForm.onSubmit({
        'name': 'Test User',
        'email': 'test@example.com',
        'password': 'password123',
      });

      verify(
        () => mockAuthBloc.add(
          const SignupEvent(
            name: 'Test User',
            email: 'test@example.com',
            password: 'password123',
          ),
        ),
      ).called(1);
    });

    testWidgets('navigates to LoginPage when switch mode is tapped', (
      WidgetTester tester,
    ) async {
      when(() => mockAuthBloc.state).thenReturn(AuthInitial());
      await tester.pumpWidget(createWidgetUnderTest());

      final authForm = tester.widget<AuthForm>(find.byType(AuthForm));
      authForm.onSwitchMode();
      await tester.pumpAndSettle();

      verify(() => mockNavigatorObserver.didPush(any(), any()));
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets(
      'shows success SnackBar and navigates to LoginPage on SignedupState',
      (WidgetTester tester) async {
        whenListen(
          mockAuthBloc,
          Stream.fromIterable([AuthInitial(), const SignedupState()]),
          initialState: AuthInitial(),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump(); // First pump for initial state
        await tester
            .pump(); // Second pump for the listener to react to SignedupState

        expect(find.text('Signup successful! Please log in.'), findsOneWidget);

        await tester.pumpAndSettle(); // Wait for navigation to complete

        verify(() => mockNavigatorObserver.didPush(any(), any()));
        expect(find.byType(LoginPage), findsOneWidget);
      },
    );

    testWidgets('shows error SnackBar on SignupFailedState', (
      WidgetTester tester,
    ) async {
      whenListen(
        mockAuthBloc,
        Stream.fromIterable([
          AuthInitial(),
          const SignupFailedState('Signup failed'),
        ]),
        initialState: AuthInitial(),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Let bloc listener react
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Signup failed'), findsOneWidget);
    });
  });
}
