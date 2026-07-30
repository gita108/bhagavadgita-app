import 'package:flutter/material.dart';
import 'package:flutter_versegrid/flutter_versegrid.dart';

import '../../../data/local/app_database.dart';
import '../../../data/local/user_data_repository.dart';
import '../../../l10n/l10n.dart';
import '../../../ui/theme/app_colors.dart';
import '../../../ui/theme/app_text.dart';

/// One chapter row: caption "Chapter N" / title / "N shlokas" caption, with
/// a trailing chevron that rotates on expand, and (when expanded) a 7-column
/// grid of verse-number circles — bookmarked verses show a small badge.
class ChapterExpandableTile extends StatelessWidget {
  const ChapterExpandableTile({
    super.key,
    required this.chapter,
    required this.slokas,
    required this.isExpanded,
    required this.selectedSlokaId,
    required this.onExpansionChanged,
    required this.onSlokaTap,
    required this.userData,
  });

  final Chapter chapter;
  final List<Sloka> slokas;
  final bool isExpanded;
  final int? selectedSlokaId;
  final ValueChanged<bool> onExpansionChanged;
  final ValueChanged<Sloka> onSlokaTap;
  final UserDataRepository userData;

  static String _slokaChipLabel(Sloka s) {
    return s.name.contains('.')
        ? s.name.split('.').last
        : s.position.toString();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
        InkWell(
          onTap: () => onExpansionChanged(!isExpanded),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 11, 16, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.chapterLabel(chapter.position),
                        style: AppText.caption(),
                      ),
                      const SizedBox(height: 2),
                      Text(chapter.name, style: AppText.body()),
                      const SizedBox(height: 1),
                      Text(
                        l10n.shlokaCount(slokas.length),
                        style: AppText.caption().copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Image.asset(
                      'assets/icons/arrow_show.png',
                      width: 12,
                      height: 12,
                      color: AppColors.gray3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Container(
            width: double.infinity,
            color: AppColors.gray5,
            padding: const EdgeInsets.all(3),
            child: VerseNumberGrid<Sloka>(
              items: items,
              columns: 7,
              maxRows: 10,
              spacing: 1,
              runSpacing: 1,
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
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selected
                                  ? AppColors.red1
                                  : AppColors.gray5,
                              border: selected
                                  ? null
                                  : Border.all(color: AppColors.gray4),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              item.label,
                              style: AppText.label().copyWith(
                                color: selected
                                    ? AppColors.white
                                    : AppColors.gray1,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Positioned(
                            top: -2,
                            right: -2,
                            child: StreamBuilder<bool>(
                              stream: userData.watchBookmark(item.value.id),
                              builder: (context, snap) {
                                if (snap.data != true) {
                                  return const SizedBox.shrink();
                                }
                                return Image.asset(
                                  'assets/icons/ic_bookmark_small.png',
                                  width: 12,
                                  height: 12,
                                );
                              },
                            ),
                          ),
                        ],
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
