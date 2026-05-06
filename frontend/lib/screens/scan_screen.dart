import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../widgets/scan_overlay.dart';
import 'analysis_result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool isIngredientsSelected = true; // Üstteki seçim için state

@override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // AppColors.ink yerine okunabilirlik için white
          onPressed: () => Navigator.pop(context),
        ),
        // Title kısmını dikey bir kolona ayırdık: Üstte Analiz Butonu, Altta Seçenekler
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. ANALİZ ET BUTONU (Sayfaya yönlendiren kısım)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AnalysisResultScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.ink.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      "ANALİZ ET",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // 2. İÇERİK / BARKOD SEÇİMİ
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSegment("İÇERİK", isIngredientsSelected, () {
                    setState(() => isIngredientsSelected = true);
                  }),
                  _buildSegment("BARKOD", !isIngredientsSelected, () {
                    setState(() => isIngredientsSelected = false);
                  }),
                ],
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Arka Plan
          Positioned.fill(
            child: Container(
              color: Colors.black87,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_camera_front_outlined,
                    size: 80,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Kamera hazırlanıyor...",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Tarama Alanı (Overlay)
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.height * 0.45,
              child: const ScanOverlay(),
            ),
          ),

          // Alt Kontroller
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomUI(),
          ),
        ],
      ),
    );
  }

  Widget _buildSegment(String title, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomUI() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 50),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.9), // Hafif şeffaf soft arka plan
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _circleIcon(Icons.flash_off),
              _shutterButton(),
              _circleIcon(Icons.photo_library),
            ],
          ),
          const SizedBox(height: 24),
          _tipBox(),
        ],
      ),
    );
  }

  Widget _circleIcon(IconData icon) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
    ),
    child: Icon(icon, color: AppColors.primary),
  );

  Widget _shutterButton() => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: AppColors.secondary, width: 4),
    ),
    child: const CircleAvatar(
      radius: 35,
      backgroundColor: AppColors.primary,
    ),
  );

  Widget _tipBox() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Row(
      children: [
        Icon(Icons.lightbulb, color: AppColors.secondary, size: 20),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            "İpucu: Yazıların net göründüğünden emin olun.",
            style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
          ),
        ),
      ],
    ),
  );
}