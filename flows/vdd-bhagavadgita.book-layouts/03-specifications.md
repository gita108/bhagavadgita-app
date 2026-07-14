# Specifications: Bhagavad Gita Book Layouts (Flutter)

> Version: 1.1  
> Status: DRAFT  
> Last Updated: 2026-04-30  
> Requirements: `01-requirements.md`  
> Visual: `02-visual.md`

## Overview

Implement the UI layouts and design system (colors, typography, spacing, navigation structure, and responsive behavior) for the Bhagavad Gita reader app in Flutter, based on `02-visual.md` and `01-requirements.md`, including store-screenshot-driven states:

- Contents: expandable chapters with verse grid (chips and ranges; **canonical format:** [`../vdd-verse-grid/03-specifications.md`](../vdd-verse-grid/03-specifications.md))
- Sloka detail: white topbar variant, round prev/next overlay, multi-variant translation/commentary pills, and compact mini-player
- Settings: compact layout with traktovki multi-select + per-item download action (“Скачать”)
- Tablet/landscape: split-view patterns (chapters+verse-grid → detail per [`../vdd-verse-grid/02-visual.md`](../vdd-verse-grid/02-visual.md), bookmarks → detail)

Scope of this spec is **layouts + theming + navigation + responsive (tablet) structure**, while keeping data access aligned with the existing Drift schema and repositories. Features like audio downloads, push notifications, and quote scheduling are acknowledged but **not implemented as part of this layouts spec unless explicitly included in the implementation plan**.

## Affected Systems

| System | Impact | Notes |
|--------|--------|-------|
| `app/bhagavadgita.book/lib/app/app.dart` | Modify | Replace seed theme with explicit design system (colors/typography), route/theme wiring |
| `app/bhagavadgita.book/lib/features/splash/splash_screen.dart` | Modify | Update splash visuals to match approved gradient + progress layout |
| `app/bhagavadgita.book/lib/features/contents/contents_screen.dart` | Modify | Match Contents AppBar (red), list row styling, optional Quote card slot, search affordance |
| `app/bhagavadgita.book/lib/features/reader/chapter_screen.dart` | Modify | List styling, bookmark indicator, consistent typography |
| `app/bhagavadgita.book/lib/features/reader/sloka_screen.dart` | Modify | Section typography, separators, author badge style, persistent audio bar placeholder, note editor styling |
| `app/bhagavadgita.book/lib/features/search/search_screen.dart` | Modify | Match approved search AppBar (white) and prepare circular reveal entry/exit |
| `app/bhagavadgita.book/lib/features/settings/settings_screen.dart` | Modify | Compact settings layout: display/audio toggles + traktovki list with checkmarks + download CTA |
| `app/bhagavadgita.book/lib/features/settings/reader_settings.dart` | Modify (optional) | Keep persistence; possibly extend with additional settings flags later |
| `app/bhagavadgita.book/lib/features/**/widgets/*` | Create | New reusable UI components (AuthorBadge, AudioPlayerBar shell, etc.) |
| `app/bhagavadgita.book/lib/features/**/tablet/*` | Create | Tablet master-detail scaffolds (sw720dp equivalent via breakpoints) |

## Architecture

### Component Diagram (high level)

```
MaterialApp
  ├─ Theme (Design System)
  └─ Navigator
      └─ SplashScreen
          └─ ContentsScreen
              ├─ ChapterScreen
              │   └─ SlokaScreen
              ├─ SearchScreen
              └─ SettingsScreen
                  └─ LanguageSelectionScreen (future)

Shared:
  - AppDatabase (Drift)
  - UserDataRepository (bookmarks/notes)
  - ReaderSettingsController (SharedPreferences)
```

### Data Flow (relevant to layouts)

```
AppDatabase (Drift) ──watch()──> Screens (StreamBuilder) ──> Widgets
User actions ──> UserDataRepository (bookmark/note) ──watch()──> UI state
Settings toggles ──> ReaderSettingsController ──ValueListenable──> SlokaScreen sections
```

Layout work must **not** change query semantics; only presentation and navigation structure is in scope.

## Interfaces

### New UI Components (Flutter widgets)

These are internal widgets (not public API), created to match the mockups and avoid duplication.

