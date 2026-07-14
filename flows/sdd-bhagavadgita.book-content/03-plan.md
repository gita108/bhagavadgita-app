# Implementation Plan: sdd-bhagavadgita.book-content

> Version: 1.0
> Status: DRAFT
> Last Updated: 2026-04-29
> Specifications: [link to 02-specifications.md]

## Summary
Generate/complete the bundled seed by filling missing slokaText/comment from `data/` and updating the Flutter seed installation logic to apply changes via `contentHash`.

## Task Breakdown
### Phase 1: Content migration foundation
#### Task 1.1: Add deterministic seed completion script
- **Description**: Create a Python script that updates `seed_v1_minimal.json` by filling nullable sloka fields from legacy CSV and data fallback.
- **Files**:
  - `scripts/build_seed_v1_complete_from_legacy_and_data.py` (Create)
- **Verification**: Run coverage stats before/after (slokaText/transcription/translation/comment completeness).

### Phase 2: Integration
#### Task 2.1: Update seed installer behavior
- **Description**: Install/refresh bundled seed snapshot when bundled `contentHash/schemaVersion` differs from local snapshot.
- **Files**:
  - `app/bhagavadgita.book/lib/data/seed/seed_installer.dart` (Modify)
- **Verification**: `flutter test`

#### Task 2.2: Ensure bootstrap schedules sync
- **Description**: Make BootstrapCoordinator always schedule startupSync; seed installer controls whether bundled seed gets applied.
- **Files**:
  - `app/bhagavadgita.book/lib/app/bootstrap/bootstrap_coordinator.dart` (Modify)
- **Verification**: `flutter test`

### Phase 3: Testing & polish
#### Task 3.1: Run automated tests
- **Description**: Ensure all Flutter tests pass.
- **Files**:
  - N/A
- **Verification**: `flutter test`

---
## Approval
- [ ] Reviewed by: [name]
- [ ] Approved on: [date]
- [ ] Notes: [any conditions or clarifications]

