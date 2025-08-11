import 'package:bloc_test/bloc_test.dart';
import 'package:chat_app/features/auth/domain/entities/user.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/features/auth/presentation/pages/login_page.dart';
import 'package:chat_app/features/auth/presentation/pages/splash/splash_screen.dart';
import 'package:chat_app/features/chat/presentation/bloc/chat_list_bloc.dart';
import 'package:chat_app/features/chat/presentation/pages/chat_page.dart';
import 'package:chat_app/injection_container.dart' as di;
import 'package:chat_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockChatListBloc extends MockBloc<ChatListEvent, ChatListState>
    implements ChatListBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockChatListBloc mockChatListBloc;

  Future<void> setupMockDependencies() async {
    await di.sl.reset();

    mockAuthBloc = MockAuthBloc();
    mockChatListBloc = MockChatListBloc();

    di.sl.registerFactory<AuthBloc>(() => mockAuthBloc);
    di.sl.registerFactory<ChatListBloc>(() => mockChatListBloc);
  }

  group('MyApp Navigation Logic', () {
    testWidgets('renders SplashScreen when AuthState is AuthInitial', (
      WidgetTester tester,
    ) async {
      // Arrange: Set up dependencies first
      await setupMockDependencies();

      // Arrange: Configure the state of the mock BLoCs
      whenListen(
        mockAuthBloc,
        Stream.fromIterable([AuthInitial()]),
        initialState: AuthInitial(),
      );
      whenListen(
        mockChatListBloc,
        Stream.fromIterable([ChatListInitial()]),
        initialState: ChatListInitial(),
      );

      // Act: Build the MyApp widget
      await tester.pumpWidget(const MyApp());

      // Assert: Verify the correct page is shown
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
      expect(find.byType(ChatPage), findsNothing);
    });

    testWidgets('renders LoginPage when AuthState is Unauthenticated', (
      WidgetTester tester,
    ) async {
      // Arrange
      await setupMockDependencies();

      whenListen(
        mockAuthBloc,
        Stream.fromIterable([Unauthenticated()]),
        initialState: Unauthenticated(),
      );
      whenListen(
        mockChatListBloc,
        Stream.fromIterable([ChatListInitial()]),
        initialState: ChatListInitial(),
      );

      // Act
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('renders ChatPage when AuthState is Authenticated', (
      WidgetTester tester,
    ) async {
      // Arrange
      await setupMockDependencies();

      const tUser = User(id: '1', name: 'Test', email: 'test@test.com');
      whenListen(
        mockAuthBloc,
        Stream.fromIterable([const Authenticated(user: tUser)]),
        initialState: const Authenticated(user: tUser),
      );
      whenListen(
        mockChatListBloc,
        Stream.fromIterable([const ChatListLoaded(chats: [])]),
        initialState: const ChatListLoaded(chats: []),
      );

      // Act
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ChatPage), findsOneWidget);
    });
  });
}