- `GitaAppBar` (optional): consistent AppBar styling (red/white variants)
- `QuoteCard`: optional card shown on Contents screen when quote data is available
- `AuthorBadge`: circular initials badge with red border/text
- `SlokaSectionHeader`: uppercase section header styling
- `SlokaTopbar`: white topbar variant (“К оглавлению”) with action icons (comments, bookmark, overflow)
- `RoundNavButtons`: overlay previous/next circular buttons for sloka navigation on tablet/compact layouts
- `VerseGrid` / expandable tile grid: implemented per **UVGF** in [`../vdd-verse-grid/03-specifications.md`](../vdd-verse-grid/03-specifications.md) (grouped ranges, selected highlight, tap resolution)
- `VariantPill`: small pill label for translation/commentary blocks (e.g. `Ru`, `En SP`, `En VC`)
- `MiniPlayerBar`: compact bottom mini-player (progress + sloka label + play)
- `TraktovkiList`: list with multi-select checkmarks and per-item download/install CTA
- `AudioPlayerBar` (optional shell): full-width persistent bottom bar layout; real audio wiring is out of scope for layouts unless planned
- `SwipeLayout` / bookmark list item actions (future; can start as placeholder)

### Modified Interfaces

- No Drift schema changes required for layouts.
- `ReaderSettings` may be extended with additional booleans later (e.g. showVocabulary already exists; commentary variants are future).

## Data Models

### Persistent Preferences

`ReaderSettingsController` persists reader toggles via `shared_preferences` with key prefix `reader_settings.`. Layout changes must preserve backwards compatibility for existing keys:

- `reader_settings.showSanskrit`
- `reader_settings.showTransliteration`
- `reader_settings.showTranslation`
- `reader_settings.showComment`
- `reader_settings.showVocabulary`

Notes:
- “Пословный перевод” maps to the existing vocabulary/word-by-word visibility concept.
- If a new key is required, it must default to the previous behavior (backwards compatible).

### Schema Changes

None required for layouts. Bookmarks/notes already exist via `UserDataRepository` + Drift tables.

## Behavior Specifications

### Navigation & Transitions (visual parity target)

The app should align with the navigation flow defined in `02-visual.md`.

- **Splash → Contents**: after bootstrap completes and snapshot exists
- **Contents (expanded)**: tap chapter row expands/collapses to show verse grid (UVGF); tap verse chip navigates to sloka detail (tablet may keep split-view)
- **Contents → Chapter (optional)**: if a dedicated chapter sloka-list view is exposed (legacy mode), open it via an explicit affordance (e.g. chevron/action) rather than replacing expand/collapse
- **Contents → Search**: tap search icon (circular reveal entry target)
- **Contents → Settings**: tap settings/tune icon (slide left)
- **Chapter → Sloka**: tap sloka row (slide left)
- **Sloka Previous/Next**: replacement navigation (slide left/right)

Animation implementation detail is deferred to the plan, but specs require:

- Search open/close uses circular reveal (300ms target)
- Search uses a white AppBar and scrim overlay behind results

### Screen-by-screen layout requirements

#### Splash
- Gradient background: `#FB9A6A → #FF5252`
- Centered brand/title lockup (placeholder text is acceptable initially)
- Linear progress + percent text (percent may be approximated if bootstrap does not provide progress yet)
- Error state: tap to retry (already exists functionally; update visuals)

#### Contents
- Red AppBar (`#FF5252`) with white foreground
- Actions (platform-dependent): Search, Bookmarks, Comments (optional), Settings/More
- Body:
  - Optional Quote-of-the-day card slot at top
  - List rows: chapter number/title + subtitle + chevron
  - Expand/collapse chapters to show verse grid inline (chips, including grouped ranges)
  - Selected verse chip highlighted
  - Empty state per mockup (icon + retry)

#### Chapter
- Red AppBar, title includes chapter number; optional subtitle is future
- List rows:
  - sloka position + title
  - bookmark indicator (filled when bookmarked)
  - chevron when not bookmarked is acceptable; must visually indicate bookmarked vs not

#### Sloka detail
- Supports two layout modes:
  - Red AppBar variant + top Previous/Next row (phone baseline)
  - White topbar variant (“К оглавлению”) + round overlay prev/next buttons (tablet/compact)
- Sloka header (position + name)
- Sections (driven by `ReaderSettings`):
  - Sanskrit (centered, Devanagari font)
  - Transcription (italic)
  - Vocabulary list (token → translation)
  - Translation (body)
  - Commentary (body; author badges are visual requirement even if only one commentary exists)
- Multi-variant blocks:
  - Multiple translation/commentary variants can be rendered in the same scroll
  - Each block is labeled by a `VariantPill` (e.g. `Ru`, `En SP`, `En VC`)
- Note editor (TextField + Save button)
- Compact audio controls:
  - `MiniPlayerBar` with progress + play (visual requirement)
  - Optional full-width `AudioPlayerBar` can be deferred

