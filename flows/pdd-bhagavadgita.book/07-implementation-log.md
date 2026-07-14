# Implementation log: Bhagavad Gita Book

> Program-level log

## Log

### 2026-05-04 — PDD restored from legacy native apps

**What changed**: Created `flows/pdd-bhagavadgita.book/` with `01`–`07` documents populated from reverse analysis of `legacy/legacy_bhagavadgita.book_swift` (iOS Gita) and `legacy/legacy_bhagavadgita.book_java` (Android `com.ethnoapp.bgita`). Added `artifacts/README.md` pointing to legacy roots.

**Why**: Establish a single program-level baseline for API, domain, UX, and engineering parity with Flutter workstreams.

**Links**: `_status.md` set to ENGINEERING / DRAFTING; charter/UX/engineering sections ready for stakeholder approval phrases.

**Deviations from master plan**: none (M0 only).

### 2026-05-04 — PDD v2.0: Flutter single codebase, native sunset

**What changed**: Reworked `01`–`06` to position **`app/bhagavadgita.book`** as the **only** product implementation. Swift and Java apps documented as **legacy archive** (parity reference only). Updated `03` with Flutter route/module table + legacy parity map. Engineering diagram and file pointers now Flutter-first (`legacy_api_client`, `features/*`, `data/local/*`). Master plan v2.0 adds explicit **M4** store releases Flutter-only and **M5** telemetry unification. `artifacts/README.md` and `_status.md` aligned.

**Why**: Eliminate dual native maintenance; single codebase for iOS, Android, web, desktop.

**Links**: Charter v2.0, domain/UX/engineering v2.0, master plan v2.0.

**Deviations**: Prior M0 wording implied equal weight to native trees — superseded by v2.0.
