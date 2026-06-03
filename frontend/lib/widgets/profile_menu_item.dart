import 'package:flutter/material.dart';
import '../core/constants.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailingText;
  final VoidCallback onTap;
  final bool isDestructive;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailingText,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color contentColor = isDestructive ? AppColors.terracotta : AppColors.ink;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDestructive 
                ? AppColors.terracotta.withOpacity(0.2) 
                : AppColors.sand.withOpacity(0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isDestructive 
              ? AppColors.terracotta.withOpacity(0.02) 
              : AppColors.warmWhite.withOpacity(0.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: contentColor, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title.toUpperCase(),
                style: AppTextStyles.monoLabel.copyWith(
                  color: contentColor,
                  fontSize: 13,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            if (trailingText != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  trailingText!.toUpperCase(),
                  style: AppTextStyles.monoLabel.copyWith(
                    color: AppColors.sage,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Icon(
              Icons.chevron_right,
              color: contentColor.withOpacity(0.6),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}