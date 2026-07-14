# Code to Flow Mapping

## Overview

Maps analyzed code modules to generated flows.

## Flow Type Detection Rules

| Indicator | Flow Type |
|-----------|-----------|
| `*.test.*`, `*.spec.*`, `__tests__/` | TDD |
| `components/`, `*.tsx`, `*.vue`, `templates/` | VDD |
| `README.md`, public exports, API docs | DDD |
| Internal logic, no UI, no public API | SDD |

## Mapping Table

| Code Path | Flow | Type | Action | Status | Notes |
|-----------|------|------|--------|--------|-------|
| `legacy/legacy_bhagavadgita.book_swift/Gita/Model/DataAccess/DataClasses/` | sdd-bhagavadgita-book-flutter-refactoring | SDD | UPDATED | DRAFT | Domain entities documented |
| `legacy/legacy_bhagavadgita.book_java/app/src/main/java/com/ethnoapp/bgita/model/` | sdd-bhagavadgita-book-flutter-refactoring | SDD | UPDATED | DRAFT | Same entities, confirms parity |
| `legacy/legacy_bhagavadgita.book_swift/Gita/Model/DataAccess/GitaRequestManager.swift` | sdd-bhagavadgita-book-flutter-refactoring | SDD | UPDATED | DRAFT | API contract documented |
| `legacy/legacy_bhagavadgita.book_java/app/src/main/java/com/ethnoapp/bgita/server/DataService.java` | sdd-bhagavadgita-book-flutter-refactoring | SDD | UPDATED | DRAFT | Same API endpoints |
| `legacy/legacy_bhagavadgita.book.db/Books/` | sdd-gitabook-database | SDD | UPDATED | DRAFT | CSV schema validation |
| `legacy/legacy_bhagavadgita.book_swift/Gita/ViewControllers/` | sdd-bhagavadgita-book-flutter-refactoring | SDD | UNCHANGED | DRAFT | UI layer, not documented |
| `legacy/legacy_bhagavadgita.book_java/app/src/main/java/com/ethnoapp/bgita/screens/` | sdd-bhagavadgita-book-flutter-refactoring | SDD | UNCHANGED | DRAFT | UI layer, not documented |
| `legacy/legacy_bhagavadgita.book.db/devices/` | - | - | UNCHANGED | - | Analytics only, out of scope |

### Action Values
- **CREATED** - New flow created
- **UPDATED** - Existing flow appended to (additive changes only)
- **UNCHANGED** - Flow exists, no new information found
- **CONFLICT** - Analysis contradicts existing documentation (needs reconciliation)

## ADR Mapping

| Code Pattern | ADR | Type | Status |
|--------------|-----|------|--------|
| Audio stored as paths not BLOBs | (in sdd-gitabook-database) | constraining | CONFIRMED |
| Single comment per sloka | (in sdd-gitabook-database) | constraining | CONFIRMED |
| Bookmarks stored locally only | (in sdd-bhagavadgita-book-flutter-refactoring) | constraining | CONFIRMED |

No new ADRs needed - all architectural decisions already documented in existing SDD flows.

## Unmapped (needs manual review)

| Code Path | Reason |
|-----------|--------|
| `legacy/legacy_bhagavadgita.book_swift/Gita/Libraries/` | Third-party libs, not domain-specific |
| `legacy/legacy_bhagavadgita.book_java/app/src/main/java/com/ironwaterstudio/` | Framework code, not domain-specific |
| `legacy/legacy_bhagavadgita.book.db/devices/Gita_Devices.csv` | Analytics data, out of scope for Flutter migration |

## Entity to Flow Mapping

| Entity | Flow | Location |
|--------|------|----------|
| Language | sdd-gitabook-database | Content domain |
| Book | sdd-gitabook-database | Content domain |
| Chapter | sdd-gitabook-database | Content domain |
| Shloka | sdd-gitabook-database | Content domain |
| Vocabulary | sdd-gitabook-database | Content domain |
| Quote | sdd-gitabook-database | Content domain |
| Bookmark | sdd-bhagavadgita-book-flutter-refactoring | User data domain |
| Note | sdd-bhagavadgita-book-flutter-refactoring | User data domain |

---

*Updated by /legacy analysis - 2026-04-29*
