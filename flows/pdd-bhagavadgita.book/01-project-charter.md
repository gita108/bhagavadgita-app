# Project charter: Bhagavad Gita Book

> Version: 2.0 (Flutter single codebase)  
> Status: DRAFT  
> Last updated: 2026-05-04  
> Parity reference (frozen): `legacy/legacy_bhagavadgita.book_swift/`, `legacy/legacy_bhagavadgita.book_java/`

## Executive summary

**Bhagavad Gita Book** is a reader for the Bhagavad Gita: multiple languages and translations, chapter/shloka navigation, local persistence, optional audio, bookmarks, notes, daily quote, search, and onboarding. The product is delivered as **one Flutter application** (`app/bhagavadgita.book`) for **all client platforms** from a **single Dart codebase**.

The former **native iOS (Swift)** and **native Android (Java)** apps are **deprecated as implementation surfaces**: they remain in the repo only as **archaeological reference** to lock API semantics, UX parity, and edge cases while Flutter reaches full replacement.

## Vision and positioning

- **Vision**: One maintainable codebase, consistent UX across platforms, reliable offline read, same backend contract the legacy apps used.
- **Positioning**: Content-centric spiritual reader; engineering stance is **Flutter-first**, not dual-native.
- **North-star metric**: Feature parity + store quality on **Flutter-only** releases, with reduced duplicate defect surface (no Swift/Java drift).

## Goals and non-goals

### Goals

1. **Single codebase**: All net-new work in `app/bhagavadgita.book` (Dart/Flutter); shared UI, sync, DB, and API client.
2. Present **books → chapters → shlokas** with correct text and commentary per local schema.
3. **Bootstrap catalog** from API (`Data/Languages`, `Data/Books`, `Data/Chapters`) and **quote** (`Data/Quotes`) via shared client (`LegacyApiClient` / envelope).
4. **On-device persistence** (Drift/SQLite stack under `lib/data/local/`) with explicit migrations — do not copy “delete DB on bundle bump” blindly without product approval.
5. **Reader affordances**: bookmarks, notes, search, settings, audio — implemented once in Flutter, adapted per platform (e.g. tablet scaffolds under `lib/features/tablet/`).

### Non-goals

- **No** continued evolution of Swift or Java UI layers for product features.
- No in-app social feed or public UGC (unchanged).
- No obligation to keep legacy apps buildable on latest Xcode/AGP for release (optional CI smoke only if team wants).

## Target users and jobs-to-be-done

| Segment | Primary job-to-be-done |
|---------|-------------------------|
| Daily reader | Open last position, continue chapter, bookmark verses |
| Student / researcher | Search text, interpretation / language settings |
| Listener | Play verse audio (shared audio stack in Flutter) |

## Scope boundaries

- **In scope**: Flutter app; API contract; local schema; release via existing CI/CD SDDs.
- **Out of scope**: Backend implementation of `app.bhagavadgitaapp.online`.
- **Dependencies**: HTTPS-capable endpoints for production; analytics/push strategy revisited once (unified Firebase or platform channels from Flutter).

## Success metrics and guardrails

| Metric | Target |
|--------|--------|
| Code duplication | **Zero** parallel product logic in Swift/Java for new scope |
| API compatibility | Preserve `code` / `data` / `message` semantics in `legacy_envelope.dart` + client |
| Parity | Critical paths match legacy behavior where documented in PDD/SDD |
| Stores | Single Flutter binaries per platform; modern min SDK / privacy posture |

## High-level user journeys (Flutter)

1. **First launch**: `splash_screen` → bootstrap/sync → `onboarding_screen` → contents/reader as coordinated by `bootstrap_coordinator` / sync layer.
2. **Returning user**: Splash → **chapters** (`chapter_screen` / contents) → **shloka** (`sloka_screen`).
3. **Settings**: `settings_screen`, content language (`content_languages_screen`), app language, reader/audio settings.

Legacy class names (e.g. `ShlokaViewController`, `SlokasFragment`) are **not** user-facing; they appear only in the **parity map** in `03-product-ux-specification.md`.

## Risks

| Risk | Mitigation |
|------|------------|
| Parity gaps vs two different legacy UIs | One Flutter UX; document intentional deltas; use one legacy as primary when they disagree |
| HTTP hosts in old code | Flutter release builds use HTTPS endpoints |
| Team habit of “checking old app” | Keep PDD + SDDs as source of truth; legacy grep only for disputes |

## Approvals

**Approval phrase to advance**: “project charter approved”
