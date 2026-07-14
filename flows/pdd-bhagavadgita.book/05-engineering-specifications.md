# Engineering specifications: Bhagavad Gita Book

> Version: 2.0 (Flutter canonical)  
> Status: DRAFT  
> Last updated: 2026-05-04

## 1. System context

```
                    ┌──────────────────────────────┐
                    │  Backend API (unchanged)    │
                    │  POST /api/Data/*            │
                    │  JSON envelope               │
                    └───────────────▲──────────────┘
                                    │
┌───────────────────────────────────┴───────────────────────────────────┐
│  Flutter app — SINGLE codebase (`app/bhagavadgita.book`)               │
│  iOS | Android | web | desktop                                          │
│  `lib/data/remote/legacy_api_client.dart` + `legacy_envelope.dart`      │
│  `lib/data/local/*` (Drift) + `lib/app/sync/*`                          │
│  `lib/features/*` (UI)                                                   │
└─────────────────────────────────────────────────────────────────────────┘

Legacy Swift / Java apps: OUT OF PRODUCT PATH (reference under `legacy/` only)
```

---

## 2. Flutter application structure (authoritative)

| Layer | Path | Responsibility |
|-------|------|------------------|
| Entry | `lib/main.dart`, `lib/app/app.dart` | RunApp, theme, routing shell |
| Remote API | `lib/data/remote/legacy_api_client.dart`, `legacy_envelope.dart`, `dto/*.dart` | HTTP, parsing, envelope |
| Local DB | `lib/data/local/app_database.dart`, `tables.dart`, `*.g.dart` | Schema, queries |
| Sync / bootstrap | `lib/app/bootstrap/bootstrap_coordinator.dart`, `lib/app/sync/sync_orchestrator.dart`, `refresh_policy.dart` | Initial load, refresh |
| Reader | `lib/features/reader/` | Chapter + shloka UI |
| Contents / bookmarks / search / settings | `lib/features/*/` | Feature modules |
| Tablet | `lib/features/tablet/` | Responsive scaffolds |
| Audio | `lib/app/audio/` | Controllers, storage, download |
| Theme / widgets | `lib/ui/theme/`, `lib/ui/widgets/` | Shared visuals |

---

## 3. Remote API contract

Same as domain doc §3. Implementation lives in **`LegacyApiClient`**; timeouts/retries should be centralized (do not depend on Swift `RequestManagerConfiguration` defaults).

**Production transport**: HTTPS (configure per flavor/env — do not ship cleartext if store policy forbids).

---

## 4. Legacy native code (archive reference)

| Tree | Use |
|------|-----|
| `legacy/legacy_bhagavadgita.book_swift/` | Difficult parity questions: iOS-specific API usage, old DB migration behavior |
| `legacy/legacy_bhagavadgita.book_java/` | Same for Android (e.g. `GitaRequest`, `DataService`) |

**Do not** add product features here. Optional: one-off scripts to extract strings/assets.

---

## 5. Non-functional targets (Flutter)

| Topic | Direction |
|-------|-----------|
| Build | `flutter build apk/ipa/...` from `app/bhagavadgita.book` |
| State | Prefer `Controller` / `ChangeNotifier` / small Riverpod or existing pattern — follow repo conventions |
| NFR | Single set of tests for logic; golden tests optional for reader UI |

---

## 6. SDD / VDD delegation

| Topic | Flow |
|-------|------|
| API client | `flows/sdd-bhagavadgita.book-api-client/` |
| Content / quotes | `flows/sdd-bhagavadgita.book-content/` |
| Database | `flows/sdd-bhagavadgita.book-database/`, `sdd-bhagavadgita.book-database-schema/` |
| Audio | `flows/sdd-bhagavadgita.book-audioplayer/` |
| CI/CD | `flows/sdd-bhagavadgita.book-cicd*` |

---

## Approvals

**Approval phrase to advance**: “engineering specifications approved”
