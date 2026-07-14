# Requirements: API Response Parsing

> Version: 1.0
> Status: DRAFT
> Last Updated: 2026-04-29
> Source: Legacy iOS/Android code analysis

## Problem Statement

The backend API returns JSON responses in a specific format with nested structures. Parsing must handle:
- Response wrapper `{code, data, message}` unwrapping
- Nested chapter → slokas → vocabularies structures
- Client-side ID generation for entities without server IDs
- Edge cases (null fields, empty arrays, malformed data)

Correctness is critical: wrong parsing means corrupted scripture display.

## User Stories

### Primary

**As a** Flutter app
**I want** reliable JSON parsing of API responses
**So that** scripture content is displayed correctly

### Secondary

**As a** developer
**I want** comprehensive test coverage for parsing
**So that** I catch regressions before they reach users

## Critical Parsing Requirements

### R001: Response Wrapper Unwrapping

The API wraps all responses in:
```json
{
  "code": 0,
  "data": <payload>,
  "message": null
}
```

Parser must:
- Extract `data` field when `code == 0`
- Throw exception with `message` when `code != 0`
- Handle missing fields gracefully

### R002: Language Parsing

```json
{"id": 1, "name": "English", "code": "en"}
```

All fields required.

### R003: Book Parsing

```json
{
  "id": 2,
  "languageId": 1,
  "name": "Bhagavad-gītā. The Hidden Treasure",
  "initials": "SM",
  "chaptersCount": 18
}
```

All fields required.

### R004: Chapter Parsing (Nested)

```json
{
  "name": "Observing the Armies",
  "order": 1,
  "slokas": [...]
}
```

**Note**: No `id` in response. Must generate client-side ID.

### R005: Shloka Parsing (Nested)

```json
{
  "name": "1.1",
  "text": "धृतराष्ट्र उवाच...",
  "transcription": "dhṛtarāṣṭra uvāca...",
  "translation": "Dhritarashtra said...",
  "comment": null,
  "order": 1,
  "audio": "/Files/xxx.mp3",
  "audioSanskrit": "/Files/yyy.mp3",
  "vocabularies": [...]
}
```

**Note**: No `id` in response. `comment`, `audio`, `audioSanskrit` can be null.

### R006: Vocabulary Parsing

```json
{"text": "dhṛtarāṣṭraḥ", "translation": "Dhritarashtra"}
```

All fields required. No ID in API response.

### R007: Quote Parsing

```json
{"author": "Mahatma Gandhi", "text": "The Gita..."}
```

All fields required. API returns single object, not array.

### R008: ID Generation

Since Chapter/Shloka don't have server IDs, generate deterministic client-side IDs:

```
Chapter ID = bookId * 100 + order
Shloka ID = chapterId * 1000 + order
```

## Acceptance Criteria

### Must Have

1. **Given** valid response with `code: 0`
   **When** parsed
   **Then** return data payload

2. **Given** error response with `code: 1`
   **When** parsed
   **Then** throw ApiException with message

3. **Given** chapters response for bookId=2
   **When** parsed
   **Then** chapter order=1 gets ID=201

4. **Given** shloka in chapter 201 with order=5
   **When** parsed
   **Then** shloka gets ID=201005

5. **Given** shloka with null comment
   **When** parsed
   **Then** entity has comment=null

6. **Given** empty vocabularies array
   **When** parsed
   **Then** shloka.vocabularies is empty list

### Should Have

- Detailed error messages for malformed JSON
- Logging of parse failures for debugging

### Won't Have (This Iteration)

- Schema validation beyond type checking
- Backward compatibility with old API versions

## Constraints

- **Technical**: Must use json_serializable or equivalent
- **Performance**: Parse 700+ slokas in <100ms
- **Platform**: Must work on iOS, Android, Web

## References

- ADR-001: API Contract Design
- SDD: Legacy Domain Model
- SDD: Legacy API Client

---

## Approval

- [ ] Reviewed by: [name]
- [ ] Approved on: [date]
- [ ] Notes: [any conditions or clarifications]
