# Implementation Plan: BhagavadGita Book Flutter Refactoring v2

> Version: 1.0  
> Status: DRAFT  
> Last Updated: 2026-04-29  
> Specifications: `flows/sdd-bhagavadgita.book-flutter-refactoring-v2/02-specifications.md`

## Summary

План v2 выполняется по вертикальным срезам с сохранением offline-first гарантий:
1) выравнивание доменной модели и legacy mapping (Java/Swift/DB -> Flutter);
2) усиление bootstrap/sync/storage контуров без регрессий user-data;
3) доведение reader/search/settings/bookmarks/notes до функционального паритета;
4) тестирование и выпуск на Android/iOS.

## Task Breakdown

### Phase 1: Domain & Data Parity Foundation

#### Task 1.1: Составить migration matrix сущностей
- **Description**: Зафиксировать соответствие моделей Java/Swift/DB -> Drift tables + Flutter domain models, включая расхождения по nullable/именам полей.
- **Files**:
  - `flows/sdd-bhagavadgita.book-flutter-refactoring-v2/artifacts/migration-matrix.md` - Create
  - `flows/sdd-bhagavadgita.book-flutter-refactoring-v2/artifacts/migration-matrix.json` - Create
- **Dependencies**: None
- **Verification**: матрица покрывает как минимум Language/Book/Chapter/Shloka/Vocabulary/Quote/Bookmark/Note
- **Complexity**: Medium

#### Task 1.2: Выравнять DTO/mapper слой под legacy payload
- **Description**: Дополнить парсинг `LegacyApiClient` и DTO для устойчивой обработки пустых/частичных полей из legacy endpoint'ов.
- **Files**:
  - `app/bhagavadgita.book/lib/data/remote/legacy_api_client.dart` - Modify
  - `app/bhagavadgita.book/lib/data/remote/dto/*.dart` - Modify
  - `app/bhagavadgita.book/lib/data/remote/legacy_envelope.dart` - Modify
- **Dependencies**: Task 1.1
- **Verification**: unit tests на envelope/code/message/data + fallback парсинг
- **Complexity**: Medium

### Phase 2: Storage, Seed, Snapshot Safety

#### Task 2.1: Расширить схему контента до v2 паритета
- **Description**: Обновить Drift schema/migrations для недостающих полей и сущностей из legacy DB (без смешивания с user-data).
- **Files**:
  - `app/bhagavadgita.book/lib/data/local/tables.dart` - Modify
  - `app/bhagavadgita.book/lib/data/local/app_database.dart` - Modify
  - `app/bhagavadgita.book/lib/data/local/app_database.g.dart` - Modify (generated)
- **Dependencies**: Task 1.1
- **Verification**: миграция поднимается на чистой и существующей БД
- **Complexity**: High

#### Task 2.2: Обновить seed snapshot под v2 минимум
- **Description**: Сформировать и подключить расширенный seed для first-launch offline сценария.
- **Files**:
  - `app/bhagavadgita.book/assets/seed/seed_v1_minimal.json` - Modify
  - `app/bhagavadgita.book/lib/data/seed/seed_installer.dart` - Modify
  - `app/bhagavadgita.book/pubspec.yaml` - Modify (если меняется asset strategy)
- **Dependencies**: Task 2.1
- **Verification**: cold start в airplane mode открывает список глав и чтение
- **Complexity**: High

#### Task 2.3: Усилить atomic snapshot replace
- **Description**: Гарантировать fail-safe replace для контентных таблиц и 100% сохранение `bookmarks`/`notes`.
- **Files**:
  - `app/bhagavadgita.book/lib/data/local/snapshot_repository.dart` - Modify
  - `app/bhagavadgita.book/lib/data/local/user_data_repository.dart` - Modify
- **Dependencies**: Task 2.1
- **Verification**: integration test "sync fails -> old snapshot kept, user data intact"
- **Complexity**: High

### Phase 3: Bootstrap & Sync Orchestration

#### Task 3.1: Доработать bootstrap состояния splash
- **Description**: Отразить состояния init/seed-ready/syncing/offline/error и retry UX без блокировки входа при наличии snapshot.
- **Files**:
  - `app/bhagavadgita.book/lib/features/splash/splash_screen.dart` - Modify
  - `app/bhagavadgita.book/lib/app/bootstrap/bootstrap_coordinator.dart` - Modify
- **Dependencies**: Task 2.2, Task 2.3
- **Verification**: сценарии first launch offline, relaunch online, retry after failure
- **Complexity**: Medium

#### Task 3.2: Расширить sync orchestration под lazy + startup refresh
- **Description**: Улучшить `SyncOrchestrator` и `RefreshPolicy` для startup refresh, ручного refresh и ленивой подгрузки без full-blocking.
- **Files**:
  - `app/bhagavadgita.book/lib/app/sync/sync_orchestrator.dart` - Modify
  - `app/bhagavadgita.book/lib/app/sync/refresh_policy.dart` - Modify
- **Dependencies**: Task 1.2, Task 2.3
- **Verification**: sync обновляет контент, UI продолжает читать локальный snapshot
- **Complexity**: High

### Phase 4: Feature Parity in Flutter UI

#### Task 4.1: Contents/Reader parity с legacy сценариями
- **Description**: Завершить экранную и поведенческую парность для contents/chapter/sloka (включая vocab/commentary/переключатели блоков).
- **Files**:
  - `app/bhagavadgita.book/lib/features/contents/contents_screen.dart` - Modify
  - `app/bhagavadgita.book/lib/features/reader/chapter_screen.dart` - Modify
  - `app/bhagavadgita.book/lib/features/reader/sloka_screen.dart` - Modify
