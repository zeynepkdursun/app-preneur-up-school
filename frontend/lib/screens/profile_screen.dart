import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../widgets/profile_menu_item.dart';
import 'skin_type_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserHeader(),
            const SizedBox(height: 32),
            _buildSectionTitle("HESAP VE BAKIM AYARLARI"),
            const SizedBox(height: 12),
            _buildMenuGroup(context),
            const SizedBox(height: 40),
            _buildLegalDisclaimer(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.ink),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        "PROFİLİM",
        style: TextStyle(
          color: AppColors.ink,
          fontSize: 12,
          letterSpacing: 2,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: Text(
              "SKINLENS",
              style: AppTextStyles.logoStyle.copyWith(fontSize: 16),
            ),
          ),
        ),
      ],
      shape: const Border(
        bottom: BorderSide(color: AppColors.sand, width: 0.5),
      ),
    );
  }

  Widget _buildUserHeader() {
    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.warmWhite,
            border: Border.all(color: AppColors.sand, width: 1.5),
          ),
          child: const Center(
            child: Icon(
              Icons.person_outline,
              size: 36,
              color: AppColors.ink,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Cilt Analiz Profili",
                style: AppTextStyles.monoLabel.copyWith(
                  color: AppColors.sand,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Kullanıcı", 
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 24),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.monoLabel.copyWith(
        color: AppColors.textMuted,
        fontSize: 11,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildMenuGroup(BuildContext context) {
    return Column(
      children: [
        ProfileMenuItem(
          icon: Icons.bubble_chart_outlined,
          title: "Cilt Profilini Güncelle",
          trailingText: "Karma", // TODO: Dinamik hale getirilecek
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SkinTypeScreen()),
            );
          },
        ),
        const SizedBox(height: 12),
        ProfileMenuItem(
          icon: Icons.bookmark_border_rounded,
          title: "Dijital Rafım (Favoriler)",
          onTap: () {
            // PRD 4.3 - GET /api/v1/favorites sayfasına yönlendirme yapılacak
          },
        ),
        const SizedBox(height: 12),
        ProfileMenuItem(
          icon: Icons.shield_moon_outlined,
          title: "Hassasiyet Bildirimleri",
          onTap: () {},
        ),
        const SizedBox(height: 24),
        const Divider(color: AppColors.sand, thickness: 0.5),
        const SizedBox(height: 12),
        ProfileMenuItem(
          icon: Icons.logout_rounded,
          title: "Oturumu Kapat",
          isDestructive: true,
          onTap: () {
            // TODO: AuthManager.logout() işlemi tetiklenecek
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      ],
    );
  }

  Widget _buildLegalDisclaimer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.textMuted,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Tıbbi tavsiye değildir, yapay zeka destekli bilgilendirmedir.", // PRD Sec 5 Guardrail
              style: AppTextStyles.bodyMd.copyWith(
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}