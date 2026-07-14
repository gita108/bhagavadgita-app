# Specifications: Legacy API Client

> Version: 1.0
> Status: DRAFT
> Last Updated: 2026-04-29
> Requirements: [01-requirements.md](./01-requirements.md)

## Overview

This spec defines the API client layer for communicating with the Bhagavad Gita backend. The client mirrors legacy Swift/Java implementations while using modern Flutter patterns.

## Affected Systems

| System | Impact | Notes |
|--------|--------|-------|
| `lib/data/api/` | Create | API client implementation |
| `lib/data/models/` | Use | DTO classes for responses |
| `lib/core/exceptions/` | Create | API exception types |

## Architecture

### Component Diagram

```
┌──────────────────────────────────────────────────────────┐
│                    Repository Layer                       │
│   ContentRepository, QuoteRepository                      │
└──────────────────────────────────────────────────────────┘
                          │
                          ▼
┌──────────────────────────────────────────────────────────┐
│                    LegacyApiClient                        │
│   - getLanguages()                                        │
│   - getBooks(languageIds)                                 │
│   - getChapters(bookId)                                   │
│   - getQuote()                                            │
└──────────────────────────────────────────────────────────┘
                          │
                          ▼
┌──────────────────────────────────────────────────────────┐
│                    ApiResponseHandler                     │
│   - unwrapResponse<T>()                                   │
│   - handleError()                                         │
└──────────────────────────────────────────────────────────┘
                          │
                          ▼
┌──────────────────────────────────────────────────────────┐
│                      Dio / Http                           │
│   (HTTP client)                                           │
└──────────────────────────────────────────────────────────┘
                          │
                          ▼
┌──────────────────────────────────────────────────────────┐
│     http://app.bhagavadgitaapp.online/api/               │
└──────────────────────────────────────────────────────────┘
```

### Data Flow

```
Repository.fetchChapters(bookId)
    │
    ▼
LegacyApiClient.getChapters(bookId)
    │
    ▼
POST /api/Data/Chapters
Body: {"bookId": 2}
    │
    ▼
Response: {"code": 0, "data": [...], "message": null}
    │
    ▼
ApiResponseHandler.unwrap()
    │
    ├── code == 0 → parse data → List<ChapterDto>
    │
    └── code != 0 → throw ApiException
    │
    ▼
Return List<ChapterDto>
```

## Interfaces

### LegacyApiClient Interface

```dart
// lib/data/api/legacy_api_client.dart

abstract class LegacyApiClient {
  /// Fetches all available languages
  Future<List<LanguageDto>> getLanguages();

  /// Fetches books, optionally filtered by language IDs
  Future<List<BookDto>> getBooks([List<int>? languageIds]);

  /// Fetches chapters with nested slokas for a book
  Future<List<ChapterDto>> getChapters(int bookId);

  /// Fetches a random inspirational quote
  Future<QuoteDto?> getQuote();
}
```

### Implementation

```dart
// lib/data/api/legacy_api_client_impl.dart

class LegacyApiClientImpl implements LegacyApiClient {
  static const _baseUrl = 'http://app.bhagavadgitaapp.online/api';

  final Dio _dio;

  LegacyApiClientImpl({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: _baseUrl,
              connectTimeout: Duration(seconds: 30),
              receiveTimeout: Duration(seconds: 30),
              contentType: 'application/json',
            ));

  @override
  Future<List<LanguageDto>> getLanguages() async {
    final response = await _post('Data/Languages', {});
    return _parseList(response, LanguageDto.fromJson);
  }

  @override
  Future<List<BookDto>> getBooks([List<int>? languageIds]) async {
    final params = languageIds != null ? {'ids': languageIds} : null;
    final response = await _post('Data/Books', params);
    return _parseList(response, BookDto.fromJson);
  }

  @override
  Future<List<ChapterDto>> getChapters(int bookId) async {
    final response = await _post('Data/Chapters', {'bookId': bookId});
    return _parseList(response, ChapterDto.fromJson);
  }

  @override
  Future<QuoteDto?> getQuote() async {
    final response = await _post('Data/Quotes', {});
    if (response == null) return null;
    return QuoteDto.fromJson(response as Map<String, dynamic>);
  }

  /// POST request with response wrapper handling
  Future<dynamic> _post(String endpoint, Map<String, dynamic>? params) async {
    try {
      final body = params != null ? {'params': params} : <String, dynamic>{};
      final response = await _dio.post(endpoint, data: body);
      return _unwrapResponse(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Unwrap {code, data, message} wrapper
  dynamic _unwrapResponse(dynamic responseData) {
    if (responseData is! Map<String, dynamic>) {
      throw ApiException(code: -1, message: 'Invalid response format');
    }

    final code = responseData['code'] as int? ?? -1;
    final data = responseData['data'];
    final message = responseData['message'] as String?;

    if (code != 0) {
      throw ApiException(code: code, message: message ?? 'Unknown error');
    }

    return data;
  }

  List<T> _parseList<T>(
    dynamic data,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (data == null) return [];
    if (data is! List) return [];
    return data
        .cast<Map<String, dynamic>>()
        .map((json) => fromJson(json))
        .toList();
  }
}
```

