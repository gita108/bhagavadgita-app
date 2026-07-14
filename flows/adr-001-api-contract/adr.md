# ADR-001: Backend API Contract Design

## Meta

- **Number**: ADR-001
- **Type**: constraining
- **Status**: DRAFT
- **Created**: 2026-04-29
- **Author**: Legacy Analysis
- **Source**: `legacy/legacy_bhagavadgita.book_swift`, `legacy/legacy_bhagavadgita.book_java`

## Context

The Bhagavad Gita mobile application requires communication with a backend server to fetch content data (languages, books, chapters with slokas, quotes). Analysis of legacy iOS (Swift) and Android (Java) implementations reveals a shared API contract that both platforms use identically.

The backend serves as the authoritative source for:
- Multilingual content (4 languages, 6 book editions)
- Scripture text (Sanskrit, transliteration, translations)
- Word-by-word vocabulary
- Inspirational quotes

A new Flutter cross-platform app must maintain compatibility with this existing API.

## Decision Drivers

- **Legacy Compatibility**: Must work with existing backend without modifications
- **Content Integrity**: All scripture data must be faithfully transmitted
- **Offline Capability**: Data structure must support local caching
- **Multilingual Support**: API must handle multiple languages and translations

## Discovered API Contract

### Base Configuration

```
Base URL: http://app.bhagavadgitaapp.online/api/
Method: POST (all endpoints)
Content-Type: application/json
```

### Response Wrapper Structure

All responses follow this format:

```json
{
  "code": 0,        // 0 = success, non-zero = error
  "data": [...],    // payload (array or object)
  "message": "..."  // error message if code != 0
}
```

### Endpoints

#### 1. Data/Languages

**Request**: `POST /api/Data/Languages`
```json
{}
```

**Response**:
```json
{
  "code": 0,
  "data": [
    {"id": 1, "name": "English", "code": "en"},
    {"id": 2, "name": "Русский", "code": "ru"},
    {"id": 3, "name": "Deutsch", "code": "de"},
    {"id": 5, "name": "Español", "code": "spa"}
  ]
}
```

#### 2. Data/Books

**Request**: `POST /api/Data/Books`
```json
{
  "ids": [1, 2]  // optional: filter by language IDs
}
```

**Response**:
```json
{
  "code": 0,
  "data": [
    {
      "id": 2,
      "languageId": 1,
      "name": "Bhagavad-gītā. The Hidden Treasure of the Sweet Absolute",
      "initials": "SM",
      "chaptersCount": 18
    }
  ]
}
```

#### 3. Data/Chapters (Nested with Slokas)

**Request**: `POST /api/Data/Chapters`
```json
{
  "bookId": 2
}
```

**Response**:
```json
{
  "code": 0,
  "data": [
    {
      "name": "Observing the Armies",
      "order": 1,
      "slokas": [
        {
          "name": "1.1",
          "text": "धृतराष्ट्र उवाच...",
          "transcription": "dhṛtarāṣṭra uvāca...",
          "translation": "Dhritarashtra said...",
          "comment": null,
          "order": 1,
          "audio": "/Files/xxx.mp3",
          "audioSanskrit": "/Files/yyy.mp3",
          "vocabularies": [
            {"text": "dhṛtarāṣṭraḥ", "translation": "Dhritarashtra"}
          ]
        }
      ]
    }
  ]
}
```

#### 4. Data/Quotes

**Request**: `POST /api/Data/Quotes`
```json
{}
```

**Response**:
```json
{
  "code": 0,
  "data": {
    "author": "Mahatma Gandhi",
    "text": "The Gita has sung the praises of Knowledge..."
  }
}
```

## Considered Options

### Option 1: Maintain Existing Contract (Chosen)

**Description**: Use the exact same API contract as legacy apps

**Pros**:
- Zero backend changes required
- Proven contract working in production
- Consistent behavior across all app versions

**Cons**:
- POST for read operations (unconventional)
- Nested response requires denormalization on client
- No pagination support

**Estimated Effort**: Low

### Option 2: RESTful Redesign

**Description**: Create new RESTful endpoints (GET /languages, GET /books/:id/chapters, etc.)

**Pros**:
- Standard REST semantics
- Cacheable GET requests
- Better HTTP caching

**Cons**:
- Requires backend changes
- Must maintain two API versions
- Higher effort for Flutter migration

**Estimated Effort**: High

### Option 3: GraphQL Migration

**Description**: Implement GraphQL for flexible queries

**Pros**:
- Client-driven queries
- No over-fetching
- Type-safe schema

**Cons**:
- Major backend rewrite
- Learning curve
- Overkill for this use case

**Estimated Effort**: Very High

## Decision

We will use **Option 1: Maintain Existing Contract** because:

- Legacy backend is working and stable
- No backend team resources available for changes
- Flutter app should be functionally equivalent to legacy apps
- POST-based API works fine for our use case (not publicly documented)

## Consequences

### Positive

- Immediate compatibility with existing backend
- No backend deployment risks
- Consistent data across iOS, Android, and Flutter apps

### Negative

- Must handle nested chapter/slokas response denormalization
- Cannot leverage HTTP caching for GET requests
- Audio paths are relative, require base URL construction

### Neutral

- Response wrapper pattern must be parsed on every request
- Error handling based on `code` field, not HTTP status

## Implementation Notes

- Create `LegacyApiClient` interface matching these endpoints
- Response parsing must handle `{code, data, message}` wrapper
- Audio URLs: prepend base URL to `/Files/xxx.mp3` paths
- Chapter IDs not in response, must be assigned client-side from bookId + order

## Related Specs

- `flows/sdd-legacy-api-client/`: API client implementation spec
- `flows/sdd-legacy-domain-model/`: Entity mapping from DTOs
- `flows/tdd-api-parsing/`: Tests for response parsing

## References

- Swift source: `legacy/legacy_bhagavadgita.book_swift/Gita/Model/DataAccess/GitaRequestManager.swift`
- Java source: `legacy/legacy_bhagavadgita.book_java/app/src/main/java/com/ethnoapp/bgita/server/DataService.java`

## Tags

api backend contract legacy compatibility http

---

## Approval

### Review History

| Date | Reviewer | Status | Comments |
|------|----------|--------|----------|
| 2026-04-29 | Legacy Analysis | draft | Generated from code analysis |

### Final Decision

- [ ] Approved by: [name]
- [ ] Decided on: [date]
- [ ] Implementation assigned to: [name/team]
