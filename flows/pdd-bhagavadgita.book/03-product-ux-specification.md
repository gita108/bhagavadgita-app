# Product UX specification: Bhagavad Gita Book

> Version: 2.0 (Flutter IA primary)  
> Status: DRAFT  
> Last updated: 2026-05-04

## 1. Platforms and constraints

| Surface | Notes |
|---------|--------|
| **Flutter (canonical)** | One codebase: `app/bhagavadgita.book` — Material/Cupertino adaptations, `lib/features/tablet/` for wide layouts |
| **Web / desktop** | Same codebase; connectivity and storage differ — use `app_database_connection_web.dart` and platform guards |
| **Legacy native** | **Not** a target platform; see §4 for parity mapping only |

## 2. Navigation model (Flutter)

| Route / feature module | Primary widgets / entry | User goal |
|------------------------|-------------------------|-----------|
| Splash | `features/splash/splash_screen.dart` | Init, policy, navigate to bootstrap |
| Onboarding | `features/onboarding/onboarding_screen.dart`, `app_onboarding_controller.dart` | First-run education |
| Contents | `features/contents/contents_screen.dart` | Chapter list, enter reader |
| Chapter | `features/reader/chapter_screen.dart` | Chapter-level navigation |
| Shloka reader | `features/reader/sloka_screen.dart` | Read verse, bookmark, share, audio chrome |
| Bookmarks | `features/bookmarks/bookmarks_screen.dart` | Saved verses |
| Search | `features/search/search_screen.dart`, `search_route.dart` | Full-text / highlighted results |
| Settings hub | `features/settings/settings_screen.dart` | App language, content languages, reader, audio |
| Content languages | `features/settings/content_languages_screen.dart` | Pick translation language |
| App language | `features/settings/app_language_screen.dart` | UI locale |
| Tablet | `contents_chapter_scaffold.dart`, `chapter_sloka_scaffold.dart`, `breakpoints.dart` | Master/detail without duplicating business logic |

**App shell / coordination**: `lib/app/app.dart`, `bootstrap_coordinator.dart`, `sync/sync_orchestrator.dart`.

## 3. Screen inventory (Flutter — product truth)

| # | User goal | Primary CTA | Flutter location |
|---|-----------|---------------|------------------|
| 1 | Pick content language | Continue | `content_languages_screen.dart` |
| 2 | Browse chapters | Open shloka | `contents_screen.dart` / `chapter_screen.dart` |
| 3 | Read verse | Bookmark / share / audio | `sloka_screen.dart` |
| 4 | Daily quote | Open / dismiss | Shared `quote_card.dart` + contents flow |
| 5 | Bookmarks | Open verse | `bookmarks_screen.dart` |
| 6 | Configure app | Save | `settings_screen.dart` + sub-screens |
| 7 | Find text | Select hit | `search_screen.dart` |

## 4. Legacy parity map (reference only)

Use when auditing “did we miss a screen?” — **not** for new IA.

| User goal | Flutter (target) | Legacy iOS | Legacy Android |
|-----------|------------------|------------|----------------|
| Splash / init | `splash_screen.dart` | `SplashViewController` | `SplashActivity` |
| Guide | `onboarding_screen.dart` | `GuideViewController` (+ variants) | `GuideActivity` |
| Chapter hub | `contents_screen.dart` | `ContentsViewController` | `ChaptersFragment` in `MainActivity` |
| Reader | `sloka_screen.dart` | `ShlokaViewController` | `SlokasFragment` |
| Bookmarks | `bookmarks_screen.dart` | `BookmarksViewController` | `BookmarksFragment` |
| Quote | quote in contents / cards | `QuoteViewController` | `QuoteActivity` |
| Settings | `settings_screen.dart` | `SettingsViewController` | `SettingsActivity` |
| Search | `search_screen.dart` | `ContentsSearchResultViewController` | `SearchPanelView` + results |

## 5. Global UX rules (Flutter)

- **Reader focus**: verse typography and spacing per `ui/theme/app_text.dart` / theme; minimize chrome on small phones.
- **Brand accents**: red family from `app_colors.dart` where aligned with legacy Android reader chrome (tune per Material 3).
- **Tablet**: one implementation of split layout via scaffolds — no separate Swift/Java tablet forks.
- **Accessibility**: Flutter semantics + platform text scale.

## 6. Access and gating

| Capability | Required state |
|------------|----------------|
| Read cached content | Snapshot/DB populated (`snapshot_repository`, sync) |
| Network bootstrap | Online for initial catalog sync |

## 7. User journey attachments

Add Flutter-specific flow diagrams under `artifacts/` and link here.

## Approvals

**Approval phrase to advance**: “product ux approved”
