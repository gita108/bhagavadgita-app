# Implementation Plan: Bhagavad Gita Book Layouts — Extra Parity (Flutter)

> Version: 1.0  
> Status: DRAFT  
> Last Updated: 2026-04-30  
> Baseline Specs: `../vdd-bhagavadgita.book-layouts/03-specifications.md`  
> Baseline Visuals: `../vdd-bhagavadgita.book-layouts/02-visual.md`

## Summary

Bring the Flutter app (`app/bhagavadgita.book`) closer to feature parity with legacy iOS/Android by implementing the “missing functional layer” behind the already-approved layouts:

- **Audio**: real playback (Sanskrit/Translation), background playback, and offline audio downloads with progress/resume.
- **Language & books**: allow selecting translation language/book (remove `bookId = 1` hardcode), and persist the selection.
- **Quotes**: show dynamic quote-of-the-day from API and (optionally) schedule local notifications.
- **Search & bookmarks UX**: search scope (All vs Bookmarks) + highlight; bookmarks list adds “note preview” and swipe-to-delete parity.

Constraints:
- Keep Drift schema changes minimal; prefer new tables only if unavoidable.
- Preserve the existing snapshot sync behavior (`SyncOrchestrator`) and UI layouts from baseline VDD.
- Favor incremental, testable slices: audio playback first, then downloads, then settings, then language selection, then polish.

## Legacy reference map (what to copy conceptually)

### iOS Swift legacy (`legacy/legacy_bhagavadgita.book_swift/`)

- **Playback**: `Gita/Model/AudioManager.swift`
  - Track completion detection, play/pause, delegate callback for “auto next”.
- **Download pipeline**: `Gita/Model/DownloadManager.swift`
  - Initial data flow, “ask to download audio”, background queue, limited parallelism, resume state, progress notifications.
- **Settings flags**: `Gita/Model/Settings.swift` (+ UI in `Gita/ViewControllers/SettingsViewController.swift`)
  - Toggles: Sanskrit audio, translation audio, autoplay, language/book/commentaries.
- **Background audio declaration**: `Gita/Info.plist` (`UIBackgroundModes: audio, fetch`)

### Android Java legacy (`legacy/legacy_bhagavadgita.book_java/`)

- **App screens present**: `app/src/main/AndroidManifest.xml`
  - `SplashActivity`, `GuideActivity`, `MainActivity`, `SettingsActivity`, `LanguagesActivity`, `QuoteActivity`.
- **Search entry**: `MainActivity` uses a search panel + `android.intent.action.SEARCH`.
- **Integrations**: GA campaign receiver, Firebase messaging service, Facebook app id meta-data.

### Legacy “books engine” (ObjC)

- **Shared audio player UI pattern**: `legacy/legacy-avadhuta/Classes/Interface/BUISharedAudioPlayerView.h`
  - “shrink/expand” player component with a slider and “no sound” label.
- **Bookmark layer separation**: `legacy/legacy-cookbook-swift/Classes/Data Core/BBookmarkManager.h`
- **Search modes**: `legacy/legacy-gitanjali-swift/Gitanjali/Classes/Interface/Search/BUISearchViewController.h`
  - Segmented control: multiple search modes (text/titles/comments).

## Task Breakdown

### Phase 1: Audio playback (functional) behind existing UI

#### Task 1.1: Introduce an audio domain model + controller (no downloads yet)
- **Description**: Implement “play/pause/seek/track selection (Sanskrit vs Translation)” and expose state to the existing `AudioPlayerBar`.
- **Files**:
  - `app/bhagavadgita.book/lib/features/shared/widgets/audio_player_bar.dart` - Modify (bind to controller; keep layout)
  - `app/bhagavadgita.book/lib/app/audio/audio_controller.dart` - Create
  - `app/bhagavadgita.book/lib/app/audio/audio_state.dart` - Create
  - `app/bhagavadgita.book/lib/features/reader/sloka_screen.dart` - Modify (connect bar to current sloka audio URLs)
- **Dependencies**: baseline layouts implementation
- **Legacy reference**: `legacy/legacy_bhagavadgita.book_swift/Gita/Model/AudioManager.swift`
- **Verification**:
  - Play/pause toggles state; position updates; “completed track” event fires
  - Track switch (Sanskrit/Translation) updates the playing source
- **Complexity**: High

