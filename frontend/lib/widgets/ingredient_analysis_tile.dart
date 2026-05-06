import 'package:flutter/material.dart';
import '../core/constants.dart';

class IngredientAnalysisTile extends StatelessWidget {
  final String name;
  final String category;
  final IconData icon;
  final Color iconColor;
  final Color? textColor;

  const IngredientAnalysisTile({
    super.key,
    required this.name,
    required this.category,
    required this.icon,
    required this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.secondary.withOpacity(0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontFamily: 'NotoSerif',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
              Text(
                category,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  color: textColor ?? AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Icon(icon, color: iconColor, size: 24),
        ],
      ),
    );
  }
}