### Exception Types

```dart
// lib/core/exceptions/api_exception.dart

class ApiException implements Exception {
  final int code;
  final String message;
  final DioException? dioError;

  const ApiException({
    required this.code,
    required this.message,
    this.dioError,
  });

  factory ApiException.fromDioError(DioException e) {
    return ApiException(
      code: e.response?.statusCode ?? -1,
      message: _messageFromDioError(e),
      dioError: e,
    );
  }

  static String _messageFromDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';
      case DioExceptionType.receiveTimeout:
        return 'Response timeout';
      case DioExceptionType.connectionError:
        return 'No internet connection';
      default:
        return e.message ?? 'Network error';
    }
  }

  bool get isNetworkError => dioError != null;
  bool get isServerError => code >= 500;
  bool get isClientError => code >= 400 && code < 500;

  @override
  String toString() => 'ApiException(code: $code, message: $message)';
}
```

## Behavior Specifications

### Request Format

All requests follow this pattern:

```
POST /api/{endpoint}
Content-Type: application/json

{
  "params": {
    "key": "value"
  }
}
```

For endpoints without parameters (Languages, Quotes), send empty body `{}`.

### Response Processing

```
Response → JSON decode
    │
    ▼
Check: is Map with {code, data, message}?
    │
    ├── NO → throw ApiException("Invalid format")
    │
    └── YES → check code
              │
              ├── code == 0 → return data
              │
              └── code != 0 → throw ApiException(code, message)
```

### Edge Cases

| Case | Trigger | Expected Behavior |
|------|---------|-------------------|
| Empty data array | No books/chapters | Return empty list |
| Null data | Quote not available | Return null |
| Network timeout | Slow/no network | Throw ApiException with connection message |
| Invalid JSON | Malformed response | Throw ApiException |
| HTTP 500 | Server error | Throw ApiException with status code |
| HTTP 401 | Unexpected auth error | Throw ApiException (shouldn't happen) |

### Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `code != 0` | Business logic error | Throw with server message |
| `DioException.connectionTimeout` | Network slow | Throw "Connection timeout" |
| `DioException.connectionError` | No internet | Throw "No internet connection" |
| JSON decode failure | Invalid response | Throw "Invalid response format" |

## Dependencies

### Requires

- `dio` package for HTTP
- ADR-001: API Contract (defines endpoints)
- SDD: Domain Model (defines DTOs)

### Blocks

- Repository layer (uses this client)
- Sync orchestrator (uses this for background sync)

## Testing Strategy

### Unit Tests

- [ ] `getLanguages()` - Parse languages response
- [ ] `getBooks()` - Parse books with optional IDs filter
- [ ] `getChapters()` - Parse nested chapters/slokas/vocabularies
- [ ] `getQuote()` - Parse single quote or null
- [ ] Error cases - code != 0, network errors, invalid JSON
- [ ] Timeout handling

### Integration Tests

- [ ] Live API call to get languages
- [ ] Full flow: languages → books → chapters

### Mock Setup

```dart
// For testing
class MockLegacyApiClient implements LegacyApiClient {
  @override
  Future<List<LanguageDto>> getLanguages() async {
    return [
      LanguageDto(id: 1, name: 'English', code: 'en'),
      LanguageDto(id: 2, name: 'Русский', code: 'ru'),
    ];
  }
  // ... other methods
}
```

---

## Approval

- [ ] Reviewed by: [name]
- [ ] Approved on: [date]
- [ ] Notes: [any conditions or clarifications]
