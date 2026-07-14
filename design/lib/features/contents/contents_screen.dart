import 'package:flutter/material.dart';

import '../../data/mock_content.dart';
import '../../data/models.dart';
import '../../data/user_data_store.dart';
import '../../features/settings/reader_settings.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_text.dart';
import '../../ui/widgets/page_dots.dart';
import '../bookmarks/bookmarks_screen.dart';
import '../reader/chapter_screen.dart';
import '../search/search_screen.dart';
import '../settings/settings_screen.dart';

class ContentsScreen extends StatelessWidget {
  const ContentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 720;
    if (isTablet) {
      return _TabletContents();
    }
    return Scaffold(
      backgroundColor: AppColors.gray5,
      appBar: AppBar(
        title: const Text('Contents'),
        actions: [
          IconButton(
            tooltip: 'Bookmarks',
            icon: const Icon(Icons.bookmark_border),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BookmarksScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () => SearchScreen.open(context),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ValueListenableBuilder<ReaderSettings>(
        valueListenable: readerSettings,
        builder: (_, s, __) => ListView.builder(
          itemCount: MockContent.chapters.length + (s.quoteOfTheDayEnabled ? 1 : 0),
          itemBuilder: (context, idx) {
            if (s.quoteOfTheDayEnabled && idx == 0) {
              return const QuoteCard(
                quote: MockContent.quoteOfTheDay,
                author: MockContent.quoteAuthor,
              );
            }
            final c = MockContent.chapters[idx - (s.quoteOfTheDayEnabled ? 1 : 0)];
            return ChapterRow(chapter: c);
          },
        ),
      ),
    );
  }
}

class ChapterRow extends StatelessWidget {
  const ChapterRow({super.key, required this.chapter, this.selected = false});

  final Chapter chapter;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ChapterScreen(chapter: chapter),
      )),
      child: Container(
        color: selected ? AppColors.red1.withValues(alpha: 0.06) : null,
        padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
        child: Row(
          children: [
            Container(
              width: 40,
              alignment: Alignment.center,
              child: Text('${chapter.position}',
                  style: AppText.heading().copyWith(
                    color: selected ? AppColors.red1 : AppColors.gray2,
                    fontSize: 22,
                  )),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(chapter.name,
                      style: AppText.body().copyWith(
                        fontWeight: FontWeight.w700,
                        color: selected ? AppColors.red1 : AppColors.gray1,
                      )),
                  const SizedBox(height: 2),
                  Text(chapter.subtitle,
                      style: AppText.caption(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.gray3, size: 22),
          ],
        ),
      ),
    );
  }
}

// Tablet master-detail layout (40/60 split).
class _TabletContents extends StatefulWidget {
  @override
  State<_TabletContents> createState() => _TabletContentsState();
}

class _TabletContentsState extends State<_TabletContents> {
  Chapter _selected = MockContent.chapters[1]; // Chapter 2

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray5,
      appBar: AppBar(
        title: Row(
          children: [
            const SizedBox(width: 4),
            const Text('Contents'),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selected.name, style: AppText.navTitle()),
                  Text(_selected.subtitle.split(' · ').first,
                      style: AppText.caption()
                          .copyWith(color: AppColors.white.withValues(alpha: 0.85))),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => SearchScreen.open(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // Master pane
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(right: BorderSide(color: AppColors.gray4)),
              ),
              child: ValueListenableBuilder<ReaderSettings>(
                valueListenable: readerSettings,
                builder: (_, s, __) => ListView.builder(
                  itemCount: MockContent.chapters.length +
                      (s.quoteOfTheDayEnabled ? 1 : 0),
                  itemBuilder: (context, idx) {
                    if (s.quoteOfTheDayEnabled && idx == 0) {
                      return const QuoteCard(
                        quote: MockContent.quoteOfTheDay,
                        author: MockContent.quoteAuthor,
                      );
                    }
                    final c = MockContent.chapters[
                        idx - (s.quoteOfTheDayEnabled ? 1 : 0)];
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _selected = c),
                      child: ChapterRow(
                        chapter: c,
                        selected: c.id == _selected.id,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          // Detail pane — chapter contents
          Expanded(
            child: ChapterScreen.embedded(chapter: _selected),
          ),
        ],
      ),
    );
  }
}
