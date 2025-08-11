import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_form_widget.dart';
import 'home_page.dart';
import 'signup_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is LoginFailedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        } else if (state is LoggedinState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login successful!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        }
      },
      child: AuthForm(
        isLoading: context.watch<AuthBloc>().state is LoginLoadingState,
        authMode: AuthMode.login,
        onSwitchMode: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const SignupPage()),
          );
        },
        onSubmit: (formData) {
          final email = formData['email']!;
          final password = formData['password']!;
          context.read<AuthBloc>().add(
            LoginEvent(email: email, password: password),
          );
        },
      ),
    );
  }
}