#### Task 1.2: Add “auto-play next sloka” wiring
- **Description**: When enabled, completing a track automatically advances to next sloka and starts playback.
- **Files**:
  - `app/bhagavadgita.book/lib/features/settings/reader_settings.dart` - Extend (add `autoPlayNext`)
  - `app/bhagavadgita.book/lib/features/settings/settings_screen.dart` - Modify (add toggle under AUDIO)
  - `app/bhagavadgita.book/lib/features/reader/sloka_screen.dart` - Modify (advance navigation + rebind audio)
- **Dependencies**: Task 1.1
- **Legacy reference**: `legacy/legacy_bhagavadgita.book_swift/Gita/Model/AudioManager.swift` (delegate)
- **Verification**:
  - With Auto-play ON: playback of current sloka completes → next sloka opens/updates and starts
  - With Auto-play OFF: no automatic navigation
- **Complexity**: High

### Phase 2: Offline audio download & progress (settings parity)

#### Task 2.1: Define audio availability + download state model
- **Description**: Store per-(book, track) download state: Not downloaded / Downloading / Downloaded, total size (optional), progress, error, and resumable intent.
- **Files**:
  - `app/bhagavadgita.book/lib/app/audio/download/audio_download_state.dart` - Create
  - `app/bhagavadgita.book/lib/app/audio/download/audio_download_repository.dart` - Create
  - `app/bhagavadgita.book/lib/data/local/tables.dart` + drift gen - Modify (only if state cannot live in SharedPreferences)
- **Dependencies**: None
- **Legacy reference**: `legacy/legacy_bhagavadgita.book_swift/Gita/Model/DownloadInfo.swift` + `DownloadManager.swift`
- **Verification**:
  - State persists across restarts (in-progress can resume or re-start deterministically)
- **Complexity**: Medium/High (depending on persistence choice)

#### Task 2.2: Implement audio download worker (bounded concurrency + resume)
- **Description**: Download audio files referenced by slokas to app storage, with bounded concurrency, progress events, and cancellation/resume behavior.
- **Files**:
  - `app/bhagavadgita.book/lib/app/audio/download/audio_downloader.dart` - Create
  - `app/bhagavadgita.book/lib/app/audio/download/audio_path.dart` - Create (stable storage layout)
  - `app/bhagavadgita.book/lib/app/audio/download/audio_indexer.dart` - Create (enumerate which slokas have audio)
  - `app/bhagavadgita.book/lib/data/remote/legacy_api_client.dart` - Modify (only if a dedicated audio endpoint needed; otherwise reuse sloka URLs)
- **Dependencies**: Task 2.1
- **Legacy reference**: `legacy/legacy_bhagavadgita.book_swift/Gita/Model/DownloadManager.swift` (max requests, progress notification)
- **Verification**:
  - Download completes and files exist on disk
  - Progress updates continuously and is accurate within ~1–2%
  - App restart: download resumes or recovers gracefully
- **Complexity**: High

#### Task 2.3: Wire Settings → audio download toggles + progress UI
- **Description**: Add the “AUDIO” section from baseline visuals: Sanskrit Audio, Translation Audio, progress line, sizes (optional), and download prompt on first sync.
- **Files**:
  - `app/bhagavadgita.book/lib/features/settings/settings_screen.dart` - Modify
  - `app/bhagavadgita.book/lib/features/splash/splash_screen.dart` - Modify (optional: prompt to download audio after first snapshot)
  - `app/bhagavadgita.book/lib/app/bootstrap/bootstrap_coordinator.dart` - Modify (hook “first run” decision)
- **Dependencies**: Task 2.2
- **Legacy reference**:
  - Prompt flow: `legacy/legacy_bhagavadgita.book_swift/Gita/Model/DownloadManager.swift` (`AlertManager.present(...)`)
  - Background audio flags: `legacy/legacy_bhagavadgita.book_swift/Gita/Info.plist`
- **Verification**:
  - Toggle ON starts download; OFF stops/cancels or marks disabled (policy decision documented)
  - Progress line updates while downloading
- **Complexity**: High

### Phase 3: Language selection + book selection (remove hardcode)

