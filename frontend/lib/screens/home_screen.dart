import 'package:flutter/material.dart';
import 'dart:ui';
import '../core/constants.dart';
import '../widgets/analysis_card.dart';
import '../widgets/product_card.dart';
import '../widgets/auth_bottom_sheet.dart';
import '../screens/skin_type_screen.dart';
import '../screens/scan_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  // Bir butona basıldığında çağırın:
void _showAuthSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // Barrier color'ı tamamen şeffaf yapıyoruz çünkü bulanıklığı BackdropFilter ile vereceğiz
      barrierColor: Colors.transparent, 
      builder: (context) {
        return Stack(
          children: [
            // Tüm ekranı kaplayan bulanıklık katmanı
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(context), // Boşluğa tıklayınca kapatmak için
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                  child: Container(
                    // Görseldeki o hafif koyu/puslu hava için çok düşük opacity
                    color: AppColors.ink.withOpacity(0.01), 
                  ),
                ),
              ),
            ),
            // Senin orijinal BottomSheet içeriğin
            const AuthBottomSheet(),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 2. ADIM: AnalysisCard'ı tıklanabilir yapıyoruz ve yönlendirme ekliyoruz
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SkinTypeScreen()),
                );
              },
              child: const AnalysisCard(),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScanScreen()),
                );
              },
              child: _buildScanButton(),
            ),
            _buildQuickActions(),
            const SizedBox(height: 40),
            _buildRecentHeader(),
            const SizedBox(height: 16),
            const ProductCard(
              brand: "LUMINESCE",
              name: "Hydrating Silk Serum",
              score: "%94",
              scoreColor: AppColors.sage,
              imageUrl: "https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=200",
            ),
            const ProductCard(
              brand: "CORE BOTANICS",
              name: "Reset Night Balm",
              score: "%82",
              scoreColor: AppColors.terracotta,
              imageUrl: "https://images.unsplash.com/photo-1601049541289-9b1b7bbbfe19?w=200",
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

AppBar _buildAppBar(BuildContext context) { // BuildContext ekledik
  return AppBar(
    backgroundColor: AppColors.background,
    elevation: 0,
    centerTitle: false,
    title: Text('SKINLENS', style: AppTextStyles.logoStyle),
    //leading: const Icon(Icons.menu, color: AppColors.ink),
    actions: [
      Center(
        child: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: InkWell( // Tıklanabilirlik eklendi
            onTap: () => _showAuthSheet(context),
            child: Text(
              'GİRİŞ YAP', 
              style: AppTextStyles.monoLabel.copyWith(color: AppColors.ink)
            ),
          ),
        ),
      ),
    ],
    shape: const Border(bottom: BorderSide(color: AppColors.sand, width: 0.5)),
  );
}

  Widget _buildScanButton() {
    return Column(
      children: [
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            color: AppColors.warmWhite,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.sand, width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.center_focus_weak, size: 48, color: AppColors.sage.withOpacity(0.8)),
              const SizedBox(height: 12),
              Text('TARAMAYI BAŞLAT', style: AppTextStyles.monoLabel),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text('YAPAY ZEKA DESTEKLİ ANALİZ', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        _actionItem(Icons.barcode_reader, "Barkod Oku"),
        const SizedBox(width: 12),
        _actionItem(Icons.biotech, "İçindekileri Oku"),
      ],
    );
  }

  Widget _actionItem(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.sand),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.ink, size: 20),
            const SizedBox(height: 8),
            Text(label.toUpperCase(), style: AppTextStyles.monoLabel),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Son Analizlerin', style: AppTextStyles.sectionTitle),
        Text('TÜMÜNÜ GÖR', style: AppTextStyles.monoLabel.copyWith(color: AppColors.sage, decoration: TextDecoration.underline)),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.background,
      selectedItemColor: AppColors.ink,
      unselectedItemColor: AppColors.textMuted,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: AppTextStyles.monoLabel.copyWith(fontSize: 8),
      unselectedLabelStyle: AppTextStyles.monoLabel.copyWith(fontSize: 8),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ANASAYFA'),
        BottomNavigationBarItem(icon: Icon(Icons.center_focus_weak), label: 'TARAMA'),
        BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), label: 'KAYITLI'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'PROFİL'),
      ],
    );
  }


  
}