# Status: pdd-bhagavadgita.book

## Current Phase

CHARTER (revised v2 — Flutter single codebase; superseding native-as-target)

## Phase Status

DRAFTING

## Last Updated

2026-05-04 — PDD rework: Flutter-only product, legacy Swift/Java = archive reference

## Blockers

- None

## Progress

- [x] 01 Project charter drafted (v2.0 Flutter-first)
- [ ] Project charter approved
- [x] 02 Domain specification drafted (v2.0)
- [ ] Domain specification approved
- [x] 03 Product UX specification drafted (v2.0 Flutter IA)
- [ ] Product UX approved
- [x] 04 Visual and messaging drafted (v2.0)
- [ ] Visual and messaging approved
- [x] 05 Engineering specifications drafted (v2.0)
- [ ] Engineering specifications approved
- [x] 06 Master plan drafted (v2.0)
- [ ] Master plan approved
- [ ] 07 Implementation started (Flutter milestones M1+)
- [ ] Implementation complete (program milestone)

## Linked feature flows (SDD / VDD)

| Feature / slice | Flow directory | Status |
|-----------------|------------------|--------|
| API client | `flows/sdd-bhagavadgita.book-api-client/` | see \_status |
| Content | `flows/sdd-bhagavadgita.book-content/` | see \_status |
| Database | `flows/sdd-bhagavadgita.book-database/` | see \_status |
| Domain model | `flows/sdd-bhagavadgita.book-domain-model/` | see \_status |
| Audioplayer | `flows/sdd-bhagavadgita.book-audioplayer/` | see \_status |

## Context Notes

- **Canonical codebase**: `app/bhagavadgita.book/` (Dart/Flutter) for all platforms.
- **Deprecated as product**: `legacy/legacy_bhagavadgita.book_swift/`, `legacy/legacy_bhagavadgita.book_java/` — parity / dispute resolution only.
- API envelope unchanged: `code`, `data`, `message`.

## Next Actions

1. Stakeholder: “project charter approved” on v2.0 if strategy is final.
2. Drive M1–M2 in Flutter; update SDDs when API or schema contracts change.
3. After M4: remove native apps from release checklist entirely.
