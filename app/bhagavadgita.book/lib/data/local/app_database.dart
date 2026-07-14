import 'package:drift/drift.dart';

import 'tables.dart';
import 'app_database_connection.dart'
    if (dart.library.io) 'app_database_connection_io.dart'
    if (dart.library.html) 'app_database_connection_web.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    SnapshotMeta,
    Languages,
    Books,
    Chapters,
    Slokas,
    Vocabularies,
    Bookmarks,
    Notes,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}
