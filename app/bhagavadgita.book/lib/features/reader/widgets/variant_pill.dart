import 'package:flutter/material.dart';

import '../../../ui/theme/app_colors.dart';
import '../../../ui/theme/app_text.dart';

class VariantPill extends StatelessWidget {
  const VariantPill({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.red1 : AppColors.gray5,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? AppColors.red1 : AppColors.gray3,
          ),
        ),
        child: Text(
          label,
          style: AppText.caption().copyWith(
            fontWeight: FontWeight.w700,
            color: isSelected ? AppColors.white : AppColors.gray1,
          ),
        ),
      ),
    );
  }
}

class VariantPillRow extends StatelessWidget {
  const VariantPillRow({
    super.key,
    required this.variants,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<String> variants;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < variants.length; i++)
          VariantPill(
            label: variants[i],
            isSelected: i == selectedIndex,
            onTap: () => onSelect(i),
          ),
      ],
    );
  }
}
