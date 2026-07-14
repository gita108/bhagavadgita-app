# Legacy Analysis Status

## Mode

- **Current**: COMPLETE
- **Type**: BFS (breadth-first analysis) + New Flow Creation

## Sources

- **Path 1**: `legacy/legacy_bhagavadgita.book_swift` (iOS Swift app)
- **Path 2**: `legacy/legacy_bhagavadgita.book_java` (Android Java app)
- **Path 3**: `legacy/legacy_bhagavadgita.book.db` (Database CSV exports)

## Traversal State

> See _traverse.md for full recursion stack

- **Current Node**: / (root)
- **Current Phase**: COMPLETE
- **Stack Depth**: 0
- **All Children**: DONE

## Progress

- [x] Root node created
- [x] Swift domain model analyzed
- [x] Java domain model analyzed
- [x] DB CSV exports analyzed
- [x] API contracts documented
- [x] Platform differences identified
- [x] Existing flows matched
- [x] Flows updated with legacy additions
- [x] **NEW: ADRs created (3)**
- [x] **NEW: SDDs created (3)**
- [x] **NEW: TDDs created (2)**
- [x] Traversal complete

## Statistics

- **Nodes created**: 5 (root, swift-model, java-model, db-data, api-contracts)
- **Nodes completed**: 5
- **Max depth reached**: 1
- **Files analyzed**:
  - Swift: 8 model files + 1 API file
  - Java: 7 model files + 1 API file
  - CSV: 7 data files
- **Entities discovered**: 7 (Language, Book, Chapter, Shloka, Vocabulary, Quote, Bookmark)
- **Flows updated**: 2 (sdd-bhagavadgita-book-flutter-refactoring, sdd-gitabook-database)
- **ADRs created**: 3
- **SDDs created**: 3
- **TDDs created**: 2
- **Total new flows**: 8
- **Pending review**: 0

## New Flows Created (2026-04-29)

### ADRs

| Flow | Title | Status |
|------|-------|--------|
| `adr-001-api-contract/` | Backend API Contract Design | DRAFT |
| `adr-002-local-storage/` | Local Storage Strategy (SQLite + Drift) | DRAFT |
| `adr-003-offline-first/` | Offline-First Architecture | DRAFT |

### SDDs

| Flow | Title | Status |
|------|-------|--------|
| `sdd-legacy-domain-model/` | Domain Model (7 entities, Dart) | DRAFT |
| `sdd-legacy-api-client/` | API Client (4 endpoints, Dio) | DRAFT |
| `sdd-legacy-database-schema/` | Database Schema (Drift tables) | DRAFT |

### TDDs

| Flow | Title | Status |
|------|-------|--------|
| `tdd-api-parsing/` | API Response Parsing (20+ tests) | TESTS_DEFINED |
| `tdd-user-data-persistence/` | Bookmark/Note Persistence (20+ tests) | TESTS_DEFINED |

## Actions Completed

### 2026-04-29 (Session 2): New Flow Creation

1. **Created 3 ADRs**:
   - ADR-001: API Contract (POST endpoints, response wrapper)
   - ADR-002: Local Storage (SQLite + Drift, content/user separation)
   - ADR-003: Offline-First (stale-while-revalidate, bundled seed)

2. **Created 3 SDDs**:
   - Domain Model: 7 entities with Dart code, JSON serialization
   - API Client: LegacyApiClient interface, Dio implementation
   - Database Schema: Full Drift tables, DAOs, migrations

3. **Created 2 TDDs**:
   - API Parsing: 20+ test cases for JSON parsing, ID generation
   - User Data: 20+ test cases for bookmarks, notes, soft delete

### 2026-04-29 (Session 1): Full Legacy Analysis

1. **Scanned existing flows**:
   - sdd-gitabook-database
   - sdd-gitabook-structure
   - sdd-gitabook-translation
   - sdd-gitabook-generate-md
   - sdd-gitanjali-flutter-refactoring
   - sdd-bhagavadgita-book-flutter-refactoring

2. **Analyzed Swift codebase**:
   - Domain model: 7 entities
   - API client: GitaRequestManager with 4 endpoints
   - Local DB: SQLite via DbHelper

3. **Analyzed Java codebase**:
   - Same entities with platform-specific differences
   - API client: DataService with same endpoints
   - Local DB: SQLite via custom ORM

4. **Analyzed DB exports**:
   - 7 CSV files with production data
   - Validated schema matches code

5. **Updated existing flows**:
   - Added "Legacy Analysis Additions" to sdd-bhagavadgita-book-flutter-refactoring
   - Added "Legacy Analysis Additions" to sdd-gitabook-database

## Key Findings

### Unified Domain Model

```
Language → Book → Chapter → Shloka → Vocabulary
                              ↓
                           Quote (standalone)
                           Bookmark (user data)
```

### API Endpoints (confirmed)

- `Data/Languages` - POST, returns all languages
- `Data/Books` - POST, returns books by language IDs
- `Data/Chapters` - POST, returns chapters with nested slokas and vocabularies
- `Data/Quotes` - POST, returns random quote

### Key Architectural Decisions

1. **Maintain legacy API contract** - no backend changes needed
2. **SQLite + Drift** for local storage
3. **Separate content vs user tables** - content replaceable, user data preserved
4. **Client-side ID generation** - deterministic IDs from bookId + order
5. **Stale-while-revalidate** - local first, background sync

---

*Completed by /legacy - 2026-04-29*
