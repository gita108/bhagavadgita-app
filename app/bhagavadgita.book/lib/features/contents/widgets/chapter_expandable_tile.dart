import 'package:flutter/material.dart';
import 'package:flutter_versegrid/flutter_versegrid.dart';

import '../../../data/local/app_database.dart';
import '../../../ui/theme/app_colors.dart';
import '../../../ui/theme/app_text.dart';

class ChapterExpandableTile extends StatelessWidget {
  const ChapterExpandableTile({
    super.key,
    required this.chapter,
    required this.slokas,
    required this.isExpanded,
    required this.selectedSlokaId,
    required this.onExpansionChanged,
    required this.onSlokaTap,
  });

  final Chapter chapter;
  final List<Sloka> slokas;
  final bool isExpanded;
  final int? selectedSlokaId;
  final ValueChanged<bool> onExpansionChanged;
  final ValueChanged<Sloka> onSlokaTap;

  static String _slokaChipLabel(Sloka s) {
    return s.name.contains('.') ? s.name.split('.').last : s.position.toString();
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      for (final s in slokas)
        VerseNumberGridItem<Sloka>(
          value: s,
          label: _slokaChipLabel(s),
          semanticsLabel:
              'Chapter ${chapter.position}, verse ${_slokaChipLabel(s)}',
        ),
    ];

    return Column(
      children: [
        ListTile(
          onTap: () => onExpansionChanged(!isExpanded),
          leading: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isExpanded ? AppColors.red1 : AppColors.gray5,
              shape: BoxShape.circle,
            ),
            child: Text(
              chapter.position.toString(),
              style: AppText.label().copyWith(
                color: isExpanded ? AppColors.white : AppColors.gray2,
              ),
            ),
          ),
          title: Text(
            chapter.name,
            style: AppText.body().copyWith(
              fontWeight: isExpanded ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
          trailing: Icon(
            isExpanded ? Icons.expand_less : Icons.expand_more,
            color: AppColors.gray3,
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: VerseNumberGrid<Sloka>(
              items: items,
              columns: 7,
              maxRows: 4,
              spacing: 6,
              runSpacing: 6,
              isSelected: (item) =>
                  selectedSlokaId != null && item.value.id == selectedSlokaId,
              onItemTap: (item) => onSlokaTap(item.value),
              cellBuilder: (context, item, selected, size, onTap) {
                return SizedBox(
                  width: size,
                  height: size,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(size / 2),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected ? AppColors.red1 : AppColors.gray5,
                          border: selected
                              ? null
                              : Border.all(color: AppColors.gray4),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          item.label,
                          style: AppText.label().copyWith(
                            color:
                                selected ? AppColors.white : AppColors.gray1,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
