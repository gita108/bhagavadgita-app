import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

import '../../app/quote/quote_of_day_controller.dart';
import '../../data/remote/dto/quote_dto.dart';
import '../../l10n/l10n.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_text.dart';
import '../../data/local/app_database.dart';
import '../../data/local/user_data_repository.dart';
import '../contents/widgets/chapter_expandable_tile.dart';
import '../quote/quote_screen.dart';
import '../reader/sloka_screen.dart';
import '../search/search_route.dart';
import '../search/search_screen.dart';
import '../settings/settings_screen.dart';
import '../shared/services/share_service.dart';
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
  late final UserDataRepository _userData = UserDataRepository(widget.db);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final chaptersQuery =
        (widget.db.select(widget.db.chapters)..where((t) => t.bookId.equals(1)))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.settingsTitle,
          icon: Image.asset(
            'assets/icons/ic_settings.png',
            width: 22,
            height: 22,
            color: AppColors.white,
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SettingsScreen(db: widget.db),
              ),
            );
          },
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                l10n.contentsTitle,
                style: AppText.navTitle(),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: Text(
                _selectedChapterTitle ?? '',
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
            icon: Image.asset(
              'assets/icons/ic_search.png',
              width: 22,
              height: 22,
              color: AppColors.white,
            ),
            onPressed: () {
              final renderBox =
                  _searchKey.currentContext?.findRenderObject() as RenderBox?;
              final center = renderBox == null
                  ? (MediaQuery.of(context).size.center(Offset.zero))
                  : renderBox.localToGlobal(renderBox.size.center(Offset.zero));
              Navigator.of(context).push(
                CircularRevealPageRoute(
                  center: center,
                  builder: (context) => SearchScreen(db: widget.db),
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
                      return ValueListenableBuilder<QuoteDto?>(
                        valueListenable: quoteOfDayController,
                        builder: (context, quote, _) {
                          if (quote?.text == null || quote?.author == null) {
                            return const SizedBox.shrink();
                          }
                          return QuoteCard(
                            quote: quote!.text!,
                            author: quote.author,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      QuoteScreen(quote: quote),
                                ),
                              );
                            },
                            onShare: () {
                              ShareService().shareQuote(
                                text: quote.text!,
                                author: quote.author!,
                              );
                            },
                          );
                        },
                      );
                    }
                    final c = chapters[index - 1];
                    final isExpanded = c.id == _selectedChapterId;

                    return StreamBuilder<List<Sloka>>(
                      stream:
                          (widget.db.select(widget.db.slokas)
                                ..where((t) => t.chapterId.equals(c.id))
                                ..orderBy([
                                  (t) => OrderingTerm.asc(t.position),
                                ]))
                              .watch(),
                      builder: (context, slokaSnap) {
                        final slokas = slokaSnap.data ?? const [];
                        return Container(
                          decoration: BoxDecoration(
                            color: isExpanded
                                ? AppColors.red1.withValues(alpha: 0.08)
                                : null,
                            border: isExpanded
                                ? const Border(
                                    left: BorderSide(
                                      color: AppColors.red1,
                                      width: 3,
                                    ),
                                  )
                                : null,
                          ),
                          child: ChapterExpandableTile(
                            chapter: c,
                            slokas: slokas,
                            isExpanded: isExpanded,
                            selectedSlokaId: null,
                            userData: _userData,
                            onExpansionChanged: (expanded) {
                              setState(() {
                                _selectedChapterId = expanded ? c.id : null;
                                _selectedChapterTitle = expanded
                                    ? l10n.chapterLabel(c.position)
                                    : null;
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
