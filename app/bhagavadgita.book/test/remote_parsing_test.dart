import 'package:bhagavadgita_book/data/remote/dto/book_dto.dart';
import 'package:bhagavadgita_book/data/remote/dto/chapter_dto.dart';
import 'package:bhagavadgita_book/data/remote/dto/language_dto.dart';
import 'package:bhagavadgita_book/data/remote/dto/sloka_dto.dart';
import 'package:bhagavadgita_book/data/remote/dto/vocabulary_dto.dart';
import 'package:bhagavadgita_book/data/remote/legacy_envelope.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LegacyEnvelope', () {
    test('parses message for non-string payload', () {
      final env = LegacyEnvelope.fromJson<List<Object?>>(<String, Object?>{
        'code': 7,
        'message': 123,
        'data': const <Object?>[],
      }, parseData: (data) => data as List<Object?>? ?? const <Object?>[]);

      expect(env.code, 7);
      expect(env.message, '123');
      expect(env.isOk, isFalse);
    });
  });

  group('DTO parsing', () {
    test('accepts numeric strings and trims fields', () {
      final language = LanguageDto.fromJson(<String, Object?>{
        'id': '5',
        'name': '  English  ',
        'code': ' en ',
      });
      expect(language.id, 5);
      expect(language.name, 'English');
      expect(language.code, 'en');

      final book = BookDto.fromJson(<String, Object?>{
        'id': '10',
        'languageId': '5',
        'name': ' Book ',
        'initials': '',
        'chaptersCount': '18',
      });
      expect(book.id, 10);
      expect(book.languageId, 5);
      expect(book.name, 'Book');
      expect(book.initials, isNull);
      expect(book.chaptersCount, 18);
    });

    test('ignores invalid nested list records', () {
      final chapter = ChapterDto.fromJson(<String, Object?>{
        'id': 1,
        'name': 'Chapter 1',
        'order': 1,
        'shlokas': <Object?>[
          <String, Object?>{
            'id': '100',
            'name': '1.1',
            'text': 'text',
            'order': '1',
            'vocabularies': <Object?>[
              <String, Object?>{
                'id': '1',
                'text': 'dharma',
                'translation': 'duty',
              },
              'bad-row',
            ],
          },
          42,
        ],
      });

      expect(chapter.slokas, hasLength(1));
      final sloka = chapter.slokas.first;
      expect(sloka, isA<SlokaDto>());
      expect(sloka.id, 100);
      expect(sloka.vocabularies, hasLength(1));
      expect(sloka.vocabularies.first, isA<VocabularyDto>());
      expect(sloka.vocabularies.first.text, 'dharma');
    });
  });
}
