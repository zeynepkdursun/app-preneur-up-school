import 'package:flutter/material.dart';
import '../core/constants.dart';

class AnalysisCard extends StatelessWidget {
  const AnalysisCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.sand),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CİLT ANALİZİ', style: AppTextStyles.monoLabel.copyWith(color: AppColors.sage)),
                const SizedBox(height: 4),
                Text('Cilt Profilini Belirle', style: AppTextStyles.sectionTitle),
                const Text('Hassas, Yağlı, Karma vb. seçin', 
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.sage),
        ],
      ),
    );
  }
}