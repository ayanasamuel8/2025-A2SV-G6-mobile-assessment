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
          if (state is SignupFailedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state is SignedupState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Signup successful! Please log in.'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          }
        },
        child: AuthForm(
          isLoading: context.watch<AuthBloc>().state is SignupLoadingState,
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
            debugPrint('Signup with: $name, $email, $password');
            context.read<AuthBloc>().add(
              SignupEvent(name: name, email: email, password: password),
            );
          },
        ),
      ),
    );
  }
}
