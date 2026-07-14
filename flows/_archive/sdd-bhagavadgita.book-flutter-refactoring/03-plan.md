# Implementation Plan: BhagavadGita Book Flutter Refactoring

> Version: 1.0  
> Status: DRAFT  
> Last Updated: 2026-04-28  
> Specifications: [02-specifications.md](./02-specifications.md)

## Summary

План делает 3 вещи в правильном порядке:
1) фиксирует картину данных (матрица покрытия по `data/`, `bak/`, `legacy_bhagavadgitabook_db`);  
2) собирает offline-first ядро Flutter (seed snapshot + локальная БД + reader);  
3) добавляет совместимость с legacy backend endpoint'ами и фоновые обновления (stale-while-revalidate).

## Task Breakdown

### Phase 0: Content Audit Matrix (обязательный фундамент)

#### Task 0.1: Построить матрицу покрытия контента
- **Description**: Автоматически собрать компактный отчет `source × language × chapter × content_types`.
- **Files**:
  - `scripts/content_audit_matrix.py` — Create
  - `flows/sdd-bhagavadgita-book-flutter-refactoring/artifacts/content-matrix.md` — Create
  - `flows/sdd-bhagavadgita-book-flutter-refactoring/artifacts/content-matrix.json` — Create
- **Dependencies**: None
- **Verification**:
  - отчет перечисляет языки, главы 01–18 и типы данных (S/T/C/V/M/A/Q)
  - отдельно отмечены “full” vs “partial” языки для v1 UI
- **Complexity**: Medium

#### Task 0.2: Зафиксировать v1 набор языков (full vs partial/hidden)
- **Description**: На основании матрицы определить, какие языки показываем в UI как полноценные, а какие скрываем/маркируем как “partial”.
- **Files**:
  - `flows/sdd-bhagavadgita-book-flutter-refactoring/artifacts/v1-language-policy.md` — Create
- **Dependencies**: Task 0.1
- **Verification**: документ с явными правилами UI (например: “el/ka/hy показывать только если есть sloka”)
- **Complexity**: Low

### Phase 1: Flutter Foundation (app shell + storage)

#### Task 1.1: Выбрать и подключить storage stack
- **Description**: Подключить SQLite-based локальную БД (предпочтительно `drift`), подготовить базовый слой миграций.
- **Files**:
  - `app/bhagavadgita.book/pubspec.yaml` — Modify
  - `app/bhagavadgita.book/lib/data/local/` — Create
  - `app/bhagavadgita.book/lib/data/local/app_database.dart` — Create
- **Dependencies**: Task 0.2
- **Verification**: локальная БД открывается, миграция выполняется, smoke-test проходит
- **Complexity**: Medium

#### Task 1.2: Seed snapshot installer (bundled assets → local DB)
- **Description**: Установить bundled seed snapshot при первом запуске или при восстановлении после corruption.
- **Files**:
  - `app/bhagavadgita.book/assets/seed/` — Create
  - `app/bhagavadgita.book/pubspec.yaml` — Modify (assets)
  - `app/bhagavadgita.book/lib/data/seed/seed_installer.dart` — Create
- **Dependencies**: Task 1.1
- **Verification**: airplane-mode first launch → данные доступны локально
- **Complexity**: High

#### Task 1.3: Snapshot meta + atomic replace strategy
- **Description**: Реализовать `snapshot_meta` и безопасную замену контента (staging → swap) без затрагивания user tables.
- **Files**:
  - `app/bhagavadgita.book/lib/data/local/snapshot_meta_dao.dart` — Create
  - `app/bhagavadgita.book/lib/data/local/snapshot_repository.dart` — Create
- **Dependencies**: Task 1.1
- **Verification**: тест “failed replace keeps previous snapshot” + “user data preserved”
- **Complexity**: High

### Phase 2: Backend compatibility layer (legacy endpoints)

#### Task 2.1: Legacy API client + DTO mapping
- **Description**: Реализовать HTTP клиент под `Data/Languages`, `Data/Books`, `Data/Chapters`, `Data/Quotes` и парсинг legacy JSON envelope.
- **Files**:
  - `app/bhagavadgita.book/lib/data/remote/legacy_api_client.dart` — Create
  - `app/bhagavadgita.book/lib/data/remote/dto/` — Create
  - `app/bhagavadgita.book/lib/data/remote/legacy_envelope.dart` — Create
- **Dependencies**: Task 1.1
- **Verification**: unit tests на парсинг code/data/message + happy path для 4 endpoint'ов
- **Complexity**: Medium

#### Task 2.2: Normalization pipeline (DTO → entities → snapshot)
- **Description**: Собрать единый `ContentSnapshot` из ответов backend и/или из `bak` fallback.
- **Files**:
  - `app/bhagavadgita.book/lib/data/mappers/` — Create
  - `app/bhagavadgita.book/lib/domain/models/` — Create
- **Dependencies**: Task 2.1, Task 1.3
- **Verification**: end-to-end: remote fetch → local DB snapshot replaced → UI обновилась
- **Complexity**: High

### Phase 3: Splash + bootstrap coordinator

#### Task 3.1: Splash screen и состояния bootstrap
- **Description**: Сделать splash экран с состояниями: initializing / seed restore / ready / syncing / offline / failed.
- **Files**:
  - `app/bhagavadgita.book/lib/features/splash/` — Create
  - `app/bhagavadgita.book/lib/app/router.dart` — Create/Modify
- **Dependencies**: Task 1.2, Task 2.1
- **Verification**: сценарии: first launch offline, first launch online, relaunch with snapshot
- **Complexity**: Medium

