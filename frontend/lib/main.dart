import 'package:flutter/material.dart';

// --- 🎨 RENK SİSTEMİ (Design System Rules referanslı) ---
class SkinLensColors {
  static const Color canvas = Color(0xFFF5F0E8);    // Ana arka plan
  static const Color warmWhite = Color(0xFFFAF7F2); // Kart/Panel
  static const Color ink = Color(0xFF2C2416);       // Koyu kahve metin
  static const Color inkSoft = Color(0xFF5C4F3A);   // İkincil metin
  static const Color olive = Color(0xFF6B6B45);     // Vurgu rengi[cite: 1]
  static const Color sand = Color(0xFFD4C4A0);      // Kenarlıklar[cite: 1]
  static const Color terracotta = Color(0xFFB85C38); // Dikkat elemanı[cite: 1]
}

void main() {
  runApp(const SkinLensApp());
}

class SkinLensApp extends StatelessWidget {
  const SkinLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkinLens',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: SkinLensColors.canvas,
        // Tipografi: Serif hissi için default fontları ezebiliriz[cite: 1]
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: SkinLensColors.ink,
            fontSize: 40,
            fontWeight: FontWeight.w300, // Lüks minimalizm[cite: 1]
            letterSpacing: -1.0,
          ),
          bodyMedium: TextStyle(color: SkinLensColors.inkSoft, fontSize: 16),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. ÜST BANNER (Resore stili koyu şerit)[cite: 1]
              Container(
                width: double.infinity,
                color: const Color(0xFF1C1A14),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: const Text(
                  "PURE · ORGANIC · AUTHENTIC",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: SkinLensColors.canvas,
                    fontSize: 10,
                    letterSpacing: 2.0,
                  ),
                ),
              ),

              // 2. HERO BÖLÜMÜ (Asimetrik Yerleşim)[cite: 1]
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "01 — ANALİZ",
                      style: TextStyle(
                        fontFamily: 'monospace', // Mono hissi[cite: 1]
                        fontSize: 12,
                        color: SkinLensColors.sand,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Cildinizin\nÖzünü\nKeşfedin",
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ],
                ),
              ),

              // 3. HİZMET KARTLARI (Brentano Grid Stili - Kare Köşeler)[cite: 1]
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildEditorialCard(
                      label: "TYPE A",
                      title: "Cilt Analizi",
                      icon: Icons.adjust_rounded,
                    ),
                    _buildEditorialCard(
                      label: "TYPE B",
                      title: "OCR Tarama",
                      icon: Icons.document_scanner_outlined,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              // 4. ANA BUTON (Resore stili kare köşe)[cite: 1]
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: InkWell(
                  onTap: () {},
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: SkinLensColors.ink,
                      border: Border.all(color: SkinLensColors.ink),
                      borderRadius: BorderRadius.zero, // Kare köşeler[cite: 1]
                    ),
                    child: const Center(
                      child: Text(
                        "ŞİMDİ TARAMAYA BAŞLA",
                        style: TextStyle(
                          color: Colors.white,
                          letterSpacing: 3.0,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Brentano ve Resore karışımı kart yapısı[cite: 1]
  Widget _buildEditorialCard({
    required String label,
    required String title,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: SkinLensColors.warmWhite,
          border: Border.all(color: SkinLensColors.sand, width: 0.5),
          borderRadius: BorderRadius.zero, // Kare köşeler vazgeçilmez[cite: 1]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                color: SkinLensColors.terracotta,
              ),
            ),
            const SizedBox(height: 24),
            Icon(icon, size: 30, color: SkinLensColors.ink),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: SkinLensColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}