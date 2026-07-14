import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_text.dart';
import '../../data/local/app_database.dart';
import '../../data/local/user_data_repository.dart';
import '../reader/sloka_screen.dart';
import 'widgets/highlighted_text.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.db});

  final AppDatabase db;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _queryController = TextEditingController();
  String _query = '';
  bool _onlyBookmarks = false;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim();
    final like = '%${q.replaceAll('%', r'\%').replaceAll('_', r'\_')}%';
    final userData = UserDataRepository(widget.db);

    final query = widget.db.select(widget.db.slokas)
      ..orderBy([(t) => OrderingTerm.asc(t.id)]);
    if (q.isNotEmpty) {
      final vocabSubquery = widget.db.selectOnly(widget.db.vocabularies)
        ..addColumns([widget.db.vocabularies.slokaId])
        ..where(
          widget.db.vocabularies.tokenText.like(like) |
              widget.db.vocabularies.translation.like(like),
        );

      query.where(
        (t) =>
            t.name.like(like) |
            t.slokaText.like(like) |
            t.transcription.like(like) |
            t.translation.like(like) |
            t.comment.like(like) |
            t.id.isInQuery(vocabSubquery),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Поиск', style: AppText.navTitle()),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray1,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.gray1),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              controller: _queryController,
              autofocus: true,
              style: AppText.body(),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.gray5,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                hintText: 'Поиск по шлокам...',
                hintStyle: AppText.body().copyWith(color: AppColors.gray2),
                prefixIcon: const Icon(Icons.search, color: AppColors.gray2),
                suffixIcon: q.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.gray2),
                        onPressed: () {
                          _queryController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: !_onlyBookmarks,
                  onSelected: (v) => setState(() => _onlyBookmarks = !v),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Bookmarks'),
                  selected: _onlyBookmarks,
                  onSelected: (v) => setState(() => _onlyBookmarks = v),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: AppColors.gray5.withValues(alpha: 0.5),
              child: StreamBuilder<List<Sloka>>(
                stream: query.watch(),
                builder: (context, snap) {
                  final items = snap.data ?? const <Sloka>[];
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (q.isNotEmpty && items.isEmpty) {
                    return const Center(child: Text('Nothing found.'));
                  }
                  if (q.isEmpty && items.isEmpty && !_onlyBookmarks) {
                    return const Center(
                      child: Text('No slokas in local snapshot.'),
                    );
                  }
                  if (q.isEmpty && items.isEmpty && _onlyBookmarks) {
                    return const Center(
                      child: Text('No bookmarks found.'),
                    );
                  }
                  return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final s = items[index];
                    return ListTile(
                      title: HighlightedText(
                        text: s.name,
                        query: q,
                        style: AppText.body().copyWith(fontWeight: FontWeight.w700),
                        highlightStyle: AppText.body().copyWith(
                          fontWeight: FontWeight.w700,
                          backgroundColor: AppColors.red2.withValues(alpha: 0.3),
                        ),
                      ),
                      subtitle: HighlightedText(
                        text: s.translation ?? s.slokaText ?? '',
                        query: q,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body(),
                        highlightStyle: AppText.body().copyWith(
                          backgroundColor: AppColors.red2.withValues(alpha: 0.3),
                        ),
                      ),
                      trailing: StreamBuilder<bool>(
                        stream: userData.watchBookmark(s.id),
                        builder: (context, bookmarkSnap) {
                          final isBookmarked = bookmarkSnap.data ?? false;
                          return Icon(
                            isBookmarked ? Icons.bookmark : Icons.chevron_right,
                            color: isBookmarked ? AppColors.red1 : null,
                          );
                        },
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                SlokaScreen(db: widget.db, slokaId: s.id),
                          ),
                        );
                      },
                    );
                  },
                );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
