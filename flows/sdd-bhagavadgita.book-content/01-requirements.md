# Requirements: sdd-bhagavadgita.book-content

> Version: 1.0
> Status: DRAFT
> Last Updated: 2026-04-29

## Problem Statement
The Flutter book app needs a complete “game/content” dataset (beyond chapter titles) offline.

We want to migrate content from:
- `legacy/legacy_bhagavadgita.book_java`
- `legacy/legacy_bhagavadgita.book_swift`
- `legacy/legacy_bhagavadgita.book_db`
- `data/`

into `app/bhagavadgita.book`, primarily by producing/updating the bundled seed:
`app/bhagavadgita.book/assets/seed/seed_v1_minimal.json`.

## User Stories
### Primary
**As a** reader
**I want** full sloka content (Sanskrit + transcription + translation + optional comment) with ordering
**So that** I can read offline consistently across languages.

### Secondary
**As a** reader
**I want** vocabulary/word meanings linked to slokas
**So that** the reader feature can show per-word meanings.

### Secondary
**As a** returning user
**I want** bundled seed updates to be applied when the seed content changes
**So that** existing installs receive improved offline content.

## Acceptance Criteria
### Must Have
1. Seed JSON contains complete sloka fields supported by the Flutter DB model:
   - `slokaText`, `transcription`, `translation`, `comment` (nullable), `position`
2. Audio references are preserved where available in legacy seed:
   - `audio`, `audioSanskrit` (nullable)
3. Vocabulary entries exist and remain linked to slokas:
   - `vocabularies[].tokenText`, `vocabularies[].translation`
4. Application applies bundled seed update when `contentHash` changes:
   - `SeedInstaller` refreshes snapshot if seed `contentHash/schemaVersion` differs
   - `BootstrapCoordinator` always schedules startup sync, independent of whether bundled seed was installed

### Won't Have (This Iteration)
5. Migration of legacy device/progress tables:
   - legacy `Devices`/progress do not map into current Flutter local DB schema for this task.

## Constraints
- **Technical**: Seed format must remain compatible with `app/bhagavadgita.book/lib/data/seed/seed_installer.dart`.
- **Integration**: Changes must not break runtime parsing.
- **Performance**: Seed parsing/refresh happens only when content differs (via `contentHash`).

## Open Questions
- [ ] Confirm whether `seed_v1_minimal.json` should be renamed to a new seed version (currently kept for compatibility).

## References
- Seed loader: `app/bhagavadgita.book/lib/data/seed/seed_installer.dart`
- Seed asset: `app/bhagavadgita.book/assets/seed/seed_v1_minimal.json`
- Legacy exports: `legacy/legacy_bhagavadgita.book_db/Books/*`
- Data sources: `data/sanskrit/*`, `data/original/*`

---
## Approval
- [ ] Reviewed by: [name]
- [ ] Approved on: [date]
- [ ] Notes: [any conditions or clarifications]

