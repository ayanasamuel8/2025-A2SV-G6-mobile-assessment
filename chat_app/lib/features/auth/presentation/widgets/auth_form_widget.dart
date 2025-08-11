import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/styles.dart';
import 'custom_button.dart';
import 'ecom_logo_widget.dart';
import 'text_field_widget.dart';

enum AuthMode { login, signup }

class AuthForm extends StatefulWidget {
  const AuthForm({
    super.key,
    required this.authMode,
    required this.onSwitchMode,
    required this.onSubmit,
    this.isLoading = false,
  });

  final AuthMode authMode;
  final VoidCallback onSwitchMode;
  final void Function(Map<String, String> formData) onSubmit;
  final bool isLoading;

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  bool _termsAccepted = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _submitForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    if (widget.authMode == AuthMode.signup && !_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms and conditions to sign up.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _formKey.currentState?.save();
    final formData = {
      'email': _emailController.text.trim(),
      'password': _passwordController.text.trim(),
    };
    if (widget.authMode == AuthMode.signup) {
      formData['name'] = _nameController.text.trim();
      formData['confirmPassword'] = _confirmPasswordController.text.trim();
    }
    widget.onSubmit(formData);
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = widget.authMode == AuthMode.login;
    final title = isLogin ? 'Sign into your account' : 'Create your account';
    final buttonText = isLogin ? 'SIGN IN' : 'SIGN UP';
    final bottomText = isLogin ? "Don't have an account?" : 'Have an account?';
    final switchText = isLogin ? 'SIGN UP' : 'SIGN IN';

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),
                          const EcomLogoWidget(size: 48, isBordered: true),
                          const SizedBox(height: 30),
                          Text(title, style: h1().copyWith(color: black())),
                          if (!isLogin)
                            CustomTextField(
                              controller: _nameController,
                              label: 'Name',
                              hint: 'ex: Jon Smith',
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your name.';
                                }
                                return null;
                              },
                            ),
                          CustomTextField(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'ex: jon.smith@email.com',
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@') ||
                                  !value.contains('.')) {
                                return 'Please enter a valid email address.';
                              }
                              return null;
                            },
                          ),
                          CustomTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: '*********',
                            isPassword: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Password must be at least 6 characters long.';
                              }
                              return null;
                            },
                          ),
                          if (!isLogin)
                            CustomTextField(
                              controller: _confirmPasswordController,
                              label: 'Confirm Password',
                              hint: '*********',
                              isPassword: true,
                              validator: (value) {
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match.';
                                }
                                return null;
                              },
                            ),
                          if (!isLogin) _buildTermsAndPolicyCheckbox(),
                          const SizedBox(height: 20),
                          CustomButton(
                            label: buttonText,
                            isLoading: widget.isLoading,
                            onPressed: _submitForm,
                          ),
                          const Spacer(),
                          _buildBottomText(context, bottomText, switchText),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTermsAndPolicyCheckbox() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Checkbox(
            value: _termsAccepted,
            onChanged: (value) {
              setState(() {
                _termsAccepted = value ?? false;
              });
            },
            activeColor: primary(),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: 'I understood the ', style: h5()),
                  TextSpan(
                    text: 'terms & policy.',
                    style: h5().copyWith(color: primary()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomText(
    BuildContext context,
    String text,
    String switchText,
  ) {
    return RichText(
      key: const Key('auth_form_bottom_text'),
      text: TextSpan(
        children: [
          TextSpan(text: text, style: h3()),
          TextSpan(
            recognizer: TapGestureRecognizer()..onTap = widget.onSwitchMode,
            text: switchText,
            style: h3().copyWith(color: primary()),
          ),
        ],
      ),
    );
  }
}
