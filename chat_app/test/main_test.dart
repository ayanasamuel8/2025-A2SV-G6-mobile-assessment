import 'package:chat_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/features/auth/presentation/pages/home_page.dart';
import 'package:chat_app/features/auth/presentation/pages/login_page.dart';
import 'package:chat_app/features/auth/presentation/pages/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock AuthBloc
class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUpAll(() {
    registerFallbackValue(AuthInitial());
    registerFallbackValue(const LoginState());
    registerFallbackValue(const AuthenticatedState());
    registerFallbackValue(const CheckAuthenticatedEvent());
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.close()).thenAnswer((_) async {});
  });

  tearDown(() {
    mockAuthBloc.close();
  });

  Widget createWidgetUnderTest() {
    return BlocProvider<AuthBloc>.value(
      value: mockAuthBloc,
      child: MaterialApp(
        title: 'My Awesome App',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthenticatedState) {
              return const HomePage();
            } else if (state is LoginState) {
              return const LoginPage();
            } else if (state is AuthInitial) {
              return const SplashScreen();
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  testWidgets('renders SplashScreen when state is AuthInitial', (
    WidgetTester tester,
  ) async {
    // Arrange
    when(() => mockAuthBloc.state).thenReturn(AuthInitial());
    when(
      () => mockAuthBloc.stream,
    ).thenAnswer((_) => Stream.fromIterable([AuthInitial()]));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    // Assert
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);
    expect(find.byType(LoginPage), findsNothing);
  });

  testWidgets('renders LoginPage when state is LoginState', (
    WidgetTester tester,
  ) async {
    // Arrange
    when(() => mockAuthBloc.state).thenReturn(const LoginState());
    when(
      () => mockAuthBloc.stream,
    ).thenAnswer((_) => Stream.fromIterable([const LoginState()]));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    // Assert
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);
    expect(find.byType(SplashScreen), findsNothing);
  });

  testWidgets('renders HomePage when state is AuthenticatedState', (
    WidgetTester tester,
  ) async {
    // Arrange
    when(() => mockAuthBloc.state).thenReturn(const AuthenticatedState());
    when(
      () => mockAuthBloc.stream,
    ).thenAnswer((_) => Stream.fromIterable([const AuthenticatedState()]));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    // Assert
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(LoginPage), findsNothing);
  });

  testWidgets('navigates from SplashScreen to HomePage when state changes', (
    WidgetTester tester,
  ) async {
    // Arrange
    when(() => mockAuthBloc.state).thenReturn(AuthInitial());
    when(() => mockAuthBloc.stream).thenAnswer(
      (_) => Stream.fromIterable([AuthInitial(), const AuthenticatedState()]),
    );

    // Act
    await tester.pumpWidget(createWidgetUnderTest());

    // Assert initial state
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);

    // Act again after state change
    await tester.pump();

    // Assert final state
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(SplashScreen), findsNothing);
  });

  testWidgets('navigates from SplashScreen to LoginPage when state changes', (
    WidgetTester tester,
  ) async {
    // Arrange
    when(() => mockAuthBloc.state).thenReturn(AuthInitial());
    when(() => mockAuthBloc.stream).thenAnswer(
      (_) => Stream.fromIterable([AuthInitial(), const LoginState()]),
    );

    // Act
    await tester.pumpWidget(createWidgetUnderTest());

    // Assert initial state
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);

    // Act again after state change
    await tester.pump();

    // Assert final state
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(SplashScreen), findsNothing);
  });
}
