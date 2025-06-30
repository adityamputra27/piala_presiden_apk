import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xffF9F9F9);
  static const Color secondary = Color(0xff000000);
  static const Color danger = Color(0xFFB92F1F);
  static const Color success = Color(0xFF2E7D32);
  static const Color background = Color(0xFFF4F6F8);
  static const Color card = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF1F1F1F);
  static const Color mutedText = Color(0xFF888888);
  static const Color border = Color(0xFFDDDDDD);
  static const Color shadow = Color(0x1A000000);
  static const Color white = Color(0xffffffff);
  static const Color black = Color(0xff000000);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF002366), Color(0xFF003399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
