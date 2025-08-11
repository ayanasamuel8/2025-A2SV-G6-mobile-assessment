import 'package:flutter/material.dart';

import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/styles.dart';
import '../../widgets/ecom_logo_widget.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          key: const Key('splash_screen_main_stack'),
          alignment: Alignment.center,
          children: [
            Image.asset(
              'images/splash_screen_image.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Container(
              key: const Key('gradient_overlay'),
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(gradient: gradientPrimary()),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const EcomLogoWidget(),
                Text('ECOMMERCE APP', style: name()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
