import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_text.dart';
import '../../data/local/app_database.dart';
import '../contents/widgets/chapter_expandable_tile.dart';
import '../reader/sloka_screen.dart';
import '../search/search_route.dart';
import '../search/search_screen.dart';
import '../settings/settings_screen.dart';
import '../shared/widgets/quote_card.dart';

class TabletContentsChapterScaffold extends StatefulWidget {
  const TabletContentsChapterScaffold({super.key, required this.db});

  final AppDatabase db;

  @override
  State<TabletContentsChapterScaffold> createState() =>
      _TabletContentsChapterScaffoldState();
}

class _TabletContentsChapterScaffoldState
    extends State<TabletContentsChapterScaffold> {
  int? _selectedChapterId;
  String? _selectedChapterTitle;

  static final GlobalKey _searchKey = GlobalKey();
  final GlobalKey<NavigatorState> _detailNavKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final chaptersQuery =
        (widget.db.select(widget.db.chapters)
              ..where((t) => t.bookId.equals(1)))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.red1,
        foregroundColor: AppColors.white,
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Contents',
                style: AppText.navTitle(),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: Text(
                _selectedChapterTitle ?? 'Chapter',
                style: AppText.navTitle(),
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            key: _searchKey,
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () {
              final renderBox =
                  _searchKey.currentContext?.findRenderObject() as RenderBox?;
              final center = renderBox == null
                  ? (MediaQuery.of(context).size.center(Offset.zero))
                  : renderBox.localToGlobal(
                      renderBox.size.center(Offset.zero),
                    );
              Navigator.of(context).push(
                CircularRevealPageRoute(
                  center: center,
                  builder: (context) => SearchScreen(db: widget.db),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Reader settings',
            icon: const Icon(Icons.tune),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: StreamBuilder<List<Chapter>>(
              stream: chaptersQuery.watch(),
              builder: (context, snap) {
                final chapters = snap.data ?? const [];
                if (snap.connectionState == ConnectionState.waiting &&
                    chapters.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (chapters.isEmpty) {
                  return const Center(child: Text('No chapters found.'));
                }

                return ListView.builder(
                  itemCount: chapters.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return const QuoteCard(
                        quote:
                            '“You have a right to perform your prescribed duty…”',
                        author: 'Bhagavad Gita',
                      );
                    }
                    final c = chapters[index - 1];
                    final isExpanded = c.id == _selectedChapterId;

                    return StreamBuilder<List<Sloka>>(
                      stream: (widget.db.select(widget.db.slokas)
                            ..where((t) => t.chapterId.equals(c.id))
                            ..orderBy([(t) => OrderingTerm.asc(t.position)]))
                          .watch(),
                      builder: (context, slokaSnap) {
                        final slokas = slokaSnap.data ?? const [];
                        return Container(
                          decoration: BoxDecoration(
                            color: isExpanded ? AppColors.red1.withValues(alpha: 0.08) : null,
                            border: isExpanded
                                ? const Border(left: BorderSide(color: AppColors.red1, width: 3))
                                : null,
                          ),
                          child: ChapterExpandableTile(
                            chapter: c,
                            slokas: slokas,
                            isExpanded: isExpanded,
                            selectedSlokaId: null,
                            onExpansionChanged: (expanded) {
                              setState(() {
                                _selectedChapterId = expanded ? c.id : null;
                                _selectedChapterTitle = expanded ? 'Chapter ${c.position}' : null;
                              });
                            },
                            onSlokaTap: (s) {
                              _detailNavKey.currentState?.pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => SlokaScreen(
                                    db: widget.db,
                                    slokaId: s.id,
                                    chapterId: c.id,
                                    position: s.position,
                                    embedded: true,
                                    isCompact: true,
                                  ),
                                ),
                                (r) => false,
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Navigator(
              key: _detailNavKey,
              onGenerateRoute: (_) => MaterialPageRoute(
                builder: (context) => const _EmptyDetailPane(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyDetailPane extends StatelessWidget {
  const _EmptyDetailPane();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 64,
            color: AppColors.red1.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Select a verse',
            style: AppText.heading().copyWith(color: AppColors.gray2),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a chapter and tap on a verse\nto view its contents here',
            textAlign: TextAlign.center,
            style: AppText.body().copyWith(color: AppColors.gray3),
          ),
        ],
      ),
    );
  }
}


