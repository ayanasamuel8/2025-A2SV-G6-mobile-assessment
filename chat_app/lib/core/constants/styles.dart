import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

TextStyle name() {
  return GoogleFonts.poppins(
    fontWeight: FontWeight.w500,
    fontSize: 36,
    color: white(),
  );
}

TextStyle logo(double size) {
  return GoogleFonts.caveatBrush(
    fontWeight: FontWeight.w400,
    fontSize: size,
    color: primary(),
  );
}

TextStyle h1() {
  return GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    fontSize: 27,
    color: white(),
  );
}

TextStyle h2() {
  return GoogleFonts.getFont(
    'General Sans',
    fontWeight: FontWeight.w500,
    fontSize: 18,
    color: white(),
  );
}

TextStyle h3() {
  return GoogleFonts.poppins(
    fontWeight: FontWeight.w400,
    fontSize: 16,
    color: grey(),
  );
}

TextStyle h4() {
  return GoogleFonts.poppins(
    fontWeight: FontWeight.w400,
    fontSize: 15,
    color: darkGrey(),
  );
}

TextStyle h4Bold() {
  return GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    fontSize: 15,
    color: white(),
  );
}

TextStyle h5() {
  return GoogleFonts.poppins(
    fontWeight: FontWeight.w400,
    fontSize: 12,
    color: black(),
  );
}
