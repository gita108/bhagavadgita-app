import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_spacing.dart';
import '../../ui/theme/app_text.dart';
import '../../data/local/app_database.dart';
import '../../data/local/user_data_repository.dart';
import '../reader/sloka_screen.dart';
import 'widgets/highlighted_text.dart';

/// Global search overlay reached from Contents' search icon. Filters live as
/// the user types (matches legacy's Android behavior — resolved over iOS's
/// submit-triggered variant, see vdd-bhagavadgita-app-uiux 02-visual.md).
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.db});

  final AppDatabase db;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
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
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray1,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.gray1),
        title: TextField(
          controller: _queryController,
          autofocus: true,
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
      body: StreamBuilder<List<Sloka>>(
        stream: query.watch(),
        builder: (context, snap) {
          final items = snap.data ?? const <Sloka>[];
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (q.isNotEmpty && items.isEmpty) {
            return _NotFound(message: l10n.searchNotFound);
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
                    if (bookmarkSnap.data != true) {
                      return const SizedBox.shrink();
                    }
                    return Image.asset(
                      'assets/icons/ic_bookmark_small.png',
                      width: 16,
                      height: 16,
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
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound({required this.message});

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
