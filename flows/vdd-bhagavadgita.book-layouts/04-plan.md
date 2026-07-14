# Implementation Plan: Bhagavad Gita Book Layouts (Gap Analysis)

> Version: 1.0
> Status: DRAFT
> Last Updated: 2026-05-01
> Specifications: `03-specifications.md`

---

## Gap Analysis Summary

**Overall Implementation: 82%**

| Screen/Component | Status | Completion |
|------------------|--------|------------|
| Splash Screen | Functional | 85% |
| Onboarding | Complete | 90% |
| Contents Screen | Partial | 75% |
| Chapter Screen | Functional | 80% |
| Sloka Screen | Partial | 80% |
| Search Screen | **CRITICAL BUG** | 70% |
| Settings Screen | **CODE ISSUES** | 80% |
| Bookmarks Screen | Functional | 85% |
| Tablet Layouts | Functional | 85% |
| Theme System | Complete | 95% |

---

## CRITICAL ISSUES (Must Fix)

### BUG-1: Search Screen - Missing State Variable

**File:** `features/search/search_screen.dart:102-109`

**Problem:** `_onlyBookmarks` variable referenced but never declared in `_SearchScreenState`. App crashes when filter chips are tapped.

**Fix:**
```dart
class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  bool _onlyBookmarks = false;  // ADD THIS LINE
  ...
}
```

**Priority:** P0 - Blocking

---

### BUG-2: Settings Screen - Duplicate/Unreachable Code

**File:** `features/settings/settings_screen.dart:371-401`

**Problem:** Duplicate `_SectionHeader` class definition and orphaned ListTile code after the class closes at line 369.

**Fix:** Remove lines 371-401 (duplicate code block).

**Priority:** P0 - Code doesn't compile properly

---

## MISSING FEATURES (From Specs)

### Phase 1: High Priority Gaps

#### GAP-1: Verse Range Chips in Contents

**Spec:** Verse grid mockups and **Universal Verse Grid Format (UVGF)** — [`../vdd-verse-grid/02-visual.md`](../vdd-verse-grid/02-visual.md), [`../vdd-verse-grid/03-specifications.md`](../vdd-verse-grid/03-specifications.md). (Legacy pointer: former `02-visual.md` ASCII block now lives under `vdd-verse-grid`.)

**Current:** Individual position chips only (1, 2, 3, etc.)

**Files:**
- `features/contents/contents_screen.dart`
- `features/contents/widgets/chapter_expandable_tile.dart` (if exists)

**Implementation:**
1. Parse sloka name for range indicators
2. Group consecutive slokas into range chips
3. Display "4-6" instead of "4", "5", "6"
4. Tap opens first sloka of range

**Complexity:** Medium

---

#### GAP-2: Splash Download Dialog

**Spec:** `02-visual.md` lines 62-80 show modal dialog for audio download

**Current:** No download dialog on splash

**Files:**
- `features/splash/splash_screen.dart`

**Implementation:**
1. Add `showDownloadDialog()` method
2. Trigger after initial bootstrap completes
3. Options: "Yes" (download) / "No" (skip)
4. Show estimated size (~150 MB)

**Complexity:** Low

---

#### GAP-3: Traktovki Multi-Select UI

**Spec:** `02-visual.md` lines 617-627 show commentary/books list with checkmarks + "Скачать" CTA

**Current:** Placeholder function `_placeholderBooks()` with hardcoded data

**Files:**
- `features/settings/settings_screen.dart`
- Create: `features/settings/books_settings_controller.dart`
- Create: `features/settings/book_summary.dart`

**Implementation:**
1. Create `BooksSettingsController` with real data source
2. Multi-select state management
3. Download CTA per item (not downloaded)
4. Progress indicator per item (downloading)
5. Checkmark (downloaded/selected)

**Complexity:** High (requires data layer)

---

#### GAP-4: Variant Pills - Interactive Selection

**Spec:** `02-visual.md` lines 472-484 show multiple translation variants (En VC, En SP)

**Current:** Static pills, no switching between variants

**Files:**
- `features/reader/sloka_screen.dart`
- Create: `features/reader/widgets/variant_selector.dart`

**Implementation:**
1. Make pills tappable
2. Highlight selected variant
3. Show/hide translation blocks based on selection
4. Persist selection preference

**Complexity:** Medium

---

#### GAP-5: Bookmark Note Preview

**Spec:** `02-visual.md` lines 735-756 show note preview in bookmark list

**Current:** Only sloka name + translation preview, no note

**Files:**
- `features/bookmarks/bookmarks_screen.dart`

**Implementation:**
1. Query note alongside bookmark
2. Show first line of note (truncated) if exists
3. Note indicator icon if note exists but truncated

**Complexity:** Low

---

### Phase 2: Visual Polish

#### POLISH-1: Audio Player Duration

**Current:** Shows position only (2:34)

**Spec:** Should show position / duration (2:34 / 5:12)

**Files:**
- `features/shared/widgets/audio_player_bar.dart`

**Complexity:** Low

---

#### POLISH-2: Scrim/Shadow Effects

**Spec:** Round nav buttons should have shadow/scrim

