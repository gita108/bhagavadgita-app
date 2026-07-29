import 'package:dio/dio.dart';

import 'dto/book_dto.dart';
import 'dto/chapter_dto.dart';
import 'dto/json_value.dart';
import 'dto/language_dto.dart';
import 'dto/quote_dto.dart';
import 'legacy_envelope.dart';

class LegacyApiClient {
  LegacyApiClient({
    Dio? dio,
    String baseUrl = 'http://app.bhagavadgitaapp.online/api/',
  }) : _dio = dio ?? Dio(BaseOptions(baseUrl: baseUrl));

  final Dio _dio;

  Future<List<LanguageDto>> getLanguages() async {
    final res = await _dio.post<Map<String, Object?>>(
      'Data/Languages',
      data: const <String, Object?>{},
    );
    final env = LegacyEnvelope.fromJson<List<LanguageDto>>(
      res.data ?? const <String, Object?>{},
      parseData: (dataJson) {
        final list = asObjectList(dataJson);
        return list.map(LanguageDto.fromJson).toList(growable: false);
      },
    );
    if (!env.isOk) throw LegacyApiException(env.code, env.message);
    return env.data;
  }

  Future<List<BookDto>> getBooks(List<int> languageIds) async {
    final res = await _dio.post<Map<String, Object?>>(
      'Data/Books',
      data: <String, Object?>{'ids': languageIds},
    );
    final env = LegacyEnvelope.fromJson<List<BookDto>>(
      res.data ?? const <String, Object?>{},
      parseData: (dataJson) {
        final list = asObjectList(dataJson);
        return list.map(BookDto.fromJson).toList(growable: false);
      },
    );
    if (!env.isOk) throw LegacyApiException(env.code, env.message);
    return env.data;
  }

  Future<List<ChapterDto>> getChapters(int bookId) async {
    final res = await _dio.post<Map<String, Object?>>(
      'Data/Chapters',
      data: <String, Object?>{'bookId': bookId},
    );
    final env = LegacyEnvelope.fromJson<List<ChapterDto>>(
      res.data ?? const <String, Object?>{},
      parseData: (dataJson) {
        final list = asObjectList(dataJson);
        return list.map(ChapterDto.fromJson).toList(growable: false);
      },
    );
    if (!env.isOk) throw LegacyApiException(env.code, env.message);
    return env.data;
  }

  Future<QuoteDto?> getQuote() async {
    final res = await _dio.post<Map<String, Object?>>(
      'Data/Quotes',
      data: const <String, Object?>{},
    );
    final env = LegacyEnvelope.fromJson<QuoteDto?>(
      res.data ?? const <String, Object?>{},
      parseData: (dataJson) {
        if (dataJson is! Map) return null;
        return QuoteDto.fromJson(dataJson.cast<String, Object?>());
      },
    );
    if (!env.isOk) throw LegacyApiException(env.code, env.message);
    return env.data;
  }
}

class LegacyApiException implements Exception {
  LegacyApiException(this.code, this.message);

  final int code;
  final String? message;

  @override
  String toString() => 'LegacyApiException(code=$code, message=$message)';
}
