# Specifications: BhagavadGita Book Flutter Refactoring

> Version: 1.0  
> Status: DRAFT  
> Last Updated: 2026-04-28  
> Requirements: [01-requirements.md](./01-requirements.md)

## Overview

Будет построено новое Flutter-приложение в `app/bhagavadgita.book`, которое объединяет legacy-функциональность Android/iOS поверх существующего backend API и локального offline-first слоя.

Ключевая архитектурная идея:
- UI всегда работает от локального хранилища;
- при старте `Splash screen` выполняет bootstrap минимального критического пути;
- backend используется через уже существующие endpoint'ы `Data/Languages`, `Data/Books`, `Data/Chapters`, `Data/Quotes`;
- локальный контент хранится как snapshot-слой, который можно безопасно обновлять;
- пользовательские данные хранятся отдельно и не затираются обновлениями snapshot;
- фоновая синхронизация использует `stale-while-revalidate`: сначала локальные данные, потом мягкое обновление.

Политика источников контента (для seed + восстановления пробелов):
- **Primary (канон для seed)**: `data/` (нормализованная структура по языкам/главам/файлам)
- **Secondary (rich fallback)**: `bak/chapters/original/chapter-XX.json` (богатый JSON: переводы, vocabulary, meta, audio refs)
- **Tertiary (legacy verification / audio & RU cross-check)**: `legacy/legacy_bhagavadgitabook_db` (CSV-снимок БД: audio refs, RU translation/transcription/vocabulary, quotes)

Цель: Flutter seed snapshot собирается так, чтобы приложение работало офлайн даже при частичной неполноте translated-языков, а sync pipeline мог дозаполнять пробелы со временем.

## Affected Systems

| System | Impact | Notes |
|--------|--------|-------|
| `app/bhagavadgita.book/lib/` | Create / Modify | Новая Flutter-архитектура приложения |
| `app/bhagavadgita.book/pubspec.yaml` | Modify | Зависимости для local DB, networking, state management, assets |
| `app/bhagavadgita.book/assets/` | Create | Встроенный seed snapshot, splash assets, локальные метаданные |
| `app/bhagavadgita.book/test/` | Modify | Unit/widget/integration tests для bootstrap, repositories, sync |
| Existing legacy backend API | Reuse | Совместимость с `Data/Languages`, `Data/Books`, `Data/Chapters`, `Data/Quotes` |
| Local storage layer | Create | SQLite/Drift/Isar-backed offline snapshot + separate user data tables |
| App startup flow | Create | Splash/bootstrap orchestration |
| Content sources (`data/`, `bak/`, `legacy_bhagavadgitabook_db`) | Reuse | Сборка seed snapshot и rules для заполнения пробелов |

## Architecture

### Component Diagram

```text
┌─────────────────────────────────────────────────────────────────┐
│                         Presentation Layer                      │
│  Splash  Contents  Chapter  Shloka  Search  Bookmarks Settings │
└──────────────────────────────┬──────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                         Application Layer                       │
│ BootstrapCoordinator  SyncOrchestrator  ReaderFacade           │
│ SearchFacade          BookmarkService   NoteService            │
└───────────────┬─────────────────────────┬───────────────────────┘
                │                         │
                ▼                         ▼
┌───────────────────────────────┐  ┌──────────────────────────────┐
│        Domain Layer           │  │     Background Processes     │
│ Repositories / Entities /     │  │ startup sync / periodic sync │
│ policies / use cases          │  │ lazy chapter refresh         │
└───────────────┬───────────────┘  └──────────────┬───────────────┘
                │                                 │
                ▼                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                           Data Layer                            │
│ ApiClient  SnapshotStore  UserStore  AssetSeedLoader           │
│ DTO mappers  SyncMetadataStore  NetworkStatus                  │
└───────────────┬───────────────────────────┬─────────────────────┘
                │                           │
                ▼                           ▼
┌───────────────────────────────┐  ┌──────────────────────────────┐
│ Existing backend API          │  │ Local database + file assets │
│ Data/Languages                │  │ content snapshot             │
│ Data/Books                    │  │ user data                    │
│ Data/Chapters                 │  │ sync metadata                │
│ Data/Quotes                   │  │ seed snapshot                │
└───────────────────────────────┘  └──────────────────────────────┘
```

