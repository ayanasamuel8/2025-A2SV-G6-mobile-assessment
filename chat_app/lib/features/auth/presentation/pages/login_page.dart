import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_form_widget.dart';
import 'signup_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return AuthForm(
              isLoading: state is AuthLoading,
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
            );
          },
        ),
      ),
    );
  }
}
