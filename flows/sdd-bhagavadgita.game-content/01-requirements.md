# Requirements: sdd-bhagavadgita.game-content

> Version: 1.0
> Status: DRAFT
> Last Updated: 2026-04-29

## Problem Statement
The current Flutter book app needs to receive the full “game/content” dataset (beyond chapter titles and visuals) from legacy sources.

We want to migrate content from:
- `legacy/legacy_bhagavadgita.book_java`
- `legacy/legacy_bhagavadgita.book_swift`
- `legacy/legacy_bhagavadgita.book_db`
- `data/`

into `app/bhagavadgita.book`, primarily into the app’s seed/data artifacts.

## User Stories
### Primary
**As a** reader
**I want** full sloka content (Sanskrit + transcription + translation + optional comment) with ordering and audio support
**So that** I can read and listen consistently across languages.

### Secondary
**As a** learner
**I want** vocabulary/word-level meanings linked to slokas
**So that** I can understand key terms.

**As a** returning user
**I want** book/chapter structure and “quote of the day” content
**So that** the app experience stays complete.

## Acceptance Criteria
### Must Have
1. The migrated seed/data contains:
   - `languages` and `books` metadata (ids/codes/names/initials)
   - `chapters` structure (bookId/name/position)
   - `slokas` fields: `slokaText`, `transcription`, `translation`, optional `comment`, `position`
2. Audio references are present in the sloka records:
   - `audio` and `audioSanskrit` fields (or an equivalent model/representation used by the Flutter app)
3. Vocabulary/word meanings are present and linked to slokas:
   - Supports per-sloka word entries (term + meaning)
4. “Quote of the day” content is available (from legacy quotes dataset), with day selection flags/metadata preserved if applicable.

### Should Have
5. Fonts and UI localization strings are included/compatible with the Flutter app approach.

### Won't Have (This Iteration)
6. Push-notification device migration unless explicitly required for “game content” (legacy device table may be out of scope).
7. Any redesign of app UI/UX (only content/data migration).

## Constraints
- **Technical**: Must conform to the existing data model / seed format used in `app/bhagavadgita.book` (currently `assets/seed/seed_v1_minimal.json` exists).
- **Integration**: Migration must not break runtime loading/parsing.
- **Performance**: Seed/data size should remain acceptable for mobile.

## Open Questions
- [ ] What exact Flutter seed/data format should be the target output (extend `seed_v1_minimal.json` vs create a new version like `seed_v2` vs use a local bundled DB)?
- [ ] Where should audio files come from if they are not present in the repo (local assets vs remote download vs packaging step)?
- [ ] Which languages/books are required for MVP of this content migration?
- [ ] Should “devices” (`legacy/legacy_bhagavadgita.book_db/devices/Gita_Devices.csv`) be migrated for this task, or only content datasets?

## References
- Current seed: `app/bhagavadgita.book/assets/seed/seed_v1_minimal.json`
- Legacy DB exports: `legacy/legacy_bhagavadgita.book_db/Books/*`
- Chapter/transliteration/vocabulary sources: `data/*`

---

## Approval
- [ ] Reviewed by: [name]
- [ ] Approved on: [date]
- [ ] Notes: [any conditions or clarifications]

