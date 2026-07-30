import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../data/local/app_database.dart';
import '../../data/local/user_data_repository.dart';
import '../../l10n/l10n.dart';
import '../reader/sloka_screen.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_spacing.dart';
import '../../ui/theme/app_text.dart';
import '../search/widgets/highlighted_text.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key, required this.db});

  final AppDatabase db;

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final TextEditingController _queryController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final userData = UserDataRepository(widget.db);
    final q = _query.trim();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bookmarksTitle, style: AppText.navTitle()),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.gutter),
            child: TextField(
              controller: _queryController,
              style: AppText.body(),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: AppColors.gray4,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space4,
                  vertical: AppSpacing.space2,
                ),
                hintText: l10n.searchPlaceholder,
                hintStyle: AppText.body().copyWith(color: AppColors.gray6),
                suffixIcon: q.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          size: 18,
                          color: AppColors.gray2,
                        ),
                        onPressed: () {
                          _queryController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<(Bookmark, Sloka, Chapter, Note?)>>(
              stream: _watchBookmarksWithSlokas(widget.db, q),
              builder: (context, snap) {
                final rows = snap.data ?? const [];
                if (snap.connectionState == ConnectionState.waiting &&
                    rows.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (rows.isEmpty) {
                  return _EmptyBookmarks(message: l10n.searchNotFound);
                }

                return ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final (bookmark, sloka, chapter, note) = rows[i];
                    final hasNote = note != null && note.note.trim().isNotEmpty;
                    return Slidable(
                      key: ValueKey('bookmark-${bookmark.slokaId}'),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (_) =>
                                userData.setBookmark(sloka.id, false),
                            backgroundColor: AppColors.red1,
                            foregroundColor: AppColors.white,
                            icon: Icons.delete,
                            label: l10n.confirmDeleteTitle,
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: HighlightedText(
                          text: '${sloka.name} ${chapter.name}',
                          query: q,
                          style: AppText.body(),
                          highlightStyle: AppText.body().copyWith(
                            backgroundColor: AppColors.red2.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        subtitle: hasNote
                            ? Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/icons/ic_note_small.png',
                                      width: 14,
                                      height: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        note.note.trim(),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppText.caption().copyWith(
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : null,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SlokaScreen(
                                db: widget.db,
                                slokaId: sloka.id,
                                cameFromBookmarks: true,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBookmarks extends StatelessWidget {
  const _EmptyBookmarks({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 79),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/icons/icn_empty.png',
              width: 80,
              height: 80,
              color: AppColors.gray3,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppText.body().copyWith(color: AppColors.gray1),
            ),
          ],
        ),
      ),
    );
  }
}

Stream<List<(Bookmark, Sloka, Chapter, Note?)>> _watchBookmarksWithSlokas(
  AppDatabase db,
  String query,
) {
  final q = db.select(db.bookmarks).join([
    innerJoin(db.slokas, db.slokas.id.equalsExp(db.bookmarks.slokaId)),
    innerJoin(db.chapters, db.chapters.id.equalsExp(db.slokas.chapterId)),
    leftOuterJoin(db.notes, db.notes.slokaId.equalsExp(db.bookmarks.slokaId)),
  ]);

  if (query.isNotEmpty) {
    final like = '%${query.replaceAll('%', r'\%').replaceAll('_', r'\_')}%';
    q.where(
      db.slokas.name.like(like) |
          db.slokas.slokaText.like(like) |
          db.slokas.translation.like(like) |
          db.slokas.comment.like(like) |
          db.notes.note.like(like),
    );
  }

  q.orderBy([OrderingTerm.desc(db.bookmarks.createdAtMs)]);

  return q.watch().map((rows) {
    return rows
        .map((r) {
          return (
            r.readTable(db.bookmarks),
            r.readTable(db.slokas),
            r.readTable(db.chapters),
            r.readTableOrNull(db.notes),
          );
        })
        .toList(growable: false);
  });
}
