# Implementation Log: sdd-bhagavadgita.book-content

> Version: 1.0
> Status: DRAFT
> Last Updated: 2026-04-29
> Requirements: [link to 01-requirements.md]

## Progress Summary
- Completed bundled seed “content completion”:
  - `slokaText` filled to 100% using legacy + `data/sanskrit/`
  - `transcription` filled to 100% using legacy + `data/original/` fallback
  - `comment` filled from legacy + `data/original/*_comment.txt` where available
  - `translation` filled where possible; some rows remain null if neither legacy nor data provide them
- Updated app startup behavior:
  - `SeedInstaller` now compares bundled seed `contentHash/schemaVersion` with local snapshot and refreshes if different
  - `BootstrapCoordinator` always schedules `startupSync()`

## What Changed
1. Added script:
   - `scripts/build_seed_v1_complete_from_legacy_and_data.py`
2. Modified seed installation logic:
   - `app/bhagavadgita.book/lib/data/seed/seed_installer.dart`
3. Modified bootstrap coordinator:
   - `app/bhagavadgita.book/lib/app/bootstrap/bootstrap_coordinator.dart`
4. Updated asset:
   - `app/bhagavadgita.book/assets/seed/seed_v1_minimal.json`

## Verification
- Ran `python scripts/build_seed_v1_complete_from_legacy_and_data.py --repo-root .`
- Coverage after migration (seed):
  - `slokaText`: 3979/3979 non-null
  - `transcription`: 3979/3979 non-null
  - `translation`: 3972/3979 non-null
  - `comment`: 1302/3979 non-null
- Ran `flutter test` in `app/bhagavadgita.book` (All tests passed).

