import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyle {
  static TextStyle headingXL = GoogleFonts.lato(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    letterSpacing: 3.5,
  );

  static TextStyle heading = GoogleFonts.montserrat(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    letterSpacing: -0.35,
  );

  static TextStyle subHeading = GoogleFonts.lato(
    fontSize: 18,
    color: Colors.black87,
  );

  static TextStyle subTitle = GoogleFonts.lato(
    fontSize: 18,
    color: Colors.black87,
  );

  static TextStyle body = GoogleFonts.lato(fontSize: 14, color: Colors.black87);

  static TextStyle bodyLight = GoogleFonts.lato(
    fontSize: 14,
    fontWeight: FontWeight.w300,
    color: Colors.black54,
  );

  static TextStyle label = GoogleFonts.lato(
    fontSize: 12,
    color: Colors.grey[700],
  );

  static TextStyle label2 = GoogleFonts.montserrat(
    fontSize: 12,
    color: Colors.grey[700],
    fontWeight: FontWeight.bold,
  );

  static TextStyle buttonBold = GoogleFonts.lato(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static TextStyle bottomNavLabel = GoogleFonts.lato(fontSize: 12);
}
