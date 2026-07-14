# Test Cases: User Data Persistence (Bookmarks & Notes)

> Version: 1.0
> Status: DRAFT
> Last Updated: 2026-04-29

## Overview

Test cases for bookmark and note persistence. Tests verify CRUD operations, soft delete behavior, content refresh survival, and edge cases.

---

## Bookmark Tests

### Test: Create Bookmark

**ID**: T101
**Requirement**: R101
**Type**: Functional

### Scenario

**Given**: Verse at chapter 5, sloka 12 is not bookmarked
**When**: User bookmarks the verse
**Then**: Bookmark record created with correct data

### Examples

| Chapter | Sloka | Expected Record |
|---------|-------|-----------------|
| 1 | 1 | `{chapterOrder: 1, shlokaOrder: 1, isDeleted: false}` |
| 5 | 12 | `{chapterOrder: 5, shlokaOrder: 12, isDeleted: false}` |
| 18 | 78 | `{chapterOrder: 18, shlokaOrder: 78, isDeleted: false}` |

### Assertions

- Record has auto-generated ID
- `createdAt` is current timestamp (±1 second)
- `isDeleted` is false

---

### Test: Create Bookmark - Duplicate

**ID**: T102
**Requirement**: R101
**Type**: Edge Case

### Scenario

**Given**: Verse at chapter 5, sloka 12 is already bookmarked
**When**: User bookmarks the same verse again
**Then**: No duplicate created, existing bookmark preserved

### Assertions

- Only one record exists for (5, 12)
- Original `createdAt` preserved
- `isDeleted` remains false

---

### Test: Remove Bookmark (Soft Delete)

**ID**: T103
**Requirement**: R102
**Type**: Functional

### Scenario

**Given**: Verse at chapter 5, sloka 12 is bookmarked
**When**: User un-bookmarks the verse
**Then**: Bookmark soft-deleted (isDeleted = true)

### Assertions

- Record still exists in database
- `isDeleted` is now true
- `createdAt` unchanged

---

### Test: Re-bookmark After Soft Delete

**ID**: T104
**Requirement**: R101, R102
**Type**: Edge Case

### Scenario

**Given**: Verse was bookmarked then un-bookmarked (soft deleted)
**When**: User bookmarks the verse again
**Then**: Bookmark is reactivated

### Assertions

- Same record updated (not new record created)
- `isDeleted` set back to false
- New `createdAt` timestamp (or keep original - design decision)

---

### Test: List Active Bookmarks

**ID**: T105
**Requirement**: R103
**Type**: Functional

### Scenario

**Given**: Database has bookmarks: (1,1 active), (2,5 deleted), (3,10 active)
**When**: Active bookmarks are queried
**Then**: Returns only active bookmarks, ordered by date

### Examples

| Database State | Query Result |
|---------------|--------------|
| 3 active, 2 deleted | 3 bookmarks returned |
| 0 active, 5 deleted | 0 bookmarks returned |
| 0 bookmarks | empty list |

### Assertions

- Deleted bookmarks NOT in result
- Order is newest first (by createdAt DESC)

---

### Test: Check If Bookmarked - True

**ID**: T106
**Requirement**: R104
**Type**: Functional

### Scenario

**Given**: Verse at chapter 5, sloka 12 has active bookmark
**When**: `isBookmarked(5, 12)` is called
**Then**: Returns `true`

---

### Test: Check If Bookmarked - False (Not Exists)

**ID**: T107
**Requirement**: R104
**Type**: Functional

### Scenario

**Given**: Verse at chapter 5, sloka 12 has no bookmark record
**When**: `isBookmarked(5, 12)` is called
**Then**: Returns `false`

---

### Test: Check If Bookmarked - False (Deleted)

**ID**: T108
**Requirement**: R104
**Type**: Edge Case

### Scenario

**Given**: Verse at chapter 5, sloka 12 has deleted bookmark
**When**: `isBookmarked(5, 12)` is called
**Then**: Returns `false`

---

### Test: Bookmarks Survive Content Refresh

**ID**: T109
**Requirement**: R105
**Type**: Integration

### Scenario

**Given**: Bookmarks exist for chapters 1, 5, 18
**When**: Content tables are completely replaced (snapshot refresh)
**Then**: All bookmarks still exist and are valid

### Steps

1. Create bookmarks for (1,1), (5,12), (18,78)
2. Execute content snapshot replacement (delete + insert content tables)
3. Query bookmarks
4. Verify all 3 bookmarks present
5. Verify bookmarks resolve to correct verses in new content

---

## Note Tests

### Test: Create Note

**ID**: T201
**Requirement**: R201
**Type**: Functional

### Scenario