### Startup and Splash Flow

```text
App start
  ↓
Load app config + open local DB
  ↓
Check if seeded snapshot exists
  ├─ no → install bundled seed snapshot
  └─ yes → continue
  ↓
Load local settings + selected language/book/chapter
  ↓
Show Splash state:
  - local snapshot ready
  - sync pending / syncing / offline
  ↓
Run bootstrap sync policy
  ├─ if local data exists: enter app immediately after minimum checks
  └─ if local data missing/corrupt: block on seed restore or critical fetch
  ↓
Navigate to main app
  ↓
Continue lazy sync in background
```

### Data Flow

```text
Seed assets or last local snapshot
        ↓
  SnapshotStore exposes reactive readers
        ↓
   UI renders chapters / slokas / settings
        ↓
 SyncOrchestrator checks network + freshness
        ↓
 API client requests Data/Languages, Data/Books, Data/Chapters, Data/Quotes
        ↓
 DTO mappers normalize legacy payloads
        ↓
 Staging transaction writes refreshed snapshot
        ↓
 Snapshot version updated atomically
        ↓
 UI refreshes from local DB
```

## Interfaces

### New Interfaces

```dart
abstract interface class LegacyApiClient {
  Future<List<LanguageDto>> getLanguages();
  Future<List<BookDto>> getBooks(List<int> languageIds);
  Future<List<ChapterDto>> getChapters(int bookId);
  Future<QuoteDto?> getQuote();
}
```

```dart
abstract interface class SnapshotRepository {
  Future<bool> hasUsableSnapshot();
  Future<SnapshotVersion?> getCurrentVersion();
  Stream<List<ChapterSummary>> watchChapters(int bookId);
  Stream<ShlokaViewModel> watchShloka(int bookId, int chapterId, int shlokaId);
  Future<void> replaceSnapshot(ContentSnapshot snapshot, SnapshotVersion version);
}
```

```dart
abstract interface class UserDataRepository {
  Stream<Set<int>> watchBookmarks();
  Future<void> setBookmark(int shlokaId, bool value);
  Future<String?> getNote(int shlokaId);
  Future<void> saveNote(int shlokaId, String note);
}
```

```dart
abstract interface class SyncPolicy {
  Future<BootstrapDecision> evaluate(BootstrapContext context);
}
```

```dart
abstract interface class SyncOrchestrator {
  Future<BootstrapResult> runStartupSync();
  Future<SyncResult> syncIfStale();
  Future<SyncResult> refreshBook(int bookId);
}
```

### Modified Interfaces

- У Flutter-клиента будет новый слой совместимости с legacy API, но без изменения server contract.
- Reader screen будет работать не напрямую с raw API DTO, а через локально собранный `ShlokaViewModel`, который объединяет:
  - основную шлоку;
  - transliteration;
  - translations;
  - comment;
  - vocabulary;
  - bookmark/note state.

## Data Models

### New Types

```dart
class SnapshotVersion {
  final String contentHash;
  final DateTime fetchedAt;
  final String source; // bundled_seed | remote_sync
  final int schemaVersion;
}
```

```dart
class BootstrapResult {
  final bool usedBundledSeed;
  final bool usedLocalSnapshot;
  final bool syncStarted;
  final bool syncFinishedBeforeNavigation;
  final bool offlineFallback;
}
```

```dart
class ContentSnapshot {
  final List<LanguageEntity> languages;
  final List<BookEntity> books;
  final List<ChapterEntity> chapters;
  final List<ShlokaEntity> shlokas;
  final List<VocabularyEntity> vocabularies;
  final QuoteEntity? quoteOfTheDay;
}
```

