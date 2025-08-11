import 'package:flutter/material.dart';

Color primary() {
  return const Color.fromARGB(255, 63, 81, 243);
}

Color white() {
  return const Color.fromARGB(255, 255, 255, 255);
}

Color voiceMessage() {
  return const Color.fromARGB(255, 116, 73, 240);
}

Color bg() {
  return const Color.fromARGB(255, 73, 140, 240);
}

Gradient gradientPrimary() {
  return const LinearGradient(
    colors: [
      Color.fromARGB(155, 63, 81, 243),
      Color.fromARGB(255, 63, 81, 243),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

Color black() {
  return const Color.fromARGB(255, 0, 0, 0);
}

Color lightGrey() {
  return const Color.fromARGB(255, 250, 250, 250);
}

Color grey() {
  return const Color.fromARGB(255, 136, 136, 136);
}

Color darkGrey() {
  return const Color.fromARGB(255, 111, 111, 111);
}
