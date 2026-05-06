import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';

class ScanOverlay extends StatelessWidget {
  const ScanOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dört Köşe Çerçevesi (Kırmızı çizgi yok, sadece hafif bir çerçeve)
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        
        // Sabit İçerik Etiketleri (OCR Simülasyonu)
       /* _buildTag(top: 80, left: 20, text: "AQUA"),
        _buildTag(top: 140, right: 30, text: "GLYCERIN"),
        _buildTag(bottom: 100, left: 40, text: "NIACINAMIDE"),
        _buildTag(bottom: 60, right: 20, text: "PHENOXYETHANOL"),*/
      ],
    );
  }

  Widget _buildTag({double? top, double? bottom, double? left, double? right, required String text}) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.secondary.withOpacity(0.8),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text,
          style: GoogleFonts.manrope(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}