#### Settings
- Red AppBar
- Section headers (uppercase, gray2)
- Toggle rows use red accent when ON
- Must continue using `ReaderSettingsController` persistence
- “Traktovki” section:
  - multi-select checkmarks supported
  - per-item download/install CTA (“Скачать”) when not present locally
- Audio toggles may be dependent/disabled based on selection; disabled state must be visually distinct

#### Search
- White AppBar variant, with close affordance and clear button (future refinement)
- Search field at top; results list below
- Scrim overlay + circular reveal transition target
- Highlighting matches is a future enhancement; not required for initial layouts pass

### Edge Cases

| Case | Trigger | Expected Behavior |
|------|---------|-------------------|
| Empty local snapshot | bootstrap completes without snapshot | Show Splash “No local snapshot…” state (existing) with non-breaking visuals |
| No chapters | DB has no chapter rows | Show approved empty state in Contents |
| No slokas for chapter | DB query empty | Show readable empty state on Chapter screen |
| Missing section content | null/empty text fields | Hide that section even if enabled (already partly done) |
| Very long Sanskrit / translation | long text blocks | Wrap and maintain readable line height; scrolling must remain smooth |
| Verse ranges in grid | chapter has grouped ranges | Display a range chip (`32-34`) and ensure tap behavior is consistent (plan detail) |

### Error Handling

| Error | Cause | Response |
|-------|------|----------|
| Bootstrap failure | seed install/DB init error | Show retry state on Splash (tap to retry) |
| DB stream error | Drift watch throws | Show generic error UI with retry affordance (implementation detail in plan) |

## Dependencies

### Requires (already present)

- `drift`, `drift_flutter`, `sqlite3_flutter_libs`
- `shared_preferences`
- Existing Drift tables (`data/local/tables.dart`)

### Optional (likely needed later; not mandated by this spec yet)

- `google_fonts` for PT Sans
- Custom font asset for Kohinoor Devanagari (licensing check)
- Animation helper (built-in Flutter is sufficient for circular reveal with `ClipPath`/`AnimatedBuilder`)

## Integration Points

### Internal Systems

- `BootstrapCoordinator` determines startup flow (splash → contents); layout work must not break it
- `UserDataRepository` supplies bookmark/note state for Chapter and Sloka screens
- `ReaderSettingsController` drives visibility of Sloka sections

### External Systems

- Legacy API client exists (`data/remote/*`) but is not required for layouts; layouts should degrade gracefully if remote sync is not present

## Testing Strategy

### Unit Tests

- [ ] `ReaderSettingsController` persists and reloads keys (if modified)

### Golden / Widget Tests (recommended)

- [ ] Contents screen default and empty states match intended structure
- [ ] Contents expanded chapter renders verse grid with selected + range chips
- [ ] Sloka screen with all sections visible and with sections hidden
- [ ] Sloka screen renders white topbar variant + variant pills + mini-player layout
- [ ] Tablet master-detail scaffolds render correctly at wide constraints
- [ ] Tablet split-view: chapters+grid → detail, bookmarks → detail

### Manual Verification

- [ ] Launch app: splash renders gradient and progresses to Contents
- [ ] Contents list: tap chapter expands verse grid; tap verse opens Sloka; Previous/Next works
- [ ] (Optional legacy) Chapter list: open chapter sloka-list view and tap sloka opens Sloka
- [ ] Settings toggles affect Sloka sections immediately and persist on restart

## Migration / Rollout

No data migrations. UI-only changes, safe to roll out behind incremental commits.

## Open Design Questions

- [ ] **Font licensing**: PT Sans via Google Fonts is OK; Kohinoor Devanagari licensing/availability on Android needs confirmation (may require bundling an alternative font)
- [ ] **Material 3 vs Material 2**: app currently uses Material 3; decide whether to keep M3 and style to match mockups, or switch to M2 for closer legacy parity
- [ ] **Tablet breakpoint**: define concrete breakpoint(s) and pane ratio (mockups imply ~40/60)
- [ ] **Circular reveal implementation**: decide whether to implement via custom clip animation or use a package (prefer custom to avoid dependency)
- [ ] **Traktovki selection rules**: confirm if multi-select is intended on all platforms; screenshots show multiple checkmarks
- [ ] **Verse range tap behavior**: tap opens first verse vs opens chooser (UX decision) — tracked in [`../vdd-verse-grid/01-requirements.md`](../vdd-verse-grid/01-requirements.md)

---

## Approval

- [ ] Reviewed by: Anton
- [ ] Approved on: TBD
- [ ] Notes: Updated to align with store screenshots and expanded ASCII visuals

