# Test Cases: API Response Parsing

> Version: 1.0
> Status: DRAFT
> Last Updated: 2026-04-29

## Overview

Test cases for parsing backend API responses. Tests are organized by endpoint and cover happy path, edge cases, and error scenarios.

---

## Test: Response Wrapper - Success

**ID**: T001
**Requirement**: R001
**Type**: Functional

### Scenario

**Given**: API response `{"code": 0, "data": [...], "message": null}`
**When**: Response is unwrapped
**Then**: Return the `data` array

### Examples

| Input | Expected Output |
|-------|-----------------|
| `{"code": 0, "data": [{"id": 1}], "message": null}` | `[{"id": 1}]` |
| `{"code": 0, "data": {"author": "X"}, "message": null}` | `{"author": "X"}` |
| `{"code": 0, "data": [], "message": null}` | `[]` |

---

## Test: Response Wrapper - Error

**ID**: T002
**Requirement**: R001
**Type**: Error

### Scenario

**Given**: API response with `code != 0`
**When**: Response is unwrapped
**Then**: Throw `ApiException` with code and message

### Examples

| Input | Expected Exception |
|-------|-------------------|
| `{"code": 1, "data": null, "message": "Book not found"}` | `ApiException(1, "Book not found")` |
| `{"code": 500, "data": null, "message": "Server error"}` | `ApiException(500, "Server error")` |
| `{"code": 401, "data": null, "message": null}` | `ApiException(401, "Unknown error")` |

---

## Test: Response Wrapper - Invalid Format

**ID**: T003
**Requirement**: R001
**Type**: Error

### Scenario

**Given**: Malformed response without expected structure
**When**: Response is unwrapped
**Then**: Throw `ApiException` with format error

### Examples

| Input | Expected Exception |
|-------|-------------------|
| `"just a string"` | `ApiException(-1, "Invalid response format")` |
| `{"other": "field"}` | `ApiException(-1, "Missing code field")` |
| `null` | `ApiException(-1, "Invalid response format")` |

---

## Test: Parse Languages

**ID**: T010
**Requirement**: R002
**Type**: Functional

### Scenario

**Given**: Languages JSON array
**When**: Parsed to `List<LanguageDto>`
**Then**: All fields mapped correctly

### Examples

| Input | Expected Entity |
|-------|-----------------|
| `[{"id": 1, "name": "English", "code": "en"}]` | `Language(id=1, name="English", code="en")` |
| `[{"id": 2, "name": "Русский", "code": "ru"}]` | `Language(id=2, name="Русский", code="ru")` |

### Edge Cases

- Unicode names (Cyrillic, Devanagari) preserved
- Empty array returns empty list

---

## Test: Parse Books

**ID**: T020
**Requirement**: R003
**Type**: Functional

### Scenario

**Given**: Books JSON array
**When**: Parsed to `List<BookDto>`
**Then**: All fields mapped correctly

### Examples

| Input | Expected Entity |
|-------|-----------------|
| `{"id": 2, "languageId": 1, "name": "Bhagavad-gītā", "initials": "SM", "chaptersCount": 18}` | `Book(id=2, languageId=1, ...)` |

### Edge Cases

- Long book names with diacritics
- chaptersCount = 0 for incomplete books

---

## Test: Parse Chapters with ID Generation

**ID**: T030
**Requirement**: R004, R008
**Type**: Functional

### Scenario

**Given**: Chapters JSON for bookId=2
**When**: Parsed with `toEntity(bookId=2)`
**Then**: Chapter ID = bookId * 100 + order

### Examples

| bookId | order | Expected ID |
|--------|-------|-------------|
| 2 | 1 | 201 |
| 2 | 18 | 218 |
| 8 | 5 | 805 |
| 11 | 12 | 1112 |

---

## Test: Parse Slokas with ID Generation

**ID**: T040
**Requirement**: R005, R008
**Type**: Functional

### Scenario

**Given**: Slokas JSON nested in chapter
**When**: Parsed with `toEntity(chapterId=201)`
**Then**: Shloka ID = chapterId * 1000 + order

### Examples

| chapterId | order | Expected ID |
|-----------|-------|-------------|
| 201 | 1 | 201001 |
| 201 | 47 | 201047 |
| 218 | 78 | 218078 |

---

## Test: Parse Shloka - Nullable Fields

**ID**: T041
**Requirement**: R005
**Type**: Edge Case

### Scenario

**Given**: Shloka JSON with null optional fields
**When**: Parsed
**Then**: Entity has null for those fields

### Examples

