# Requirements: User Data Persistence (Bookmarks & Notes)

> Version: 1.0
> Status: DRAFT
> Last Updated: 2026-04-29
> Source: Legacy iOS/Android code analysis

## Problem Statement

Users create bookmarks and notes on specific verses. This data must:
- Persist across app restarts
- Survive content refresh/sync operations
- Be referenced by verse position (chapter + sloka order), not internal IDs
- Support soft delete for bookmarks (undo capability)

Legacy analysis shows iOS used separate Bookmarks table while Android stored `isBookmark` flag directly on Sloka. We choose the iOS approach for cleaner separation.

## User Stories

### Primary

**As a** reader
**I want** to bookmark verses I want to revisit
**So that** I can quickly find them later

**As a** student
**I want** to add notes to verses
**So that** I can record my understanding

### Secondary

**As a** user
**I want** my bookmarks preserved when content updates
**So that** I don't lose my study progress

## Critical Requirements

### R101: Create Bookmark

User can bookmark any verse. Bookmark stores:
- Chapter order (1-18)
- Shloka order (within chapter)
- Created timestamp
- Active/deleted state

### R102: Remove Bookmark (Soft Delete)

User can un-bookmark a verse:
- Bookmark row updated with `isDeleted = true`
- Row not physically deleted (allows undo)
- UI filters out deleted bookmarks

### R103: List Active Bookmarks

App can retrieve all active (non-deleted) bookmarks:
- Ordered by creation date (newest first)
- Used on Bookmarks screen

### R104: Check If Bookmarked

App can quickly check if a specific verse is bookmarked:
- Used to show bookmark icon state
- Must be fast (indexed lookup)

### R105: Bookmark Survives Content Refresh

When content is refreshed:
- Bookmarks table NOT touched
- Bookmarks use chapter_order + sloka_order (stable identifiers)
- After refresh, bookmarks still point to correct verses

### R201: Create/Update Note

User can add a note to any verse:
- One note per verse (upsert behavior)
- Updated timestamp tracked
- Empty note = delete note

### R202: Read Note

App can retrieve note for a specific verse:
- Returns note text or null if none
- Used when viewing verse detail

### R203: Note Survives Content Refresh

When content is refreshed:
- Notes table NOT touched
- Notes use sloka_id (may need migration strategy)

## Legacy Implementation Reference

### iOS: Bookmark.swift

```swift
// Lines 34-46
static func updateBookmarked(chapterOrder: Int, shlokaOrder: Int, bookmarked: Bool) {
    let cmd = DbCommand(connection: conn)
    cmd.text = bookmarked ?
        "INSERT OR REPLACE INTO Bookmarks (ChapterOrder, SlokaOrder, IsDeleted) VALUES (:ChapterOrder, :SlokaOrder, :IsDeleted)" :
        "UPDATE Bookmarks SET IsDeleted = :IsDeleted WHERE ChapterOrder = :ChapterOrder AND SlokaOrder = :SlokaOrder"
    // ...
}
```

### Android: Sloka.java

```java
// Lines 88-94
public boolean isBookmark() { return isBookmark; }
public void setBookmark(boolean bookmark) { isBookmark = bookmark; }

// Lines 98-102
public String getNote() { return note; }
public void setNote(String note) { this.note = note; }
```

## Acceptance Criteria

### Must Have

1. **Given** user views a verse
   **When** they tap bookmark icon
   **Then** bookmark is created with current timestamp

2. **Given** a bookmarked verse
   **When** user taps bookmark icon again
   **Then** bookmark is soft-deleted (isDeleted = true)

3. **Given** multiple bookmarks exist
   **When** user opens Bookmarks screen
   **Then** only active bookmarks shown, newest first

4. **Given** content is refreshed
   **When** bookmarks table is queried
   **Then** all bookmarks still reference correct verses

5. **Given** user adds note to verse
   **When** note is saved
   **Then** note persists and can be retrieved

6. **Given** user edits existing note
   **When** note is saved
   **Then** previous note is replaced (upsert)

### Should Have

- Undo for bookmark deletion (within session)
- Note character limit warning (>1000 chars)

### Won't Have (This Iteration)

- Bookmark folders/categories
- Note search
- Cloud sync of bookmarks/notes
- Export functionality

## Constraints

- **Technical**: Use SQLite via Drift
- **Technical**: Bookmarks must use position-based references
- **Performance**: Check bookmark state in <10ms
- **Dependencies**: ADR-002 (storage strategy)

## References

- Swift source: `legacy/legacy_bhagavadgita.book_swift/Gita/Model/DataAccess/DataClasses/Bookmark.swift`
- Java source: `legacy/legacy_bhagavadgita.book_java/app/src/main/java/com/ethnoapp/bgita/model/Sloka.java:88-102`
- ADR-002: Local Storage Strategy
- SDD: Legacy Database Schema

---

## Approval

- [ ] Reviewed by: [name]
- [ ] Approved on: [date]
- [ ] Notes: [any conditions or clarifications]
