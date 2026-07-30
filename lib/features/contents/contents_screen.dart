import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

import '../../app/quote/quote_of_day_controller.dart';
import '../../data/local/app_database.dart';
import '../../data/local/user_data_repository.dart';
import '../../data/remote/dto/quote_dto.dart';
import '../../l10n/l10n.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_text.dart';
import '../bookmarks/bookmarks_screen.dart';
import '../quote/quote_screen.dart';
import '../shared/services/share_service.dart';
import '../shared/widgets/quote_card.dart';
import '../reader/sloka_screen.dart';
import '../search/search_screen.dart';
import '../search/search_route.dart';
import '../settings/settings_screen.dart';
import '../tablet/breakpoints.dart';
import '../tablet/contents_chapter_scaffold.dart';
import 'widgets/chapter_expandable_tile.dart';

class ContentsScreen extends StatelessWidget {
  const ContentsScreen({super.key, required this.db});

  final AppDatabase db;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (Breakpoints.isTablet(constraints)) {
          return TabletContentsChapterScaffold(db: db);
        }
        return _PhoneContents(db: db);
      },
    );
  }
}

class _PhoneContents extends StatefulWidget {
  const _PhoneContents({required this.db});

  final AppDatabase db;

  @override
  State<_PhoneContents> createState() => _PhoneContentsState();
}

class _PhoneContentsState extends State<_PhoneContents> {
  int? _expandedChapterId;
  int? _selectedSlokaId;
  late final UserDataRepository _userData = UserDataRepository(widget.db);

  final GlobalKey _searchKey = GlobalKey();

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
        title: Text(l10n.contentsTitle, style: AppText.navTitle()),
        actions: [
          IconButton(
            tooltip: l10n.bookmarksTitle,
            icon: Image.asset(
              'assets/icons/ic_bookmarks.png',
              width: 22,
              height: 22,
              color: AppColors.white,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BookmarksScreen(db: widget.db),
                ),
              );
            },
          ),
          IconButton(
            key: _searchKey,
            tooltip: l10n.searchPlaceholder,
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
      body: StreamBuilder<List<Chapter>>(
        stream: chaptersQuery.watch(),
        builder: (context, snap) {
          final chapters = snap.data ?? const [];
          if (snap.connectionState == ConnectionState.waiting &&
              chapters.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (chapters.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.menu_book_outlined,
                      size: 54,
                      color: AppColors.gray2.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 14),
                    Text('No chapters found', style: AppText.heading()),
                    const SizedBox(height: 6),
                    Text(
                      'Please check your connection and try again.',
                      textAlign: TextAlign.center,
                      style: AppText.body().copyWith(color: AppColors.gray2),
                    ),
                    const SizedBox(height: 14),
                    FilledButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => ContentsScreen(db: widget.db),
                          ),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            itemCount: chapters.length + 1,
            padding: EdgeInsets.zero,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              if (index == 0) {
                return ValueListenableBuilder<QuoteDto?>(
                  valueListenable: quoteOfDayController,
                  builder: (context, quote, _) {
                    // Optional section — omitted entirely if no quote has
                    // been fetched yet, matching legacy behavior.
                    if (quote?.text == null || quote?.author == null) {
                      return const SizedBox.shrink();
                    }
                    return QuoteCard(
                      quote: quote!.text!,
                      author: quote.author,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => QuoteScreen(quote: quote),
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
              final isExpanded = _expandedChapterId == c.id;

              return StreamBuilder<List<Sloka>>(
                stream:
                    (widget.db.select(widget.db.slokas)
                          ..where((t) => t.chapterId.equals(c.id))
                          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
                        .watch(),
                builder: (context, slokaSnap) {
                  final slokas = slokaSnap.data ?? const [];
                  return ChapterExpandableTile(
                    chapter: c,
                    slokas: slokas,
                    isExpanded: isExpanded,
                    selectedSlokaId: _selectedSlokaId,
                    userData: _userData,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _expandedChapterId = expanded ? c.id : null;
                      });
                    },
                    onSlokaTap: (s) {
                      setState(() => _selectedSlokaId = s.id);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SlokaScreen(
                            db: widget.db,
                            slokaId: s.id,
                            chapterId: c.id,
                            position: s.position,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