**Given**: Verse has no existing note
**When**: User saves note text
**Then**: Note record created

### Examples

| Sloka ID | Note Text | Expected |
|----------|-----------|----------|
| 201001 | "Important verse" | Record created |
| 201001 | "Long text..." (1000 chars) | Record created |

### Assertions

- Record has auto-generated ID
- `updatedAt` is current timestamp
- Text stored exactly as provided

---

### Test: Update Existing Note

**ID**: T202
**Requirement**: R201
**Type**: Functional

### Scenario

**Given**: Verse already has a note
**When**: User saves new note text
**Then**: Existing note updated (not new record)

### Assertions

- Only one note record for sloka
- Text is new value
- `updatedAt` updated to current time

---

### Test: Read Note - Exists

**ID**: T203
**Requirement**: R202
**Type**: Functional

### Scenario

**Given**: Verse has a saved note
**When**: Note is queried
**Then**: Returns note text

---

### Test: Read Note - Not Exists

**ID**: T204
**Requirement**: R202
**Type**: Functional

### Scenario

**Given**: Verse has no note
**When**: Note is queried
**Then**: Returns `null`

---

### Test: Delete Note (Empty Text)

**ID**: T205
**Requirement**: R201
**Type**: Edge Case

### Scenario

**Given**: Verse has an existing note
**When**: User saves empty string as note
**Then**: Note record deleted

### Assertions

- No record exists for sloka after operation
- Subsequent read returns `null`

---

### Test: Note with Unicode

**ID**: T206
**Requirement**: R201
**Type**: Edge Case

### Scenario

**Given**: User writes note with Sanskrit/Cyrillic/emoji
**When**: Note is saved and retrieved
**Then**: All characters preserved exactly

### Examples

| Input | Retrieved |
|-------|-----------|
| "धर्म means duty" | "धर्म means duty" |
| "Важный стих" | "Важный стих" |
| "Great verse! 🙏" | "Great verse! 🙏" |

---

### Test: Notes Survive Content Refresh

**ID**: T207
**Requirement**: R203
**Type**: Integration

### Scenario

**Given**: Notes exist for various slokas
**When**: Content tables are replaced
**Then**: Notes still accessible (if sloka IDs stable)

### Consideration

If sloka IDs change during refresh, notes may orphan. Test verifies:
- Notes table not deleted during content refresh
- Warning: if ID generation changes, notes may point to wrong verses

---

## Performance Tests

### Test: Bookmark Check Performance

**ID**: P001
**Requirement**: R104
**Type**: Performance

### Scenario

**Given**: Database has 1000 bookmarks
**When**: `isBookmarked(x, y)` called 100 times
**Then**: Average time < 10ms per call

### Index Requirement

Index on `(chapter_order, sloka_order) WHERE is_deleted = 0`

---

### Test: Bookmark List Performance

**ID**: P002
**Requirement**: R103
**Type**: Performance

### Scenario

**Given**: Database has 500 active bookmarks
**When**: Active bookmarks list queried
**Then**: Response time < 100ms

---

## Error Scenarios

### Test: Invalid Chapter Order

**ID**: E101
**Requirement**: R101

**Given**: Attempt to bookmark with chapterOrder = 0 or > 18
**When**: Bookmark operation executed
**Then**: Validation error thrown (or handled gracefully)

---

### Test: Invalid Sloka Order

**ID**: E102
**Requirement**: R101

**Given**: Attempt to bookmark with shlokaOrder <= 0
**When**: Bookmark operation executed
**Then**: Validation error thrown

---

### Test: Database Full

**ID**: E103
**Requirement**: R101, R201

**Given**: Device storage is full
**When**: User tries to save bookmark or note
**Then**: Graceful error message, no crash

---

## Test Coverage Matrix

| Requirement ID | Test IDs | Status |
|----------------|----------|--------|
| R101 (Create Bookmark) | T101, T102, T104 | Covered |
| R102 (Remove Bookmark) | T103, T104 | Covered |
| R103 (List Bookmarks) | T105, P002 | Covered |
| R104 (Check Bookmarked) | T106, T107, T108, P001 | Covered |
| R105 (Survive Refresh) | T109 | Covered |
| R201 (Create/Update Note) | T201, T202, T205, T206 | Covered |
| R202 (Read Note) | T203, T204 | Covered |
| R203 (Note Survives) | T207 | Covered |

---

## Notes

- Use in-memory database for unit tests (fast)
- Use real database for integration tests (T109, T207)
- Consider property-based testing for valid order ranges

---

## Approval

- [ ] Reviewed by: [name]
- [ ] Approved on: [date]
- [ ] Notes: [any conditions or clarifications]