#### Task 3.1: Persist selected language/book and propagate to queries
- **Description**: Replace `bookId = 1` usage with a persisted selection, defaulting deterministically on first launch.
- **Files**:
  - `app/bhagavadgita.book/lib/app/state/selection_store.dart` - Create
  - `app/bhagavadgita.book/lib/features/contents/contents_screen.dart` - Modify (query by selected bookId)
  - `app/bhagavadgita.book/lib/app/sync/sync_orchestrator.dart` - Modify (ensure selected book exists locally; adjust snapshot replace if needed)
- **Dependencies**: None
- **Legacy reference**:
  - Android has `LanguagesActivity` + default host/book model: `legacy/legacy_bhagavadgita.book_java/app/src/main/AndroidManifest.xml`
  - iOS picks default language based on device: `legacy/legacy_bhagavadgita.book_swift/Gita/Model/DownloadManager.swift` (currentLanguage)
- **Verification**:
  - Contents list changes when language/book changes
  - Restart preserves selection
- **Complexity**: Medium

#### Task 3.2: Implement Language Selection screen (UI + behavior)
- **Description**: Build the baseline mock “Language Selection” and wire it from Settings.
- **Files**:
  - `app/bhagavadgita.book/lib/features/language/language_screen.dart` - Create
  - `app/bhagavadgita.book/lib/features/settings/settings_screen.dart` - Modify (add LANGUAGE row)
- **Dependencies**: Task 3.1
- **Legacy reference**: `legacy/legacy_bhagavadgita.book_java/app/src/main/AndroidManifest.xml` (`LanguagesActivity`)
- **Verification**:
  - Selecting language updates selection store and refreshes Contents
- **Complexity**: Medium

### Phase 4: Quotes (dynamic) + optional notifications

#### Task 4.1: Show real quote from API on Contents (fallback to stub)
- **Description**: Fetch quote via `LegacyApiClient.getQuote()` and render it in `QuoteCard`; keep the UI slot optional.
- **Files**:
  - `app/bhagavadgita.book/lib/features/shared/widgets/quote_card.dart` - Modify (accept dynamic data/states)
  - `app/bhagavadgita.book/lib/features/contents/contents_screen.dart` - Modify (load quote async; cache lightly)
- **Dependencies**: None
- **Legacy reference**: `legacy/legacy_bhagavadgita.book_java/app/src/main/AndroidManifest.xml` (`QuoteActivity`)
- **Verification**:
  - When API responds: quote renders
  - When API fails/offline: safe fallback (hide card or show cached/stub)
- **Complexity**: Medium

#### Task 4.2 (Optional): Quote-of-the-day notifications toggle
- **Description**: Add a Settings toggle and schedule a daily local notification with a quote.
- **Files**:
  - `app/bhagavadgita.book/lib/features/settings/reader_settings.dart` - Extend
  - `app/bhagavadgita.book/lib/features/settings/settings_screen.dart` - Modify
  - `app/bhagavadgita.book/lib/app/notifications/quote_scheduler.dart` - Create
- **Dependencies**: Task 4.1
- **Legacy reference**: concept only (not confirmed in legacy); baseline visuals include NOTIFICATIONS section.
- **Verification**:
  - Toggle ON schedules; OFF cancels; schedule survives restart
- **Complexity**: High (platform integration)

### Phase 5: Search & Bookmarks polish (UX parity)

#### Task 5.1: Add search scope (All vs Bookmarks) and match highlighting
- **Description**: Implement segmented scope + bold highlight of matched substring in result preview.
- **Files**:
  - `app/bhagavadgita.book/lib/features/search/search_screen.dart` - Modify
  - `app/bhagavadgita.book/lib/features/search/widgets/highlighted_text.dart` - Create
- **Dependencies**: None
- **Legacy reference**: multi-mode search UX pattern in `legacy/legacy-gitanjali-swift/.../BUISearchViewController.h`
- **Verification**:
  - Scope filters results; highlights render without layout jumps
- **Complexity**: Medium

#### Task 5.2: Bookmarks list parity: show chapter + note preview + swipe delete UX
- **Description**: Add “note preview” and chapter label; replace Dismissible background with closer swipe action UI if needed.
- **Files**:
  - `app/bhagavadgita.book/lib/features/bookmarks/bookmarks_screen.dart` - Modify
  - `app/bhagavadgita.book/lib/data/local/user_data_repository.dart` - Modify (join note if needed)
- **Dependencies**: None
- **Legacy reference**:
  - Android has `BookmarksFragment` (feature presence)
  - ObjC engine patterns: `legacy/legacy-cookbook-swift/Classes/Data Core/BBookmarkManager.h`
