import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../data/user_data_store.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_text.dart';
import 'sloka_screen.dart';

class ChapterScreen extends StatelessWidget {
  const ChapterScreen({super.key, required this.chapter})
      : _embedded = false;

  const ChapterScreen.embedded({super.key, required this.chapter})
      : _embedded = true;

  final Chapter chapter;
  final bool _embedded;

  @override
  Widget build(BuildContext context) {
    final body = ValueListenableBuilder<Set<int>>(
      valueListenable: UserDataStore.instance.bookmarks,
      builder: (_, bookmarks, __) {
        return ListView.builder(
          itemCount: chapter.slokas.length,
          itemBuilder: (context, i) {
            final s = chapter.slokas[i];
            final bookmarked = bookmarks.contains(s.id);
            return _SlokaRow(sloka: s, bookmarked: bookmarked);
          },
        );
      },
    );

    if (_embedded) {
      return Container(color: AppColors.white, child: body);
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(chapter.name, style: AppText.navTitle()),
            Text(
              chapter.subtitle.split(' · ').first,
              style: AppText.caption().copyWith(
                color: AppColors.white.withValues(alpha: 0.85),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
      body: body,
    );
  }
}

class _SlokaRow extends StatelessWidget {
  const _SlokaRow({required this.sloka, required this.bookmarked});
  final Sloka sloka;
  final bool bookmarked;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => SlokaScreen(slokaId: sloka.id),
      )),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.gray4)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              child: Text(sloka.name,
                  style: AppText.label().copyWith(
                    color: AppColors.red1,
                    fontSize: 14,
                  )),
            ),
            Expanded(
              child: Text(
                sloka.transcription.split('\n').first,
                style: AppText.body(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              bookmarked ? Icons.bookmark : Icons.chevron_right,
              size: 18,
              color: bookmarked ? AppColors.red1 : AppColors.gray3,
            ),
          ],
        ),
      ),
    );
  }
}