#### Task 3.2: BootstrapCoordinator (быстрый вход + фоновые обновления)
- **Description**: Реализовать policy: если локальные данные есть → не блокировать вход, sync в фоне.
- **Files**:
  - `app/bhagavadgita.book/lib/app/bootstrap/bootstrap_coordinator.dart` — Create
  - `app/bhagavadgita.book/lib/app/bootstrap/sync_policy.dart` — Create
- **Dependencies**: Task 3.1, Task 1.3, Task 2.2
- **Verification**: тест таймаута и перехода в main screen до окончания sync
- **Complexity**: High

### Phase 4: Reader MVP (contents → chapter → shloka)

#### Task 4.1: Contents (список глав)
- **Description**: Экран списка глав из локальной БД.
- **Files**:
  - `app/bhagavadgita.book/lib/features/contents/` — Create
- **Dependencies**: Task 1.1, Task 1.2
- **Verification**: офлайн просмотр глав 1–18
- **Complexity**: Medium

#### Task 4.2: Chapter + Shloka reader
- **Description**: Экран чтения шлоки с блоками sanskrit/translit/translation/comment/vocabulary и toggle-опциями.
- **Files**:
  - `app/bhagavadgita.book/lib/features/reader/` — Create
- **Dependencies**: Task 4.1
- **Verification**: офлайн чтение + UI правильно отображает partial языки
- **Complexity**: High

### Phase 5: User data (bookmarks, notes, settings, search)

#### Task 5.1: Bookmarks + Notes (изолировано от snapshot)
- **Description**: Реализовать таблицы и UI для закладок и заметок.
- **Files**:
  - `app/bhagavadgita.book/lib/data/local/user_data_dao.dart` — Create
  - `app/bhagavadgita.book/lib/features/bookmarks/` — Create
  - `app/bhagavadgita.book/lib/features/notes/` — Create
- **Dependencies**: Task 1.1, Task 4.2
- **Verification**: “bookmark persists after snapshot replace”
- **Complexity**: Medium

#### Task 5.2: Search (локальный)
- **Description**: Локальный поиск по шлокам/переводам (SQLite LIKE/FTS при необходимости).
- **Files**:
  - `app/bhagavadgita.book/lib/features/search/` — Create
- **Dependencies**: Task 1.1, Task 4.2
- **Verification**: поиск по ru/en и по sanskrit/translit не ломает unicode
- **Complexity**: High

### Phase 6: Sync orchestration (lazy + periodic)

#### Task 6.1: SyncOrchestrator (startup + refresh + lazy)
- **Description**: Реализовать orchestrator, который:
  - делает startup sync,
  - обновляет активную книгу,
  - ставит refresh главы в очередь при открытии,
  - ведет `sync_events`.
- **Files**:
  - `app/bhagavadgita.book/lib/app/sync/sync_orchestrator.dart` — Create
  - `app/bhagavadgita.book/lib/data/local/sync_events_dao.dart` — Create
- **Dependencies**: Task 2.2, Task 3.2
- **Verification**: offline fallback + safe retries, отсутствие partial writes
- **Complexity**: High

#### Task 6.2: Periodic refresh policy (foreground-triggered v1)
- **Description**: В v1: периодическое обновление в foreground (app start / resume) без background scheduler. Background scheduler оставить на follow-up.
- **Files**:
  - `app/bhagavadgita.book/lib/app/sync/refresh_policy.dart` — Create
- **Dependencies**: Task 6.1
- **Verification**: обновления не мешают чтению, UI рефрешится после sync
- **Complexity**: Medium

## Dependency Graph

```text
0.1 → 0.2 → 1.1 → 1.2 → 3.1 → 3.2 → 4.1 → 4.2 → 5.1
                     └→ 1.3 → 2.1 → 2.2 ─┬→ 6.1 → 6.2
                                         └→ 5.2
```

## File Change Summary

| Area | Action | Reason |
|------|--------|--------|
| `flows/.../artifacts/*` | Create | Матрица покрытия + политика языков v1 |
| `scripts/content_audit_matrix.py` | Create | Автоматизировать аудит `data/bak/legacy_db` |
| `app/bhagavadgita.book/assets/seed/` | Create | Bundled seed snapshot для офлайна |
| `app/bhagavadgita.book/lib/data/*` | Create | DB, репозитории, seed installer, API client, mappers |
| `app/bhagavadgita.book/lib/features/*` | Create | Splash + reader + bookmarks + search |

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Неровное покрытие translated языков | High | Medium | policy “full vs partial”, lazy backfill, скрытие неполных |
| Backend contract drift | Medium | High | envelope parser + fail-closed snapshot replace |
| Seed snapshot слишком большой | Medium | High | выбрать v1 языки/книги, сжатие/packaging, incremental seed |
| Unicode/RTL issues | Medium | Medium | тесты на `ar/he`, шрифты, directionality |
| Snapshot replace повреждает user data | Low | High | отдельные таблицы + транзакции + тесты |

## Rollback Strategy

- Не менять legacy источники.
- Любая проблема с sync → приложение продолжает работать на последнем локальном snapshot/seed.
- При проблемах со схемой DB → bump schemaVersion и миграция; в крайнем случае reset content snapshot без удаления user data.

## Checkpoints

- После Phase 0: согласован v1 набор языков и политика partial/full.
- После Phase 1: airplane-mode install работает (seed → reader).
- После Phase 2–3: online sync обновляет snapshot без блокировки входа.
- После Phase 4–5: reader + bookmarks/notes/search работают офлайн.
- После Phase 6: lazy + periodic refresh не ломают UX и не теряют данные.

---

## Approval

- [ ] Reviewed by: [name]
- [ ] Approved on: [date]
- [ ] Notes: [any conditions or clarifications]