| Field | JSON Value | Entity Value |
|-------|------------|--------------|
| comment | `null` | `null` |
| comment | `"text"` | `"text"` |
| audio | `null` | `null` |
| audio | `"/Files/x.mp3"` | `"/Files/x.mp3"` |
| audioSanskrit | `null` | `null` |

---

## Test: Parse Shloka - Audio URL Construction

**ID**: T042
**Requirement**: R005
**Type**: Functional

### Scenario

**Given**: Shloka with relative audio path
**When**: Accessed via `audioUrl` getter
**Then**: Full URL constructed with base URL

### Examples

| audio field | audioUrl getter |
|-------------|-----------------|
| `"/Files/abc.mp3"` | `"http://app.bhagavadgitaapp.online/Files/abc.mp3"` |
| `null` | `null` |

---

## Test: Parse Vocabularies

**ID**: T050
**Requirement**: R006
**Type**: Functional

### Scenario

**Given**: Vocabularies JSON array in shloka
**When**: Parsed
**Then**: All word entries mapped

### Examples

| Input | Expected |
|-------|----------|
| `[{"text": "dharma", "translation": "duty"}]` | `Vocabulary(text="dharma", translation="duty")` |

### Edge Cases

- Empty vocabularies array → empty list
- Vocabularies with Sanskrit diacritics preserved

---

## Test: Parse Quote

**ID**: T060
**Requirement**: R007
**Type**: Functional

### Scenario

**Given**: Quote JSON object
**When**: Parsed
**Then**: Author and text mapped

### Examples

| Input | Expected |
|-------|----------|
| `{"author": "Gandhi", "text": "The Gita..."}` | `Quote(author="Gandhi", text="The Gita...")` |

### Edge Cases

- Long quote text (>1000 chars)
- Author with title (e.g., "Mahatma Gandhi")

---

## Test: Parse Empty Chapter Slokas

**ID**: T070
**Requirement**: R005
**Type**: Edge Case

### Scenario

**Given**: Chapter JSON with empty or null slokas
**When**: Parsed
**Then**: Entity has empty slokas list

### Examples

| slokas field | entity.slokas |
|--------------|---------------|
| `[]` | `[]` |
| `null` | `[]` |

---

## Test: Parse Empty Shloka Vocabularies

**ID**: T071
**Requirement**: R006
**Type**: Edge Case

### Scenario

**Given**: Shloka JSON with empty or null vocabularies
**When**: Parsed
**Then**: Entity has empty vocabularies list

### Examples

| vocabularies field | entity.vocabularies |
|--------------------|---------------------|
| `[]` | `[]` |
| `null` | `[]` |

---

## Integration Flow: Full Chapter Parse

End-to-end test for chapters endpoint response:

```
Raw JSON → Unwrap Response → Parse Chapters → Generate IDs → Entity List
```

### Scenario

**Given**: Full chapters API response for book 2
**When**: Parsed through entire pipeline
**Then**: All chapters, slokas, vocabularies have correct IDs

### Steps

1. Receive raw API response
2. Unwrap `{code: 0, data: [...]}`
3. Parse each chapter with bookId
4. Verify chapter IDs: 201, 202, ..., 218
5. Verify nested slokas have correct chapterId references
6. Verify vocabularies reference correct slokaId

---

## Error Scenarios

### Test: Missing Required Field

**ID**: E001
**Requirement**: R002-R006

**Given**: JSON missing required field (e.g., `name`)
**When**: Parsed
**Then**:
- Throw parsing exception with field name
- Include JSON context in error message
- Allow caller to handle gracefully

---

### Test: Wrong Field Type

**ID**: E002
**Requirement**: R002-R006

**Given**: JSON with wrong type (e.g., `"id": "not-a-number"`)
**When**: Parsed
**Then**:
- Throw parsing exception with type info
- Include expected vs actual type

---

## Test Coverage Matrix

| Requirement ID | Test IDs | Status |
|----------------|----------|--------|
| R001 (Wrapper) | T001, T002, T003 | Covered |
| R002 (Language) | T010 | Covered |
| R003 (Book) | T020 | Covered |
| R004 (Chapter) | T030 | Covered |
| R005 (Shloka) | T040, T041, T042, T070 | Covered |
| R006 (Vocabulary) | T050, T071 | Covered |
| R007 (Quote) | T060 | Covered |
| R008 (ID Gen) | T030, T040 | Covered |

---

## Notes

- Test with real API response samples from legacy code
- Use property-based testing for ID generation formula
- Consider fuzzing for malformed JSON edge cases

---

## Approval

- [ ] Reviewed by: [name]
- [ ] Approved on: [date]
- [ ] Notes: [any conditions or clarifications]
