import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../data/local/app_database.dart';
import '../../data/local/user_data_repository.dart';
import '../reader/sloka_screen.dart';
import '../../ui/theme/app_colors.dart';
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
    final userData = UserDataRepository(widget.db);
    final q = _query.trim();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _queryController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: q.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _queryController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                hintText: 'Search within bookmarks',
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<(Bookmark, Sloka, Note?)>>(
              stream: _watchBookmarksWithSlokas(widget.db, q),
              builder: (context, snap) {
                final rows = snap.data ?? const [];
                if (snap.connectionState == ConnectionState.waiting && rows.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (rows.isEmpty) return const _EmptyBookmarks();

                return ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final (bookmark, sloka, note) = rows[i];
                    final hasNote = note != null && note.note.trim().isNotEmpty;
                    return Slidable(
                      key: ValueKey('bookmark-${bookmark.slokaId}'),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (_) => userData.setBookmark(sloka.id, false),
                            backgroundColor: AppColors.red1,
                            foregroundColor: AppColors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: HighlightedText(
                          text: sloka.name,
                          query: q,
                          style: AppText.body().copyWith(fontWeight: FontWeight.w700),
                          highlightStyle: AppText.body().copyWith(
                            fontWeight: FontWeight.w700,
                            backgroundColor: AppColors.red2.withValues(alpha: 0.3),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HighlightedText(
                              text: sloka.translation ?? sloka.slokaText ?? '',
                              query: q,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.body(),
                              highlightStyle: AppText.body().copyWith(
                                backgroundColor: AppColors.red2.withValues(alpha: 0.3),
                              ),
                            ),
                            if (hasNote) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.note, size: 14, color: AppColors.gray2),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      note.note.trim(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppText.caption().copyWith(
                                        fontStyle: FontStyle.italic,
                                        color: AppColors.gray2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  SlokaScreen(db: widget.db, slokaId: sloka.id),
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
  const _EmptyBookmarks();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 76,
              color: AppColors.red1.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No bookmarks yet',
              style: AppText.heading(),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the bookmark icon on any sloka to save it here.',
              textAlign: TextAlign.center,
              style: AppText.body(),
            ),
          ],
        ),
      ),
    );
  }
}

Stream<List<(Bookmark, Sloka, Note?)>> _watchBookmarksWithSlokas(AppDatabase db, String query) {
  final q = db.select(db.bookmarks).join([
    innerJoin(db.slokas, db.slokas.id.equalsExp(db.bookmarks.slokaId)),
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
    return rows.map((r) {
      return (
        r.readTable(db.bookmarks),
        r.readTable(db.slokas),
        r.readTableOrNull(db.notes),
      );
    }).toList(growable: false);
  });
}
