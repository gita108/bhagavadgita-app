# Specifications: BhagavadGita Book Flutter Refactoring v2

> Version: 1.0  
> Status: DRAFT  
> Last Updated: 2026-04-29  
> Requirements: `flows/sdd-bhagavadgita.book-flutter-refactoring-v2/01-requirements.md`

## Overview

v2 migration consolidates legacy Java (`legacy_bhagavadgita.book_java`), Swift (`legacy_bhagavadgita.book_swift`), and legacy DB (`legacy_bhagavadgita.book_db`) behavior into Flutter runtime `app/bhagavadgita.book` by:
- keeping legacy backend contract (`Data/Languages`, `Data/Books`, `Data/Chapters`, `Data/Quotes`);
- preserving offline-first bootstrap via bundled seed and local snapshot;
- atomically replacing content snapshot without affecting user tables (`bookmarks`, `notes`);
- unifying domain mapping and repository usage so that Java/Swift stay read-only references.

## Affected Systems

| System | Impact | Notes |
|--------|--------|-------|
| `app/bhagavadgita.book/lib/app/bootstrap` | Modify | Startup orchestration and splash behavior |
| `app/bhagavadgita.book/lib/app/sync` | Modify | Legacy API sync pipeline and refresh policy |
| `app/bhagavadgita.book/lib/data/local` | Modify | Snapshot/content schema and user-data isolation |
| `app/bhagavadgita.book/lib/data/remote` | Modify | DTO mapping for legacy API contract |
| `app/bhagavadgita.book/lib/features/*` | Modify | Reader/search/settings/bookmarks UX parity |
| `legacy/legacy_bhagavadgita.book_java` | Reference only | Migration source |
| `legacy/legacy_bhagavadgita.book_swift` | Reference only | Migration source |
| `legacy/legacy_bhagavadgita.book_db` | Reference only | Data model and content source |

## Architecture

### Component Diagram

```text
SplashScreen
  -> BootstrapCoordinator
      -> SeedInstaller (first install fallback snapshot)
      -> SyncOrchestrator.startupSync() [background]
          -> LegacyApiClient (Data/* endpoints)
          -> SnapshotRepository.replaceSnapshot() [atomic]
              -> Drift SQLite content tables
User actions (bookmark/note/search/settings)
  -> UserDataRepository + feature repositories
  -> Drift SQLite user tables (isolated)
```

### Data Flow

```text
Bundled seed JSON -> SeedInstaller -> content tables + snapshot_meta
Legacy API -> DTO parsing -> companion mapping -> replaceSnapshot transaction
UI reads local DB streams first; sync never blocks initial render
Bookmarks/Notes writes always go to user tables only
```

## Interfaces

### New Interfaces

```dart
abstract interface class ContentRepository {
  Stream<List<ChapterView>> watchChapters(int bookId);
  Stream<List<SlokaView>> watchSlokas(int chapterId);
  Future<void> refreshContent({bool force = false});
}

abstract interface class UserRepository {
  Stream<bool> watchBookmark(int slokaId);
  Stream<String?> watchNote(int slokaId);
  Future<void> setBookmark(int slokaId, bool value);
  Future<void> saveNote(int slokaId, String note);
}
```

### Modified Interfaces

- `BootstrapCoordinator.run()` must continue to return non-blocking startup result while scheduling sync in background.
- `SyncOrchestrator.refreshNow()` must support full snapshot replacement and explicit failure reason for telemetry/logging.
- `LegacyApiClient` must keep legacy envelope behavior and graceful parse fallback on partially missing fields.

## Data Models

### New Types

```dart
enum SnapshotSource { bundledSeed, remoteSync }

class MigrationMapEntry {
  const MigrationMapEntry({
    required this.legacyEntity,
    required this.flutterTable,
    required this.transformRules,
  });

  final String legacyEntity;
  final String flutterTable;
  final List<String> transformRules;
}
```

### Schema Changes

