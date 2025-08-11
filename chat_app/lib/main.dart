import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/colors.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/splash/splash_screen.dart';
import 'features/chat/presentation/bloc/chat_list_bloc.dart';
import 'features/chat/presentation/pages/chat_page.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.sl<ChatListBloc>()),
        BlocProvider(
          create: (context) =>
              di.sl<AuthBloc>()..add(const CheckAuthenticatedEvent()),
        ),
      ],
      child: MaterialApp(
        title: 'My Awesome App',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: white(),
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (previous, current) {
            return current is Authenticated ||
                current is Unauthenticated ||
                current is AuthInitial;
          },
          builder: (context, state) {
            if (state is Authenticated) {
              print('User is authenticated: ${state.user}');
              return const ChatPage();
            } else if (state is Unauthenticated) {
              return const LoginPage();
            } else {
              return const SplashScreen();
            }
          },
        ),
      ),
    );
  }
}
