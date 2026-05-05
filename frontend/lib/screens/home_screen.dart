import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../widgets/analysis_card.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const AnalysisCard(),
            const SizedBox(height: 40),
            _buildScanButton(),
            const SizedBox(height: 40),
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

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,
      title: Text('SKINLENS', style: AppTextStyles.logoStyle),
      leading: const Icon(Icons.menu, color: AppColors.ink),
      actions: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text('GİRİŞ YAP', style: AppTextStyles.monoLabel.copyWith(color: AppColors.ink)),
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
        _actionItem(Icons.biotech, "İçindekiler"),
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
      mainAxisAlignment: MainAxisAlignment.center,
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