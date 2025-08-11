import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/styles.dart';

class EcomLogoWidget extends StatelessWidget {
  final bool isBordered;
  final double size;
  const EcomLogoWidget({super.key, this.isBordered = false, this.size = 96});

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: IntrinsicHeight(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: isBordered ? Border.all(width: 1, color: primary()) : null,
            color: white(),
          ),
          alignment: Alignment.center,
          child: Text('ECOM', style: logo(size)),
        ),
      ),
    );
  }
}
