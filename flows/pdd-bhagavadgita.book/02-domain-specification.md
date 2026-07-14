# Domain specification: Bhagavad Gita Book

> Version: 2.0 (Flutter canonical client)  
> Status: DRAFT  
> Last updated: 2026-05-04

## 1. Glossary

| Term | Definition |
|------|------------|
| **Book** | Translation/edition within a **Language**; `id`, `languageId`, `name`, `initials`, `chaptersCount` (see DTOs under `lib/data/remote/dto/`). |
| **Chapter** | Ordered section of a book; `bookId`. |
| **Shloka** | Verse unit; primary reader surface in Flutter: **`sloka_screen`** (`lib/features/reader/sloka_screen.dart`). |
| **Quote** | Object from `Data/Quotes`; DTO `quote_dto.dart`. |
| **Device token** | Optional `Authorization: Gita <token>` header (legacy Android); Flutter client should preserve header contract if backend still expects it. |
| **Api envelope** | JSON: `code == 0` + `data` = success; see `lib/data/remote/legacy_envelope.dart`. |
| **Legacy apps** | Swift + Java trees under `legacy/` — **not** part of the runtime domain; reference material only. |

## 2. Core entities and relationships

```
Language 1──* Book 1──* Chapter 1──* Shloka (local DB + optional downloaded assets)
                    └── audio / files via Flutter audio controllers
Bookmarks / Notes / user progress: local persistence (`user_data_repository`, Drift tables)
```

## 3. Remote API (domain contract)

Unchanged contract for backend compatibility:

**Base path**: `{HOST}/api/` (production must move to **HTTPS** in Flutter configs).

**Transport**: POST, JSON body; params shape as legacy (`Data/Books` expects `ids`, etc.) — implemented in **`legacy_api_client.dart`**.

**Actions** (authoritative list for MVP parity):

| Action | Params | Result |
|--------|--------|--------|
| `Data/Languages` | empty | `Language` list |
| `Data/Books` | `ids` | `Book` list |
| `Data/Chapters` | `bookId` | `Chapter` list |
| `Data/Quotes` | empty | `Quote` |

**Headers**: `accept-language`; optional `Authorization: Gita <token>` when device token exists.

**Evidence in repo**: `lib/data/remote/legacy_api_client.dart`, DTOs alongside; legacy Swift `GitaRequestManager.swift` / Android `DataService.java` for dispute resolution only.

## 4. Local persistence domain (Flutter)

- Implementation: **`lib/data/local/`** — `app_database.dart`, `tables.dart`, `snapshot_repository.dart`, `seed_installer.dart`, platform connections (`app_database_connection_*.dart`).
- **Migrations**: explicit Drift/schema migrations; avoid wholesale DB delete unless explicitly approved (legacy Swift replaced file on `user_version` bump).

## 5. Client rules — legacy vs Flutter

| Topic | Legacy behavior | Flutter stance |
|-------|-----------------|----------------|
| Incomplete downloads on cold start | Swift cleared `DownloadInfo` | Define in sync/bootstrap policy (`bootstrap_coordinator`, download controllers) |
| Selected shloka on launch | Swift reset daily | **Product decision** — default: persist last position (better UX); document if diverging |
| Search panel lifecycle | Android saved state keys | Flutter: preserve search state in `SearchRoute` / controller pattern |

## 6. Third-party (consolidation target)

- Replace siloed **GA iOS** + **Play Analytics Java** with a **single** analytics approach from Flutter (e.g. Firebase Analytics for both platforms, subject to SDD).
- **Firebase**: one project strategy for push if still required.
- **Facebook SDK** (legacy Android): re-evaluate; do not port blindly unless product requires.

## 7. Traceability to charter

| Charter goal | Supported by |
|--------------|----------------|
| Single codebase | §1 Glossary + §4 Flutter paths |
| Offline read | §4 Local persistence |
| API stability | §3 |

## Approvals

**Approval phrase to advance**: “domain specification approved”
