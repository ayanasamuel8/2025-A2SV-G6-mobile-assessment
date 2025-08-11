import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_form_widget.dart';
import 'login_page.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

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
          } else if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return AuthForm(
              isLoading: state is AuthLoading,
              authMode: AuthMode.signup,
              onSwitchMode: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              onSubmit: (formData) {
                final name = formData['name']!;
                final email = formData['email']!;
                final password = formData['password']!;
                final confirmPassword = formData['confirmPassword']!;
                context.read<AuthBloc>().add(
                  SignupEvent(
                    name: name,
                    email: email,
                    password: password,
                    confirmPassword: confirmPassword,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
