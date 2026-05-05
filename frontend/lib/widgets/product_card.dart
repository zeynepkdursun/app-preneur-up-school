import 'package:flutter/material.dart';
import '../core/constants.dart';

class ProductCard extends StatelessWidget {
  final String brand;
  final String name;
  final String score;
  final Color scoreColor;
  final String imageUrl;

  const ProductCard({
    super.key,
    required this.brand,
    required this.name,
    required this.score,
    required this.scoreColor,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sand.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
            child: Image.network(imageUrl, width: 100, height: 100, fit: BoxFit.cover),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(brand, style: AppTextStyles.monoLabel.copyWith(color: AppColors.sage)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: scoreColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(score, style: TextStyle(color: scoreColor, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.ink)),
                  const SizedBox(height: 8),
                  const Text("KURU CİLT • VEGAN", style: TextStyle(fontSize: 8, color: AppColors.textMuted, letterSpacing: 0.5)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}