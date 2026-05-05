import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color ink = Color(0xFF2C2416);
  static const Color sand = Color(0xFFE2D6C1);
  static const Color sage = Color(0xFF8B9E7A);
  static const Color warmWhite = Color(0xFFFAF7F2);
  static const Color background = Color(0xFFFDFBF7);
  static const Color terracotta = Color(0xFFB85C38);
  static const Color textMuted = Color(0xFF9C8E7A);
}

class AppTextStyles {
  static TextStyle get logoStyle => GoogleFonts.cormorantGaramond(
        color: AppColors.ink,
        fontSize: 20,
        fontWeight: FontWeight.w400,
        letterSpacing: 2.5,
      );

  static TextStyle get sectionTitle => GoogleFonts.cormorantGaramond(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      );

  static TextStyle get monoLabel => GoogleFonts.dmMono(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
      );
}