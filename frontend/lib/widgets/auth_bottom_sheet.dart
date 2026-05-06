import 'package:flutter/material.dart';
import '../core/constants.dart';


class AuthBottomSheet extends StatelessWidget {
  const AuthBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          // Bu metod çağrıldığı için decoration const OLAMAZ
          color: AppColors.ink.withOpacity(0.1), 
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5), // Gölgeyi yukarı doğru verir
          ),
        ],
      ),
      
      child: Column(
        mainAxisSize: MainAxisSize.min, // İçerik kadar yer kapla
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.sand,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),
          
          // Header Section
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("SkinLens'e Katıl", style: AppTextStyles.sectionTitle.copyWith(fontSize: 28)),
                const SizedBox(height: 12),
                Text(
                  "Cilt analizlerinizi kaydedin, zaman içindeki değişimleri takip edin ve size özel bakım önerilerine her an ulaşın.",
                  style: AppTextStyles.bodyMd,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Google Button (Primary Action)
          _buildActionButton(
            label: "GOOGLE İLE DEVAM ET",
            backgroundColor: AppColors.sand,
            textColor: Colors.white,
            icon: Icons.g_mobiledata_rounded,
            onPressed: () {},
          ),
          const SizedBox(height: 12),

          // Email Button (Secondary Action)
          _buildActionButton(
            label: "E-POSTA İLE KAYIT OL",
            backgroundColor: Colors.transparent,
            textColor: AppColors.ink,
            isOutlined: true,
            onPressed: () {},
          ),
          
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFC3C8C1), thickness: 0.5),
          const SizedBox(height: 16),

          // Footer Link
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Zaten bir hesabın var mı?", style: AppTextStyles.bodyMd),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "Giriş Yap",
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.sand,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
    IconData? icon,
    bool isOutlined = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: isOutlined ? BorderSide(color: AppColors.ink.withOpacity(0.3)) : BorderSide.none,
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor, size: 28),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: AppTextStyles.monoLabel.copyWith(color: textColor, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}