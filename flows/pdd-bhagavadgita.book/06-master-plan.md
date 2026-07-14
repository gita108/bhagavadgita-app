# Master plan: Bhagavad Gita Book

> Version: 2.0 (Flutter replacement)  
> Status: DRAFT  
> Last updated: 2026-05-04

## 1. Strategic decision

| Decision | Status |
|----------|--------|
| **Replace** dual native apps (Swift + Java) with **one Flutter codebase** | **Adopted** |
| Legacy repos in `legacy/` | **Read-only reference** for parity and archaeology |

## 2. Milestones

| Milestone | Outcome |
|-----------|---------|
| **M0** | PDD v2.0 (this set) + charter alignment on Flutter-only |
| **M1** | API + envelope + sync path production-ready in Flutter (`legacy_api_client`, orchestrators) |
| **M2** | Reader parity: contents → shloka, bookmarks, notes, search, settings |
| **M3** | Audio parity per `sdd-bhagavadgita.book-audioplayer` |
| **M4** | Store releases **only** Flutter artifacts; legacy apps **removed from roadmap** (optional: archive tags on old native repos if they live elsewhere) |
| **M5** | Telemetry unification (single analytics approach from Flutter) |

## 3. Workstreams

| Stream | Owner focus | Depends on |
|--------|-------------|------------|
| **Flutter product** | `app/bhagavadgita.book` features & UX | M1 |
| **Data / schema** | Drift migrations, seed, snapshots | SDD database |
| **Release / CI** | Build matrices for iOS+Android from one project | SDD cicd |
| **Legacy sunset** | Stop treating Swift/Java as “second implementation” to fix | M4 |

## 4. Risks

| Risk | Mitigation |
|------|------------|
| “Fix it in native” habit | Code review + PDD §1; bugs filed against Flutter modules |
| Parity arguments | Parity map in `03-product-ux-specification.md` + acceptance in SDD |
| Web/desktop scope creep | Gate in charter if unsupported in v1 |

## 5. Open decisions

| ID | Decision |
|----|----------|
| D1 | Last-read persistence (recommended) vs legacy Swift cold-start reset |
| D2 | Official HTTPS base URL + env matrix (dev/staging/prod) |
| D3 | Whether to keep Facebook SDK equivalent in Flutter |

## Approvals

**Approval phrase to start program execution**: “master plan approved”
