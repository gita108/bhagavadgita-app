import 'package:bhagavadgita_book/data/local/app_database.dart';
import 'package:bhagavadgita_book/data/local/book_repository.dart';
import 'package:bhagavadgita_book/data/remote/dto/book_dto.dart';
import 'package:bhagavadgita_book/data/remote/dto/chapter_dto.dart';
import 'package:bhagavadgita_book/data/remote/dto/sloka_dto.dart';
import 'package:bhagavadgita_book/data/remote/legacy_api_client.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeApiClient extends LegacyApiClient {
  _FakeApiClient({this.books = const [], this.chapters = const []});

  final List<BookDto> books;
  final List<ChapterDto> chapters;

  @override
  Future<List<BookDto>> getBooks(List<int> languageIds) async => books;

  @override
  Future<List<ChapterDto>> getChapters(int bookId) async => chapters;
}

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    // Seed the default book's own chapter/verses, matching what
    // SnapshotRepository/SeedInstaller would normally have installed.
    await db
        .into(db.languages)
        .insert(const LanguagesCompanion(id: Value(1), code: Value('en')));
    await db
        .into(db.books)
        .insert(
          const BooksCompanion(
            id: Value(1),
            languageId: Value(1),
            name: Value('Default Edition'),
          ),
        );
    await db
        .into(db.chapters)
        .insert(
          const ChaptersCompanion(
            id: Value(1),
            bookId: Value(1),
            name: Value('Chapter 1'),
            position: Value(1),
          ),
        );
    await db
        .into(db.slokas)
        .insert(
          const SlokasCompanion(
            id: Value(1),
            chapterId: Value(1),
            name: Value('1.1'),
            translation: Value('Default translation for 1.1'),
            position: Value(1),
          ),
        );
    await db
        .into(db.slokas)
        .insert(
          const SlokasCompanion(
            id: Value(2),
            chapterId: Value(1),
            name: Value('1.2'),
            translation: Value('Default translation for 1.2'),
            position: Value(2),
          ),
        );
  });

  tearDown(() async => db.close());

  test(
    'downloadBook matches by verse Name and skips verses missing from the fetched book',
    () async {
      final api = _FakeApiClient(
        books: const [
          BookDto(
            id: 2,
            languageId: 1,
            name: 'Other Edition',
            initials: 'OE',
            chaptersCount: 1,
          ),
        ],
        chapters: [
          ChapterDto(
            id: 100,
            name: 'Other Chapter 1',
            order: 1,
            slokas: const [
              // Matches default sloka "1.1" by name — should be stored.
              SlokaDto(
                id: 200,
                name: '1.1',
                text: null,
                transcription: null,
                translation: 'Other edition translation for 1.1',
                comment: 'Other edition comment for 1.1',
                order: 1,
                audio: null,
                audioSanskrit: null,
                vocabularies: [],
              ),
              // No "1.2" entry — this book is missing that verse.
            ],
          ),
        ],
      );

      final repo = BookRepository(db, apiClient: api);
      await repo.downloadBook(2);

      final editionsFor1_1 = await repo.watchEditions(1).first;
      final otherEdition = editionsFor1_1.where((e) => e.bookId == 2);
      expect(otherEdition, hasLength(1));
      expect(
        otherEdition.single.translation,
        'Other edition translation for 1.1',
      );
      expect(otherEdition.single.bookInitials, 'OE');

      final editionsFor1_2 = await repo.watchEditions(2).first;
      expect(
        editionsFor1_2.where((e) => e.bookId == 2),
        isEmpty,
        reason:
            'verse missing from the fetched book must be skipped, not errored',
      );

      final catalogRow = await (db.select(
        db.interpretationBooks,
      )..where((t) => t.id.equals(2))).getSingle();
      expect(catalogRow.isDownloaded, isTrue);
    },
  );

  test('watchEditions always includes the default book\'s own row', () async {
    final repo = BookRepository(db, apiClient: _FakeApiClient());
    await repo.refreshCatalog(); // no books returned by fake -> no-op, fine

    // Seed a default-book catalog row directly since refreshCatalog() found
    // nothing from the (empty) fake API.
    await db
        .into(db.interpretationBooks)
        .insert(
          const InterpretationBooksCompanion(
            id: Value(1),
            languageId: Value(1),
            name: Value('Default Edition'),
            initials: Value('DE'),
            isDefault: Value(true),
            isDownloaded: Value(true),
          ),
        );

    final editions = await repo.watchEditions(1).first;
    expect(editions, hasLength(1));
    expect(editions.single.bookId, BookRepository.defaultBookId);
    expect(editions.single.translation, 'Default translation for 1.1');
  });

  test(
    'deleteBook clears its editions and is a no-op for the default book',
    () async {
      final repo = BookRepository(
        db,
        apiClient: _FakeApiClient(
          books: const [
            BookDto(
              id: 2,
              languageId: 1,
              name: 'Other Edition',
              initials: 'OE',
              chaptersCount: 1,
            ),
          ],
          chapters: [
            ChapterDto(
              id: 100,
              name: 'Other Chapter 1',
              order: 1,
              slokas: const [
                SlokaDto(
                  id: 200,
                  name: '1.1',
                  text: null,
                  transcription: null,
                  translation: 'Other translation',
                  comment: null,
                  order: 1,
                  audio: null,
                  audioSanskrit: null,
                  vocabularies: [],
                ),
              ],
            ),
          ],
        ),
      );

      await repo.downloadBook(2);
      expect((await repo.watchEditions(1).first).length, 1);

      await repo.deleteBook(2);
      expect(await repo.watchEditions(1).first, isEmpty);

      await repo.deleteBook(
        BookRepository.defaultBookId,
      ); // no-op, must not throw
    },
  );
}
