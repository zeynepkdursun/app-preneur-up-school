import 'package:flutter/material.dart';
import '../core/constants.dart';

class SensitivityChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Function(bool?) onChanged;

  const SensitivityChip({super.key, required this.label, required this.isSelected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!isSelected),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.warmWhite,
          border: Border.all(color: AppColors.sand),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24, height: 24,
              child: Checkbox(
                value: isSelected,
                onChanged: onChanged,
                activeColor: AppColors.ink,
                side: const BorderSide(color: AppColors.outlineVariant, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(width: 8),
            Text(label.toUpperCase(), style: const TextStyle(fontSize: 11, letterSpacing: 1.1, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}