- **Dependencies**: Task 2.1, Task 3.2
- **Verification**: ручной прогон user flow от главы к шлоке офлайн/онлайн
- **Complexity**: High

#### Task 4.2: Search + Settings parity
- **Description**: Довести поиск и reader settings до функциональной эквивалентности legacy (в рамках текущего scope).
- **Files**:
  - `app/bhagavadgita.book/lib/features/search/search_screen.dart` - Modify
  - `app/bhagavadgita.book/lib/features/settings/settings_screen.dart` - Modify
  - `app/bhagavadgita.book/lib/features/settings/reader_settings.dart` - Modify
- **Dependencies**: Task 4.1
- **Verification**: поиск по локальной БД и сохранение настроек после рестарта
- **Complexity**: Medium

#### Task 4.3: Bookmarks/Notes parity
- **Description**: Проверить и доработать UX и хранение закладок/заметок на уровне паритета legacy.
- **Files**:
  - `app/bhagavadgita.book/lib/data/local/user_data_repository.dart` - Modify
  - `app/bhagavadgita.book/lib/features/reader/sloka_screen.dart` - Modify
- **Dependencies**: Task 2.3, Task 4.1
- **Verification**: bookmark/note survives sync replace and app restart
- **Complexity**: Medium

### Phase 5: Validation, Run, and Release Preparation

#### Task 5.1: Unit + integration test coverage
- **Description**: Добавить/обновить тесты bootstrap/sync/repository/feature parity.
- **Files**:
  - `app/bhagavadgita.book/test/**/*.dart` - Modify/Create
- **Dependencies**: Task 3.2, Task 4.3
- **Verification**: `flutter test` проходит стабильно
- **Complexity**: Medium

#### Task 5.2: Platform run verification
- **Description**: Прогнать приложение на Android и iOS, проверить ключевые offline/online сценарии.
- **Files**:
  - `flows/sdd-bhagavadgita.book-flutter-refactoring-v2/04-implementation-log.md` - Modify
- **Dependencies**: Task 5.1
- **Verification**: успешный запуск `flutter run` на обеих платформах
- **Complexity**: Medium

#### Task 5.3: Store release handoff
- **Description**: Подготовить инструкции/чеклист публикации; при явном подтверждении пользователя выполнить публикацию в сторах.
- **Files**:
  - `flows/sdd-bhagavadgita.book-flutter-refactoring-v2/artifacts/release-checklist.md` - Create
- **Dependencies**: Task 5.2
- **Verification**: чеклист complete; публикация запускается только после отдельного подтверждения
- **Complexity**: Low

## Dependency Graph

```text
1.1 -> 1.2 -> 2.1 -> 2.2 -> 3.1 -> 4.1 -> 4.2
               |       |
               v       v
              2.3 ---->3.2 -> 4.3 -> 5.1 -> 5.2 -> 5.3
```

## File Change Summary

| File/Area | Action | Reason |
|----------|--------|--------|
| `flows/sdd-bhagavadgita.book-flutter-refactoring-v2/artifacts/*` | Create | Формализовать mapping и release артефакты |
| `app/bhagavadgita.book/lib/data/remote/*` | Modify | Legacy API compatibility и robust parsing |
| `app/bhagavadgita.book/lib/data/local/*` | Modify | Snapshot safety и schema parity |
| `app/bhagavadgita.book/lib/app/bootstrap/*` | Modify | Startup UX + non-blocking entry |
| `app/bhagavadgita.book/lib/app/sync/*` | Modify | Lazy/startup sync orchestration |
| `app/bhagavadgita.book/lib/features/*` | Modify | Функциональный паритет с legacy |
| `app/bhagavadgita.book/test/*` | Modify/Create | Предотвратить регрессии миграции |

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Несовпадение legacy payload форматов | Medium | High | Defensive parsing + tests from captured payload samples |
| Регрессия офлайн старта | Medium | High | Seed smoke tests + bootstrap fallback checks |
| Потеря user data при sync | Low | High | Separate tables + transactional replace tests |
| Неполный UI parity | Medium | Medium | Explicit parity checklist per feature |
| Рост объема seed | Medium | Medium | Keep minimal guaranteed dataset + incremental sync |

## Rollback Strategy

1. При ошибках v2 sync отключить принудительный refresh и оставить чтение на последнем валидном snapshot.
2. При проблемах миграции БД откатить schema changes и пересоздать контентный snapshot без удаления user tables.
3. При критическом UI regressions временно выключить затронутые фичи feature-flags на уровне конфигурации релиза.

## Checkpoints

- [ ] После Phase 1: migration matrix покрывает все ключевые сущности.
- [ ] После Phase 2: first launch offline стабилен, snapshot replace безопасен.
- [ ] После Phase 3: bootstrap/sync не блокируют вход в чтение.
- [ ] После Phase 4: feature parity достигнут по agreed scope.
- [ ] После Phase 5: тесты зелёные, Android/iOS run верифицирован.

## Open Implementation Questions

- [ ] Включать ли audio parity в этот план или отдельной задачей после core migration?
- [ ] Нужно ли фиксировать 1:1 визуальный parity или достаточно функционального parity?

## Approval

- [ ] Reviewed by: [name]
- [ ] Approved on: [date]
- [ ] Notes: [any conditions or clarifications]
