# ADR-003: Offline-First Architecture

## Meta

- **Number**: ADR-003
- **Type**: enabling
- **Status**: DRAFT
- **Created**: 2026-04-29
- **Author**: Legacy Analysis
- **Source**: `legacy/legacy_bhagavadgita.book_swift`, `legacy/legacy_bhagavadgita.book_java`

## Context

The Bhagavad Gita app is primarily a reading/study application. Users should be able to:
- Read scripture offline (planes, retreats, areas without connectivity)
- Access bookmarks and notes without network
- Have the app work immediately on launch

Analysis of legacy iOS and Android apps shows they implement "download then read" pattern:
1. On first launch: download book content from server
2. Store locally in SQLite
3. All reading happens from local database
4. Subsequent launches: read from local, optionally sync updates

This pattern must be preserved and improved for Flutter.

## Decision Drivers

- **User Experience**: App must be usable without waiting for network
- **Content Freshness**: Users should get updates when available
- **Data Integrity**: User bookmarks/notes must never be lost
- **Battery/Network**: Minimize unnecessary network requests

## Legacy Behavior Analysis

### iOS Download Flow (from GitaRequestManager.swift)

```
Splash Screen
    │
    ├── Check if book downloaded (Book.isDownloaded)
    │
    ├── If not: call Data/Chapters, save to DB
    │
    ├── Mark book as downloaded
    │
    └── Navigate to Contents
```

### Android Download States (from Book.java:17-20)

```java
public static final int STATUS_NO = -1;           // Not downloaded
public static final int STATUS_PROGRESS_LOAD = 0; // Downloading
public static final int STATUS_PROGRESS_DELETE = 1; // Deleting
public static final int STATUS_SUCCESS = 2;       // Downloaded
public static final int STATUS_ERROR = 3;         // Failed
```

### Reading Flow (both platforms)

```
Contents Screen
    │
    └── Load chapters from LOCAL DB only
        │
        └── Chapter.getList(bookId) → SQLite query
```

## Considered Options

### Option 1: Download-Then-Read (Legacy Pattern)

**Description**: Download full book before use, read from local

**Pros**:
- Simple model
- Guaranteed offline availability
- No network requests during reading

**Cons**:
- Blocks first use until download completes
- All-or-nothing download
- No partial content

**Estimated Effort**: Low

### Option 2: Stale-While-Revalidate (Chosen)

**Description**: Use local data immediately, sync in background

**Pros**:
- Instant app start
- Progressive updates
- Better UX for returning users
- Still works offline

**Cons**:
- More complex sync logic
- Potential stale data visibility

**Estimated Effort**: Medium

### Option 3: Online-First with Cache

**Description**: Always try network first, fall back to cache

**Pros**:
- Always fresh data when online

**Cons**:
- Slow startup with poor network
- Poor offline experience
- Against app purpose (study tool)

**Estimated Effort**: Low

### Option 4: Full Offline-Only

**Description**: Bundle all content in app, no network

**Pros**:
- Perfect offline
- Zero network dependency

**Cons**:
- Large app size (audio files)
- No content updates
- No quote-of-the-day feature

**Estimated Effort**: Low

## Decision

We will use **Option 2: Stale-While-Revalidate** because:

- Best balance of instant availability and freshness
- Users with existing data don't wait
- Background sync provides updates transparently
- Degrades gracefully to pure offline

## Architecture Design

### Startup Flow

```
App Launch
    │
    ▼
Open Local DB
    │
    ▼
Check Snapshot Exists?
    │
    ├── NO → Load Bundled Seed → Save to DB → Mark ready
    │
    └── YES → Mark ready immediately
    │
    ▼
Navigate to Main App
    │
    ▼
[Background] Check network + freshness
    │
    ├── Stale + Online → Sync new data → Atomic replace
    │
    └── Fresh OR Offline → Skip sync
```

### Freshness Policy

```
STALE_THRESHOLD = 24 hours

is_stale = (now - snapshot.fetched_at) > STALE_THRESHOLD

sync_decision:
  - if is_stale AND network_available: SYNC
  - if not is_stale: SKIP
  - if no network: SKIP (will retry later)
```

### Sync Strategy

```
Sync Process:
  1. Fetch Data/Languages
  2. Fetch Data/Books
  3. Fetch Data/Chapters for each downloaded book
  4. Write all to staging tables
  5. Atomic swap: rename staging → main tables
  6. Update snapshot_meta with new timestamp
  7. UI automatically refreshes via reactive queries
```

### Data Layers

```
┌─────────────────────────────────────────────┐
│                 UI Layer                      │
│  (reads via reactive streams from DB)        │
└─────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────┐
│              Repository Layer                 │
│  SnapshotRepository (content)                │
│  UserDataRepository (bookmarks, notes)       │
└─────────────────────────────────────────────┘
                    │
        ┌───────────┴───────────┐
        ▼                       ▼
┌───────────────┐       ┌───────────────┐
│ Content Store │       │  User Store   │
│ (replaceable) │       │ (preserved)   │
└───────────────┘       └───────────────┘
        │                       │
        └───────────┬───────────┘
                    ▼
┌─────────────────────────────────────────────┐
│           SQLite (via Drift)                  │
└─────────────────────────────────────────────┘
```

### Bundled Seed

App includes minimal seed snapshot in assets:
- All languages
- All books metadata
- One default book with all chapters/slokas
- No audio files (download separately)

This ensures app works on first launch even without network.

## Consequences

### Positive

- Instant app start for returning users
- Works completely offline
- Background sync doesn't block reading
- User data isolated from content updates

### Negative

- First-time users need network for full content
- Brief period of stale data possible
- More complex than pure download-first

### Neutral

- Bundled seed adds ~1-2MB to app size
- Sync metadata storage required

## Implementation Notes

- Use `Connectivity` package to check network state
- Implement `SyncOrchestrator` to manage background sync
- Use Drift's `watch` queries for reactive UI updates
- Store `fetched_at` in `snapshot_meta` table
- Consider WorkManager/BGTaskScheduler for periodic sync

## Related Decisions

- ADR-001: API Contract Design (defines what we sync)
- ADR-002: Local Storage Strategy (where we store it)

## Related Specs

- `flows/sdd-bhagavadgita-book-flutter-refactoring/`: Full app architecture
- `flows/sdd-legacy-api-client/`: API client for sync

## References

- Swift splash: `legacy/legacy_bhagavadgita.book_swift/Gita/ViewControllers/SplashViewController.swift`
- Android splash: `legacy/legacy_bhagavadgita.book_java/app/src/main/java/com/ethnoapp/bgita/screens/SplashActivity.java`

## Tags

offline architecture sync caching availability

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
