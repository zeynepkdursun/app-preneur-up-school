import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // HTML'deki yeni renk tokenları mevcut isimlere eşlendi
  static const Color ink = Color(0xFF1B3022);          // primary (Derin Orman Yeşili)
  static const Color inkSoft = Color(0xFF5C4F3A);
  static const Color sand = Color(0xFF7C5730);         // warm-bronze (Sıcak Bronz)
  static const Color sage = Color(0xFF4D6453);         // surface-tint (Muted Yeşil)
  static const Color warmWhite = Color(0xFFF8F3ED);    // surface-container-low (Krem)
  static const Color background = Color(0xFFFEF9F2);   // background (Kemik Rengi)
  static const Color terracotta = Color(0xFFBA1A1A);   // error (Kiremit Kırmızısı)
  static const Color textMuted = Color(0xFF434843);    // on-surface-variant (Gri-Yeşil)
  static const Color surfaceContainer = Color(0xFFF2EDEA);
  static const Color outlineVariant = Color(0xFFCEC5BA);
  
  // Overlay ve Blur için
  static Color barrierColor = const Color(0xFF1B3022).withOpacity(0.2);
}

class AppTextStyles {
  static TextStyle get logoStyle => GoogleFonts.notoSerif(
        color: AppColors.ink,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        letterSpacing: 4.0,
      );

  static TextStyle get sectionTitle => GoogleFonts.notoSerif(
        fontSize: 22, // Biraz daha belirginleştirildi
        fontWeight: FontWeight.w500,
        color: AppColors.ink,
        letterSpacing: -0.5,
      );

  static TextStyle get monoLabel => GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: AppColors.ink,
      );

static final TextStyle bodyMd = GoogleFonts.manrope(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.5,
  );
}