```dart
class ShlokaViewModel {
  final int shlokaId;
  final String title;
  final String? sanskrit;
  final String? transliteration;
  final List<TranslationBlock> translations;
  final String? comment;
  final List<VocabularyItem> vocabulary;
  final bool isBookmarked;
  final String? note;
}
```

### Local Schema

Контентный слой:
- `languages`
- `books`
- `chapters`
- `shlokas`
- `vocabularies`
- `quotes`
- `snapshot_meta`
- `sync_events`

Пользовательский слой:
- `user_settings`
- `bookmarks`
- `notes`
- `reading_progress`

Служебный слой:
- `bootstrap_state`
- `pending_sync_tasks`

### Content Coverage Matrix (build-time artifact)

Для сборки seed snapshot и контроля качества добавляется артефакт “матрица покрытия”:

- Оси: `source × language × chapter × content_types`
- Типы: `sloka`, `translit`, `comment`, `vocabulary`, `meta`, `audioRefs`, `quotes`
- Выход: компактный JSON/MD отчет, используемый на этапе сборки seed и в CI/ручной проверке.

### Schema Changes

По сравнению с legacy нужно нормализовать хранение:
- не хранить bookmark/note внутри таблицы шлок;
- отделить snapshot-данные от пользовательских данных;
- добавить `snapshot_meta` для версионирования и безопасной замены контента;
- добавить `sync_events` и `bootstrap_state` для восстановления после прерывания startup/sync.

## Behavior Specifications

### Happy Path

1. Пользователь запускает приложение.
2. `Splash screen` открывает локальную БД и проверяет наличие валидного snapshot.
3. Если локальный snapshot отсутствует, устанавливается bundled seed snapshot из assets.
4. Экран показывает, что локальные данные готовы, и запускает сетевую проверку актуальности.
5. Если сеть доступна, приложение вызывает:
   - `Data/Languages`
   - `Data/Books`
   - `Data/Chapters` для активной книги или стартового набора книг
   - `Data/Quotes` опционально для стартового контента
6. Ответы нормализуются в общий `ContentSnapshot`.
7. Новый snapshot записывается в staging transaction и атомарно заменяет старый.
8. Пользователь попадает в основной экран без ожидания полного фонового обновления, если локальные данные уже были доступны.
9. UI продолжает читать только из локальной БД, автоматически отражая обновления после sync.

### Lazy Loading Strategy

1. При старте грузится минимальный seed snapshot.
2. Затем синхронизируются:
   - список языков;
   - список книг;
   - стартовая книга/глава;
   - прочие главы по мере открытия или по фоновой очереди.
3. Если пользователь открывает еще не актуализированную главу, UI показывает локальную версию, а refresh ставится в фоновую очередь.
4. Периодический sync проверяет freshness и догружает обновления без блокировки чтения.

### Splash States

`Splash screen` обязан поддерживать следующие состояния:
- `initializing_local_store`
- `restoring_seed_snapshot`
- `local_snapshot_ready`
- `checking_updates`
- `sync_in_progress`
- `offline_mode`
- `startup_failed`

### Edge Cases

| Case | Trigger | Expected Behavior |
|------|---------|-------------------|
| First launch without network | App installed, backend unavailable | Install bundled seed snapshot and enter app offline |
| Corrupted local snapshot | DB open succeeds but snapshot invalid | Reset content snapshot, preserve user data, restore bundled seed |
| Partial remote sync failure | One endpoint fails during refresh | Keep previous snapshot active, log failure, retry later |
| Empty backend response | API returns valid but empty data | Reject snapshot replacement, keep previous local content |
| App killed during sync | Startup or refresh interrupted | On next launch detect unfinished sync and resume safely |
| User data exists during snapshot replace | Bookmarks/notes present | Preserve user tables untouched |
| Network slow | Splash bootstrap network check delayed | Navigate using local snapshot after timeout threshold |
| Quote endpoint fails | `Data/Quotes` unavailable | Continue startup without blocking reader |

### Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| No local snapshot and no seed | Packaging/config error | Show fatal startup state with retry diagnostics |
| Network unreachable | Offline device or server down | Use local/seed snapshot and mark offline mode |
| Invalid API payload | Backend contract drift | Reject incoming payload, record sync event, keep previous snapshot |
| DB write failure | Storage full / schema issue | Abort snapshot swap, preserve old snapshot, expose non-blocking error |
| Mapping failure | Legacy DTO incompatible with expected schema | Log sync error, keep old content, do not crash reader UI |

## Dependencies

### Requires

- Existing legacy backend endpoints:
  - `Data/Languages`
  - `Data/Books`
  - `Data/Chapters`
  - `Data/Quotes`
- Flutter storage/network stack
- Bundled seed snapshot inside Flutter app assets
- Data mapping rules from legacy Android/iOS/domain exports

### Blocks

- Core app implementation in `app/bhagavadgita.book/lib/`
- Bootstrap and splash implementation
- Local DB schema design and migration code
- Repository and sync orchestration implementation

## Integration Points

### External Systems

- Legacy HTTP backend at the same host pattern used in iOS/Android legacy
- Optional network connectivity monitoring
- Local filesystem/assets for seed snapshot payload

### Internal Systems

- Flutter app navigation
- Reader feature modules
- Search/bookmarks/notes/settings modules
- Future audio download subsystem

## Testing Strategy

### Unit Tests

- [ ] `SyncPolicy` - decisions for first launch, stale snapshot, offline fallback
- [ ] `LegacyApiClient` mappers - parse legacy payloads into normalized DTO/entities
- [ ] `SnapshotRepository` - atomic replace and snapshot version readback
- [ ] `UserDataRepository` - bookmarks and notes remain isolated from snapshot updates
- [ ] `BootstrapCoordinator` - navigation decision timing and splash states

### Integration Tests

- [ ] First launch without network installs bundled seed and opens app
- [ ] Launch with existing local snapshot opens app before remote sync completes
- [ ] Failed sync leaves previous snapshot intact
- [ ] Snapshot refresh updates visible content after local DB write
- [ ] Reader loads chapter/shloka from local DB without network

### Manual Verification

- [ ] Launch on clean install in airplane mode
- [ ] Launch with network and verify splash transitions to main app quickly
- [ ] Kill app during sync and relaunch
- [ ] Add bookmarks/notes, then trigger content refresh and verify preservation
- [ ] Open quote flow with backend available and unavailable

## Migration / Rollout

### Phase 1

Собрать Flutter skeleton:
- app shell
- routing
- splash/bootstrap coordinator
- local DB schema
- seed snapshot loading

Параллельно:
- определить v1 набор языков для UI (full vs partial) на основе матрицы покрытия
- зафиксировать правила приоритетов источников (data → bak → legacy DB) для seed

### Phase 2

Подключить backend compatibility layer:
- `Data/Languages`
- `Data/Books`
- `Data/Chapters`
- `Data/Quotes`
- DTO parsing and normalization

### Phase 3

Подключить reader features:
- contents
- chapter/shloka screen
- bookmarks
- notes
- search
- settings

### Phase 4

Добавить background sync и stale-while-revalidate refresh.

### Phase 5

Опционально вынести аудио и tablet-specific UX в отдельный follow-up.

## Open Design Questions

- [ ] Какой объем данных должен входить в bundled seed: одна книга/язык по умолчанию или весь минимально необходимый каталог?
- [ ] Какие языки считаются “full” для v1 UI, а какие “partial/hidden” до дозаполнения (на основе матрицы покрытия)?
- [ ] Выбирать ли в первой реализации `Drift + sqlite3` как базовый storage stack или взять более простой local store?
- [ ] Нужен ли `Data/Quotes` на splash screen сразу или только после входа в основное приложение?
- [ ] Делать ли refresh только активной книги на старте или нескольких default books/languages?
- [ ] Нужен ли отдельный background worker scheduler, или достаточно startup-triggered + foreground refresh?

---

## Approval

- [ ] Reviewed by: [name]
- [ ] Approved on: [date]
- [ ] Notes: [any conditions or clarifications]
