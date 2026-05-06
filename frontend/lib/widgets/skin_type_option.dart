import 'package:flutter/material.dart';
import '../core/constants.dart';

class SkinTypeOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const SkinTypeOption({super.key, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceContainer : AppColors.warmWhite,
          border: Border.all(color: isSelected ? AppColors.ink : AppColors.sand),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label.toUpperCase(), 
              style: const TextStyle(letterSpacing: 1.2, fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.ink)),
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? AppColors.ink : AppColors.outlineVariant, width: 1.5),
              ),
              child: Center(
                child: AnimatedScale(
                  scale: isSelected ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(width: 12, height: 12, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.ink)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}