- **Verification**:
  - Bookmarks list shows richer rows; swipe delete remains reliable
- **Complexity**: Medium

### Phase 6: Platform parity checklist (Android/iOS)

#### Task 6.1: Background audio + platform declarations
- **Description**: Ensure iOS background audio mode parity and Android audio focus policy.
- **Files**:
  - `app/bhagavadgita.book/ios/Runner/Info.plist` - Modify (background audio if needed)
  - `app/bhagavadgita.book/android/app/src/main/AndroidManifest.xml` - Modify (foreground service if required by chosen approach)
- **Dependencies**: Phase 1–2
- **Legacy reference**: `legacy/legacy_bhagavadgita.book_swift/Gita/Info.plist` (`UIBackgroundModes`)
- **Verification**:
  - Screen off / background: playback continues (as intended)
- **Complexity**: Medium/High (depends on chosen audio stack)

#### Task 6.2: (Optional) Analytics & push parity decisions
- **Description**: Decide what to port now vs later: Firebase messaging, analytics events, Facebook SDK.
- **Files**: TBD (kept optional; do not add unless approved)
- **Dependencies**: None
- **Legacy reference**: `legacy/legacy_bhagavadgita.book_java/app/src/main/AndroidManifest.xml`, `legacy/legacy_bhagavadgita.book_java/app/build.gradle`
- **Verification**: N/A (decision gate)
- **Complexity**: Medium

## Dependency Graph

```
Task 1.1 ─→ Task 1.2 ───────────────┐
                                    ├─→ Task 6.1
Task 2.1 ─→ Task 2.2 ─→ Task 2.3 ───┘

Task 3.1 ─→ Task 3.2

Task 4.1 ─→ (Optional) Task 4.2

Task 5.1
Task 5.2
```

## File Change Summary (expected)

| Area | Files | Action | Reason |
|------|-------|--------|--------|
| Audio core | `lib/app/audio/*` | Create | Playback state + controller |
| Audio download | `lib/app/audio/download/*` | Create | Offline downloads/progress/resume |
| Settings | `lib/features/settings/*` | Modify | Add AUDIO/LANGUAGE/NOTIFICATIONS toggles |
| Language | `lib/features/language/*` | Create | Language selection screen |
| Quote | `lib/features/contents/*`, `lib/features/shared/widgets/quote_card.dart` | Modify | Dynamic quote rendering |
| Search | `lib/features/search/*` | Modify/Create | Scope + highlight |
| Bookmarks | `lib/features/bookmarks/*` | Modify | Note preview + richer rows |
| Platform | `ios/Runner/Info.plist`, `android/.../AndroidManifest.xml` | Modify | Background audio declarations (if required) |

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Audio stack choice becomes complex (background, seek, interruptions) | Med | High | Implement in layers; validate on-device early; keep UI stable |
| Offline audio download sizes are large | High | High | Make downloads opt-in; allow per-track toggles; surface progress/cancel |
| Legacy audio URLs may be incomplete / 404 | Med | Med | Skip missing files; mark as unavailable; keep playback functional |
| Language/book selection impacts many queries | Med | High | Introduce a single selection store and propagate via small focused edits |

## Rollback Strategy

If a phase causes instability:

1. Disable the new feature behind a settings flag / “opt-in” (e.g., keep audio bar UI but no playback).
2. Revert the last phase’s commits; keep the selection store + schema stable if already shipped.

## Checkpoints (manual)

After each phase, verify:

- [ ] Contents → Chapter → Sloka still works
- [ ] Settings toggles persist and update UI
- [ ] Audio play/pause/seek works; switching tracks behaves correctly
- [ ] If downloads enabled: progress updates; restart resumes deterministically
- [ ] Language switch changes Contents and Sloka content without crashes

## Open Implementation Questions (decision gates)

- [ ] Audio stack in Flutter: which packages and how to support background playback on iOS/Android?
- [ ] Download persistence: Drift table(s) vs SharedPreferences + file scan?
- [ ] Quote notifications: do we actually ship them in this iteration, and at what local time?
- [ ] Search highlight strategy: plain substring vs tokenization vs (later) SQLite FTS?

---

## Approval

- [ ] Reviewed by: Anton
- [ ] Approved on: 2026-04-30
- [ ] Notes: Plan ready for review

