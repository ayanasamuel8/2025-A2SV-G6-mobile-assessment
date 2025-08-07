import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/styles.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final bool isPassword;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.isPassword = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: h3()),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            obscureText: isPassword,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              hintStyle: h4(),
              fillColor: lightGrey(),
              filled: true,
            ),
          ),
        ],
      ),
    );
  }
}
