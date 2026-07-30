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
    InterpretationBooks,
    SlokaEditions,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(interpretationBooks);
        await m.createTable(slokaEditions);
      }
    },
  );
}
