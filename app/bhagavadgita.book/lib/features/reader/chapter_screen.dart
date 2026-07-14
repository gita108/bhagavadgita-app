import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import '../../data/local/app_database.dart';
import '../../data/local/user_data_repository.dart';
import 'sloka_screen.dart';

class ChapterScreen extends StatelessWidget {
  const ChapterScreen({
    super.key,
    required this.db,
    required this.chapterId,
    required this.title,
  });

  final AppDatabase db;
  final int chapterId;
  final String title;

  @override
  Widget build(BuildContext context) {
    final userData = UserDataRepository(db);
    final slokasQuery =
        (db.select(db.slokas)..where((t) => t.chapterId.equals(chapterId)))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: StreamBuilder<List<Sloka>>(
        stream: slokasQuery.watch(),
        builder: (context, snap) {
          final slokas = snap.data ?? const [];
          if (snap.connectionState == ConnectionState.waiting &&
              slokas.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (slokas.isEmpty) {
            return const Center(child: Text('No slokas in this chapter yet.'));
          }

          return ListView.separated(
            itemCount: slokas.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final s = slokas[index];
              return ListTile(
                title: Text(s.name),
                subtitle: Text(
                  s.translation ?? s.slokaText ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: StreamBuilder<bool>(
                  stream: userData.watchBookmark(s.id),
                  builder: (context, bookmarkSnap) {
                    final isBookmarked = bookmarkSnap.data ?? false;
                    return Icon(
                      isBookmarked ? Icons.bookmark : Icons.chevron_right,
                      color: isBookmarked
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    );
                  },
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SlokaScreen(
                        db: db,
                        slokaId: s.id,
                        chapterId: chapterId,
                        position: s.position,
                      ),
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
