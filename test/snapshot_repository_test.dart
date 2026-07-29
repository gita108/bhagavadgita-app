import 'package:bhagavadgita_book/data/local/app_database.dart';
import 'package:bhagavadgita_book/data/local/snapshot_repository.dart';
import 'package:drift/drift.dart' show Value;
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

  test('replaceSnapshot keeps bookmarks and notes untouched', () async {
    await db
        .into(db.bookmarks)
        .insert(
          BookmarksCompanion(
            slokaId: const Value(1001),
            createdAtMs: Value(DateTime.now().millisecondsSinceEpoch),
          ),
        );
    await db
        .into(db.notes)
        .insert(
          NotesCompanion(
            slokaId: const Value(1001),
            note: const Value('persist me'),
            updatedAtMs: Value(DateTime.now().millisecondsSinceEpoch),
          ),
        );

    await repository.replaceSnapshot(
      languages: [
        const LanguagesCompanion(
          id: Value(1),
          code: Value('en'),
          name: Value('English'),
          nativeName: Value('English'),
          script: Value('Latin'),
          direction: Value('ltr'),
          type: Value('translated'),
        ),
      ],
      books: [
        const BooksCompanion(
          id: Value(1),
          languageId: Value(1),
          name: Value('Bhagavad Gita'),
          initials: Value('BG'),
        ),
      ],
      chapters: [
        const ChaptersCompanion(
          id: Value(1),
          bookId: Value(1),
          name: Value('Chapter 1'),
          position: Value(1),
        ),
      ],
      slokas: [
        const SlokasCompanion(
          id: Value(1001),
          chapterId: Value(1),
          name: Value('1.1'),
          slokaText: Value('dharma ksetre'),
          transcription: Value('dharma-ksetre'),
          translation: Value('On the field of dharma'),
          comment: Value('comment'),
          position: Value(1),
          audio: Value(null),
          audioSanskrit: Value(null),
        ),
      ],
      vocabularies: [
        const VocabulariesCompanion(
          id: Value(1),
          slokaId: Value(1001),
          tokenText: Value('dharma'),
          translation: Value('duty'),
          position: Value(1),
        ),
      ],
      meta: SnapshotMetaCompanion.insert(
        contentHash: 'snapshot-1',
        fetchedAtMs: DateTime.now().millisecondsSinceEpoch,
        source: 'test',
        schemaVersion: db.schemaVersion,
      ),
    );

    final bookmark = await (db.select(
      db.bookmarks,
    )..where((t) => t.slokaId.equals(1001))).getSingleOrNull();
    final note = await (db.select(
      db.notes,
    )..where((t) => t.slokaId.equals(1001))).getSingleOrNull();
    expect(bookmark, isNotNull);
    expect(note?.note, 'persist me');
  });

  test('replaceSnapshot replaces old content snapshot', () async {
    await repository.replaceSnapshot(
      languages: [
        const LanguagesCompanion(
          id: Value(1),
          code: Value('en'),
          name: Value('English'),
          nativeName: Value(null),
          script: Value(null),
          direction: Value(null),
          type: Value('translated'),
        ),
      ],
      books: [
        const BooksCompanion(
          id: Value(1),
          languageId: Value(1),
          name: Value('Old Book'),
          initials: Value('OLD'),
        ),
      ],
      chapters: [
        const ChaptersCompanion(
          id: Value(1),
          bookId: Value(1),
          name: Value('Old Chapter'),
          position: Value(1),
        ),
      ],
      slokas: [
        const SlokasCompanion(
          id: Value(1),
          chapterId: Value(1),
          name: Value('1.1'),
          slokaText: Value('old'),
          transcription: Value(null),
          translation: Value('old'),
          comment: Value(null),
          position: Value(1),
          audio: Value(null),
          audioSanskrit: Value(null),
        ),
      ],
      vocabularies: const [],
      meta: SnapshotMetaCompanion.insert(
        contentHash: 'old',
        fetchedAtMs: 1,
        source: 'test',
        schemaVersion: db.schemaVersion,
      ),
    );

    await repository.replaceSnapshot(
      languages: [
        const LanguagesCompanion(
          id: Value(2),
          code: Value('ru'),
          name: Value('Russian'),
          nativeName: Value(null),
          script: Value(null),
          direction: Value(null),
          type: Value('translated'),
        ),
      ],
      books: [
        const BooksCompanion(
          id: Value(2),
          languageId: Value(2),
          name: Value('New Book'),
          initials: Value('NEW'),
        ),
      ],
      chapters: [
        const ChaptersCompanion(
          id: Value(2),
          bookId: Value(2),
          name: Value('New Chapter'),
          position: Value(1),
        ),
      ],
      slokas: [
        const SlokasCompanion(
          id: Value(2),
          chapterId: Value(2),
          name: Value('1.1'),
          slokaText: Value('new'),
          transcription: Value(null),
          translation: Value('new'),
          comment: Value(null),
          position: Value(1),
          audio: Value(null),
          audioSanskrit: Value(null),
        ),
      ],
      vocabularies: const [],
      meta: SnapshotMetaCompanion.insert(
        contentHash: 'new',
        fetchedAtMs: 2,
        source: 'test',
        schemaVersion: db.schemaVersion,
      ),
    );

    final books = await db.select(db.books).get();
    expect(books, hasLength(1));
    expect(books.single.id, 2);
    expect(books.single.name, 'New Book');
  });
}