- Keep current Drift content tables as baseline: `languages`, `books`, `chapters`, `slokas`, `vocabularies`, `snapshot_meta`.
- Keep user tables isolated: `bookmarks`, `notes`.
- Add schema migration only when parity requires new fields from legacy DB (e.g. richer quote metadata, download state unification, language flags).
- Any new user-centric fields must not be stored in content snapshot tables.

## Behavior Specifications

### Happy Path

1. App starts, `SplashScreen` invokes `BootstrapCoordinator`.
2. If local snapshot exists, app proceeds immediately to content UI and schedules background sync.
3. If no snapshot, `SeedInstaller` installs bundled seed, then app proceeds and schedules background sync.
4. `SyncOrchestrator` calls legacy endpoints and atomically replaces content snapshot.
5. Reader/search/settings screens observe local streams and reflect updated content when sync completes.

### Edge Cases

| Case | Trigger | Expected Behavior |
|------|---------|-------------------|
| No network on cold start | API unavailable, no remote sync | Seed snapshot is used, app remains readable |
| Corrupt/empty API payload | `Data/Books` or `Data/Chapters` empty | Sync fails gracefully; existing snapshot preserved |
| Long sync time | Slow backend response | Startup remains non-blocking; user reads current local content |
| Partial migration parity gap | Legacy field not yet mapped | Feature degrades gracefully with clear TODO and fallback |
| Existing notes/bookmarks | Snapshot replacement runs | User tables remain untouched |

### Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `LegacyApiException` | Non-zero `code` in legacy envelope | Mark sync failed, keep old snapshot |
| Parse/type errors | Unexpected DTO structure | Catch and fail sync without DB corruption |
| Seed asset missing | Packaging/config issue | Show startup failure with retry action |
| DB write failure | IO/transaction problem | Roll back transaction; keep previous data |

## Dependencies

### Requires

- Drift database and generated schema files.
- Dio-based network layer for legacy endpoints.
- Bundled seed asset in `assets/seed`.
- Legacy mapping references from Java/Swift/DB sources.

### Blocks

- Final implementation task decomposition in `03-plan.md`.
- Release-readiness checks for Android/iOS parity.

## Integration Points

### External Systems

- Legacy backend API at `http://app.bhagavadgitaapp.online/api/`.
- App store build pipelines for iOS and Android (post-implementation).

### Internal Systems

- `lib/features/splash` for bootstrap state UX.
- `lib/features/contents`, `lib/features/reader`, `lib/features/search`, `lib/features/settings`.
- `lib/data/local/*` repositories and tables.
- `lib/data/remote/*` DTO and API envelope parsing.

## Testing Strategy

### Unit Tests

- [ ] `RefreshPolicy` decision logic for stale/fresh snapshot.
- [ ] `SyncOrchestrator` mapping and failure behavior.
- [ ] `SnapshotRepository.replaceSnapshot` keeps user tables intact.
- [ ] `SeedInstaller` cold-start install behavior.

### Integration Tests

- [ ] First launch offline -> seed install -> readable contents.
- [ ] Startup with existing snapshot -> immediate UI + background sync.
- [ ] Sync failure -> no data loss and no crash.
- [ ] Bookmark/note persistence across snapshot refresh.

### Manual Verification

- [ ] Verify chapter/sloka/navigation parity against legacy Java and Swift sample scenarios.
- [ ] Verify search results and settings persistence after app restart.
- [ ] Verify app behavior in airplane mode on first and subsequent launches.

## Migration / Rollout

1. Build migration mapping matrix Java+Swift+DB -> Flutter entities/repositories.
2. Implement parity in vertical slices (bootstrap, content sync, reader, user data, search, settings).
3. Validate offline-first invariants and snapshot atomicity.
4. Run platform smoke tests (Android/iOS).
5. Prepare release build and staged rollout checklist.

## Open Design Questions

- [ ] Audio playback parity included in v2 scope or deferred to v2.1?
- [ ] Strict UI parity with legacy screens or functional parity with Flutter-native navigation?
- [ ] Should quote-of-the-day become part of splash bootstrap payload?

## Approval

- [ ] Reviewed by: [name]
- [ ] Approved on: [date]
- [ ] Notes: [any conditions or clarifications]
