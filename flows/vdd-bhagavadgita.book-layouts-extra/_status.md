# Status: vdd-bhagavadgita.book-layouts-extra

## Current Phase

PLAN

## Phase Status

DRAFTING

## Last Updated

2026-04-30 by GPT-5.2 (Cursor)

## Blockers

- None

## Progress

- [x] Requirements drafted (inherited baseline)
- [x] Requirements approved (inherited baseline)
- [x] Visual mockups drafted (inherited baseline)
- [x] Visual approved (inherited baseline)
- [x] Specifications drafted (inherited baseline)
- [x] Specifications approved (inherited baseline)
- [x] Plan drafted  ← current
- [ ] Plan approved
- [ ] Implementation started
- [ ] Implementation complete
- [ ] Documentation drafted
- [ ] Documentation approved

## Context Notes

This flow extends the already-approved layouts baseline with “extra” functionality and UX parity with legacy apps:

- Audio is currently a **UI shell** in Flutter (`AudioPlayerBar`), but legacy apps have real playback + offline audio download.
- Flutter currently hardcodes `bookId = 1` in Contents; legacy supports language/book selection and initial book download.
- Legacy iOS has a robust audio download pipeline with resume/progress and background audio.
- Legacy Android has guide + quote screen + marketing integrations (GA/Firebase/Facebook) and a search intent flow.
- Additional legacy “books engine” projects include reusable UX ideas (shared audio player view, search modes, bookmark manager).

## Fork History

- Forked from: `vdd-bhagavadgita.book-layouts` on 2026-04-30
- Reason: Keep the “layouts parity” work scoped and approved, while planning the next chunk (audio + language + quote + search polish) with explicit legacy references.
- Changes:
  - Adds real audio playback wiring + offline audio downloads with progress/resume
  - Adds language selection and book selection UX
  - Makes quotes dynamic (API + optional scheduling)
  - Extends search UX (scope, highlight) and bookmarks UX (swipe actions)

## Reference Materials

- Baseline Requirements: `flows/vdd-bhagavadgita.book-layouts/01-requirements.md`
- Baseline Visual Mockups: `flows/vdd-bhagavadgita.book-layouts/02-visual.md`
- Baseline Specifications: `flows/vdd-bhagavadgita.book-layouts/03-specifications.md`
- Baseline Plan: `flows/vdd-bhagavadgita.book-layouts/04-plan.md`

Legacy references (functional parity targets):
- iOS (Swift): `legacy/legacy_bhagavadgita.book_swift/`
  - Audio playback: `Gita/Model/AudioManager.swift`
  - Data + audio downloads: `Gita/Model/DownloadManager.swift`
  - Background audio: `Gita/Info.plist` (`UIBackgroundModes`)
- Android (Java): `legacy/legacy_bhagavadgita.book_java/`
  - Activities: `app/src/main/AndroidManifest.xml` (Splash/Guide/Main/Settings/Languages/Quote)
  - Host config: `app/build.gradle` (dev/live hosts)

Legacy “books engine” references (UX ideas, ObjC):
- Shared audio player view: `legacy/legacy-avadhuta/Classes/Interface/BUISharedAudioPlayerView.h`
- Bookmark manager: `legacy/legacy-cookbook-swift/Classes/Data Core/BBookmarkManager.h`
- Search modes/controllers: `legacy/legacy-gitanjali-swift/Gitanjali/Classes/Interface/Search/BUISearchViewController.h`

## Next Actions

1. Review and approve `04-plan.md`
2. Start implementation in `app/bhagavadgita.book/` (audio + language + quote + search polish)

