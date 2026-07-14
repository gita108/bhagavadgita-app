# Implementation Log: bhagavadgita.book-flutter-refactoring

> Started: 2026-04-28  
> Plan: `flows/sdd-bhagavadgita.book-flutter-refactoring/03-plan.md`

## Progress Tracker

| Task | Status | Notes |
|------|--------|-------|
| Phase 0.1 Content audit matrix | Done | Скрипт + артефакты `content-matrix.json/.md` |
| Phase 0.2 v1 language policy doc | Done | `artifacts/v1-language-policy.md` |
| Phase 1 Storage stack | Done | `drift` schema + codegen, app стартует через Splash; `flutter test` проходит |
| Phase 1 Seed installer | Done | Bundled seed asset + installer, Splash ставит seed при отсутствии snapshot |
| Phase 1 Snapshot meta + atomic replace | Done | `SnapshotRepository.replaceSnapshot()` атомарно обновляет content-таблицы, user-таблицы не трогает |
| Phase 2 Legacy API client | Done | `LegacyApiClient` (Dio) + DTOs + envelope parser для `Data/Languages|Books|Chapters|Quotes` |
| Phase 3 Splash/bootstrap | Done | Splash + `BootstrapCoordinator` (seed install / snapshot check) и быстрый вход в app |
| Phase 4 Reader MVP | Done | Contents (главы из DB) + Chapter/Sloka screens (шлоки/словарь из DB) + минимальный seed контент |
| Phase 5 User data | Done | Bookmarks + notes + local search + reader settings подключены в UI |
| Phase 6 Sync orchestration | Done | `RefreshPolicy` + `SyncOrchestrator`; bootstrap планирует фоновый startup sync и atomic snapshot replace |

## Session Log

### Session 2026-04-28

#### Completed

- Реализован скрипт аудита покрытия данных: `scripts/content_audit_matrix.py`
- Сгенерированы артефакты:
  - `flows/sdd-bhagavadgita.book-flutter-refactoring/artifacts/content-matrix.json`
  - `flows/sdd-bhagavadgita.book-flutter-refactoring/artifacts/content-matrix.md`

#### Findings (high-signal)

- В `data/meta/languages.json` перечислены `tr` и `sw`, но в `data/translated/` они не обнаружены (как минимум, отсутствует директория/контент).
- Набор translated-языков в `data/` неравномерен по типам контента (например, `el/ka/hy` без `sloka`, `zh-CN` частично без `sloka`, `ja` “рваный”).

#### Next

- Зафиксировать v1 policy “full vs partial/hidden” на основе артефактов матрицы (Task 0.2).
