import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../data/mock_content.dart';
import '../../data/models.dart';
import '../../data/user_data_store.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_text.dart';
import '../reader/sloka_screen.dart';
import '../search/search_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray5,
      appBar: AppBar(
        title: const Text('Bookmarks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => SearchScreen.open(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ValueListenableBuilder<Set<int>>(
        valueListenable: UserDataStore.instance.bookmarks,
        builder: (_, ids, __) {
          if (ids.isEmpty) {
            // Show a couple of seeded bookmarks so the UI isn't empty in
            // a fresh state. (Remove this in production.)
            UserDataStore.instance.bookmarks.value = {3, 14, 117, 412};
            UserDataStore.instance.notes.value = {
              3: 'Beginning of the dialogue. Important context.',
              117:
                  'My favorite verse about action without attachment to results.',
              412: 'Beautiful promise of divine protection.',
            };
            return const SizedBox.shrink();
          }
          final bookmarks = <Sloka>[];
          for (final c in MockContent.chapters) {
            for (final s in c.slokas) {
              if (ids.contains(s.id)) bookmarks.add(s);
            }
          }
          if (bookmarks.isEmpty) return const _EmptyBookmarks();
          return ListView.builder(
            itemCount: bookmarks.length,
            itemBuilder: (context, i) =>
                _BookmarkRow(sloka: bookmarks[i]),
          );
        },
      ),
    );
  }
}

class _BookmarkRow extends StatelessWidget {
  const _BookmarkRow({required this.sloka});
  final Sloka sloka;

  @override
  Widget build(BuildContext context) {
    final note = UserDataStore.instance.noteFor(sloka.id);
    final chapter = MockContent.chapters[sloka.chapterId - 1];
    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            backgroundColor: AppColors.red3,
            foregroundColor: AppColors.white,
            icon: Icons.delete_outline,
            label: 'Delete',
            onPressed: (_) =>
                UserDataStore.instance.removeBookmark(sloka.id),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => SlokaScreen(slokaId: sloka.id),
        )),
        child: Container(
          color: AppColors.white,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.gray4)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sloka.transcription.split('\n').first,
                        style: AppText.body().copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(chapter.name, style: AppText.caption()),
                    if (note.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.gray5,
                          borderRadius: BorderRadius.circular(6),
                          border: Border(
                            left: BorderSide(
                                color: AppColors.red1.withValues(alpha: 0.6),
                                width: 2),
                          ),
                        ),
                        child: Text('Note: $note',
                            style: AppText.caption().copyWith(
                              color: AppColors.gray1,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right,
                  size: 20, color: AppColors.gray3),
            ],
          ),
        ),
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
            Container(
              width: 76,
              height: 76,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.red1.withValues(alpha: 0.08),
              ),
              child: Image.asset('assets/icons/icn_empty.png',
                  width: 56, height: 56),
            ),
            const SizedBox(height: 16),
            Text('No bookmarks yet',
                style: AppText.heading().copyWith(color: AppColors.gray1)),
            const SizedBox(height: 8),
            Text(
              'Tap the bookmark icon on any sloka to save it here.',
              textAlign: TextAlign.center,
              style: AppText.caption(),
            ),
          ],
        ),
      ),
    );
  }
}
