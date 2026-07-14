# Specifications: sdd-bhagavadgita.book-content

> Version: 1.0
> Status: DRAFT
> Last Updated: 2026-04-29
> Requirements: [link to 01-requirements.md]

## Overview
Update the bundled seed so that offline reading has the full sloka dataset (within what the sources provide), and ensure the app applies bundled seed refresh when the seed changes.

## Affected Systems
| System | Impact | Notes |
|--------|--------|-------|
| `app/bhagavadgita.book` seed loading | Modify | SeedInstaller + BootstrapCoordinator logic |
| `app/bhagavadgita.book` bundled seed asset | Modify | Fill missing `slokaText` and available `comment` from `data/` |
| `scripts/*` | Add | Deterministic generator for seed completion |

## Data Model
Local DB includes:
- `languages`, `books`, `chapters`, `slokas`, `vocabularies` as content snapshot
- `bookmarks`, `notes` isolated and untouched by snapshot replace

## Behavior Specifications
1. Seed refresh is triggered when:
   - `snapshotMeta` is empty, OR
   - snapshot `contentHash/schemaVersion` differs from bundled seed.
2. Legacy fields:
   - use legacy CSV first for `audio`, `audioSanskrit`, `transcription`, `translation`, `comment`, `slokaText`.
3. Data fallback:
   - if legacy `slokaText`/`transcription`/`translation`/`comment` is missing (`NULL`/empty), load from `data/` files.

## Dependencies
- Legacy CSV exports must exist in `legacy/legacy_bhagavadgita.book_db/Books/`
- Data files must exist in `data/sanskrit/` and `data/original/<lang>/`

---
## Approval
- [ ] Reviewed by: [name]
- [ ] Approved on: [date]
- [ ] Notes: [any conditions or clarifications]