**Current:** Flat buttons without visual depth

**Files:**
- `features/reader/sloka_screen.dart`
- `features/reader/widgets/round_nav_button.dart` (if exists)

**Complexity:** Low

---

#### POLISH-3: Commentary Author Attribution

**Current:** Shows "BG" badge only

**Spec:** Should show author name (e.g., "Bhaktivedanta")

**Files:**
- `features/reader/sloka_screen.dart`
- `features/shared/widgets/author_badge.dart`

**Complexity:** Low

---

#### POLISH-4: Search Scrim Overlay

**Spec:** Dark overlay behind search results

**Current:** No scrim visible

**Files:**
- `features/search/search_screen.dart`

**Complexity:** Low

---

### Phase 3: Tablet Refinements

#### TABLET-1: Selected Chapter Highlight

**Current:** Basic selection state

**Spec:** Visual highlight for selected chapter in master pane

**Files:**
- `features/tablet/contents_chapter_scaffold.dart`

**Complexity:** Low

---

#### TABLET-2: Empty Detail Pane State

**Current:** "Select a chapter" text

**Spec:** Refined empty state with icon + message

**Files:**
- `features/tablet/contents_chapter_scaffold.dart`
- `features/tablet/chapter_sloka_scaffold.dart`

**Complexity:** Low

---

#### TABLET-3: Remove Unused Code

**File:** `features/tablet/contents_chapter_scaffold.dart:193-254`

**Problem:** `_ChapterDetailPane` class defined but never used

**Fix:** Remove or integrate

**Complexity:** Low

---

## Implementation Order

### Sprint 1: Critical Fixes (P0)

| Task | File | Effort |
|------|------|--------|
| BUG-1: Add `_onlyBookmarks` | search_screen.dart | 5 min |
| BUG-2: Remove duplicate code | settings_screen.dart | 5 min |
| Run `flutter analyze` | - | 5 min |
| Run `flutter test` | - | 10 min |

**Total:** ~30 min

---

### Sprint 2: High Priority Gaps

| Task | Files | Effort |
|------|-------|--------|
| GAP-5: Bookmark note preview | bookmarks_screen.dart | 1h |
| GAP-2: Splash download dialog | splash_screen.dart | 2h |
| GAP-1: Verse range chips | contents_screen.dart | 3h |
| GAP-4: Variant pills interactive | sloka_screen.dart | 3h |

**Total:** ~9h

---

### Sprint 3: Visual Polish

| Task | Files | Effort |
|------|-------|--------|
| POLISH-1: Duration display | audio_player_bar.dart | 30 min |
| POLISH-2: Scrim/shadow | round nav buttons | 1h |
| POLISH-3: Author attribution | author_badge, sloka_screen | 1h |
| POLISH-4: Search scrim | search_screen.dart | 30 min |

**Total:** ~3h

---

### Sprint 4: Tablet & Cleanup

| Task | Files | Effort |
|------|-------|--------|
| TABLET-1: Selection highlight | contents_chapter_scaffold | 1h |
| TABLET-2: Empty states | tablet scaffolds | 1h |
| TABLET-3: Remove dead code | contents_chapter_scaffold | 15 min |

**Total:** ~2.5h

---

### Sprint 5: Traktovki (Deferred)

| Task | Files | Effort |
|------|-------|--------|
| GAP-3: Books settings controller | new files | 4h |
| GAP-3: Multi-select UI | settings_screen | 3h |
| GAP-3: Download/progress states | settings_screen | 2h |

**Total:** ~9h

**Note:** GAP-3 depends on data layer decisions (seed vs repository). Can be deferred to separate flow.

---

## Dependency Graph

```
Sprint 1 (Critical)
    │
    ├── BUG-1 (search)
    └── BUG-2 (settings)
           │
           ▼
Sprint 2 (High Priority)
    │
    ├── GAP-5 (bookmarks)
    ├── GAP-2 (splash dialog)
    ├── GAP-1 (verse ranges)
    └── GAP-4 (variants)
           │
           ▼
Sprint 3 (Polish)
    │
    ├── POLISH-1..4
           │
           ▼
Sprint 4 (Tablet)
    │
    ├── TABLET-1..3
           │
           ▼
Sprint 5 (Traktovki) ─── DEFERRED
```

---

## Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Verse range parsing fails | Med | Low | Fallback to individual chips |
| Download dialog interrupts flow | Low | Med | Make dismissible, remember choice |
| Variant data missing | Med | Med | Show only available variants |

---

## Checkpoints

- [x] Sprint 1: `flutter analyze` = 0 errors ✅
- [x] Sprint 2: All high priority gaps closed ✅ (GAP-1, GAP-2, GAP-4, GAP-5)
- [x] Sprint 3: Visual polish complete ✅ (POLISH-1, POLISH-2, POLISH-3, POLISH-4)
- [x] Sprint 4: Tablet layouts refined ✅ (TABLET-1, TABLET-2)
- [ ] Sprint 5: Traktovki functional (optional, deferred)

---

## Approval

- [ ] Reviewed by: Anton
- [ ] Approved on: [date]
- [ ] Notes: [conditions]
