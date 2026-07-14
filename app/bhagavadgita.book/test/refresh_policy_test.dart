import 'package:bhagavadgita_book/app/sync/refresh_policy.dart';
import 'package:bhagavadgita_book/data/local/app_database.dart';
import 'package:bhagavadgita_book/data/local/snapshot_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late SnapshotRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = SnapshotRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('should refresh when no snapshot exists', () async {
    final policy = RefreshPolicy(maxSnapshotAge: const Duration(hours: 6));
    expect(await policy.shouldRefresh(repository), isTrue);
  });

  test('should not refresh when snapshot is fresh', () async {
    await db
        .into(db.snapshotMeta)
        .insert(
          SnapshotMetaCompanion.insert(
            contentHash: 'fresh',
            fetchedAtMs: DateTime.now().millisecondsSinceEpoch,
            source: 'test',
            schemaVersion: db.schemaVersion,
          ),
        );

    final policy = RefreshPolicy(maxSnapshotAge: const Duration(hours: 6));
    expect(await policy.shouldRefresh(repository), isFalse);
  });

  test('should refresh when snapshot is stale', () async {
    await db
        .into(db.snapshotMeta)
        .insert(
          SnapshotMetaCompanion.insert(
            contentHash: 'stale',
            fetchedAtMs: DateTime.now()
                .subtract(const Duration(hours: 7))
                .millisecondsSinceEpoch,
            source: 'test',
            schemaVersion: db.schemaVersion,
          ),
        );

    final policy = RefreshPolicy(maxSnapshotAge: const Duration(hours: 6));
    expect(await policy.shouldRefresh(repository), isTrue);
  });
}
