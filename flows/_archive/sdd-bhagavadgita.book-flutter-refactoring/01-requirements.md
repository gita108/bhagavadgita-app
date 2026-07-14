# Requirements: BhagavadGita Book Flutter Refactoring

> Version: 1.0  
> Status: DRAFT  
> Last Updated: 2026-04-28

## Problem Statement

Текущий продукт существует в нескольких legacy-реализациях:
- Android Java: `legacy/legacy_bhagavadgita_book_java`
- iOS Swift: `legacy/legacy_bhagavadgita_book_swift`
- Источники данных и DB exports: `legacy/legacy_bhagavadgitabook_db`
- Нормализованные данные проекта: `data/`
- Исторические/промежуточные сборки данных: `bak/`

Новая кодовая база Flutter в `app/bhagavadgita.book` сейчас является пустой заготовкой и не наследует доменную модель, офлайн-поведение и UX-возможности legacy-приложений.

Нужен рефакторинг с переносом продукта в единое Flutter-приложение, которое:
- покрывает основные пользовательские сценарии из legacy Android/iOS;
- использует согласованную доменную модель вместо платформенных расхождений;
- продолжает работать с тем же backend/API и теми же endpoint, которые уже используются в legacy;
- работает в режиме offline-first;
- хранит локальный последний слепок контента и продолжает работать даже при недоступности backend/API;
- умеет лениво догружать и периодически обновлять данные с сервера в фоне без блокировки основного чтения;
- использует `Splash screen` как управляемую точку bootstrap, проверки локального snapshot и запуска фоновой синхронизации.

Это важно, чтобы прекратить поддержку двух разных нативных кодовых баз, получить единый продукт для дальнейшего развития и повысить надежность чтения контента при слабом или отсутствующем интернете.

## User Stories

### Primary

**As a** читатель Бхагавад-гиты  
**I want** читать главы, шлоки, комментарии и словарь в новом Flutter-приложении  
**So that** пользоваться единым современным приложением на Android и iOS

**As a** пользователь с нестабильным интернетом  
**I want** чтобы приложение продолжало работать с последними загруженными или предустановленными данными  
**So that** я не терял доступ к текстам и структуре книги при недоступности сервера

**As a** пользователь  
**I want** чтобы обновления контента догружались лениво и в фоне  
**So that** чтение открывалось быстро, а данные постепенно актуализировались без ручных действий

**As a** пользователь  
**I want** видеть splash screen при старте приложения  
**So that** понимать, что приложение проверяет локальные данные, готовность контента и фоновую загрузку

**As a** разработчик  
**I want** объединить доменную логику legacy Android/iOS в одном Flutter-коде  
**So that** дальнейшая поддержка и развитие происходили в одной кодовой базе

### Secondary

**As a** пользователь  
**I want** иметь закладки, заметки, поиск и настройки отображения  
**So that** не потерять ключевые возможности legacy-приложения

**As a** пользователь  
**I want** при первом запуске получить рабочее приложение даже без сети  
**So that** можно начать читать сразу за счет встроенного базового набора данных

**As a** владелец продукта  
**I want** иметь предсказуемую стратегию миграции данных и фонового обновления  
**So that** можно выпускать новые версии приложения без ломки локального контента

## Acceptance Criteria

### Must Have

1. **Given** новый проект Flutter в `app/bhagavadgita.book`  
   **When** приложение запускается после рефакторинга  
   **Then** пользователь видит рабочий каталог глав и может открыть содержимое книги вместо demo-экрана

2. **Given** устройство без доступа к backend/API  
   **When** пользователь открывает приложение  
   **Then** приложение работает на предустановленном слепке данных или на последнем успешно загруженном локальном слепке

3. **Given** устройство уже получило обновленные данные ранее  
   **When** backend временно недоступен  
   **Then** приложение использует последний локально сохраненный слепок без потери базовой функциональности чтения

4. **Given** приложение имеет доступ к сети  
   **When** пользователь открывает список глав или конкретную шлоку  
   **Then** данные отображаются сразу из локального хранилища, а фоновая синхронизация может обновить их без блокирующего full reload

5. **Given** сервер вернул новую версию части контента  
   **When** фоновая синхронизация завершается успешно  
   **Then** локальный слепок обновляется атомарно и новые данные становятся доступны в UI

6. **Given** legacy Android и iOS содержат основные доменные сущности  
   **When** выполняется рефакторинг  
   **Then** Flutter-версия сохраняет как минимум: главы, шлоки, переводы, комментарии, словарь, закладки, заметки, поиск и настройки чтения

7. **Given** пользователь уже создал локальные заметки и закладки  
   **When** обновляется контентный слепок  
   **Then** пользовательские данные не теряются и не затираются серверным контентом

8. **Given** сервер недоступен на первом запуске  
   **When** приложение только установлено  
   **Then** оно все равно работает на встроенном наборе данных, достаточном для базового чтения

9. **Given** в legacy уже существуют endpoint'ы `Data/Languages`, `Data/Books`, `Data/Chapters`, `Data/Quotes`  
   **When** Flutter-приложение выполняет инициализацию и синхронизацию  
   **Then** оно использует эти же endpoint'ы и совместимый контракт ответа вместо нового параллельного API

10. **Given** пользователь запускает приложение  
    **When** выполняется startup sequence  
    **Then** splash screen показывает состояние инициализации: загрузка встроенного snapshot, проверка локальной БД, запуск фонового обновления или вход в offline fallback

11. **Given** локальные данные уже доступны  
    **When** splash bootstrap завершает критический минимум проверок  
    **Then** пользователь попадает в основное приложение без ожидания полной синхронизации всего контента

### Should Have

- Фоновое периодическое обновление по расписанию или при старте приложения
- Индикация состояния контента: встроенный слепок, локально обновленный слепок, идет обновление, ошибка синхронизации
- Поддержка выборочной lazy loading стратегии по главам/языкам, а не только полного обновления всей базы
- Общая архитектура, пригодная для дальнейшего добавления аудио и дополнительных языков
- Показ полезной информации на splash screen: прогресс, версия локальных данных, состояние сети, режим offline

### Won't Have (This Iteration)

- Полная миграция всех второстепенных инфраструктурных возможностей legacy (analytics, push, рекламные/сторонние SDK)
- Двусторонняя серверная синхронизация пользовательских заметок между устройствами
- CMS или редактор контента внутри приложения
- Миграция legacy UI один-в-один на уровне визуальных деталей

## Constraints

- **Technical**: Новая реализация должна быть построена в `app/bhagavadgita.book` на Flutter/Dart
- **Source of Truth**: Надо использовать и согласовать данные/поведение из `legacy/legacy_bhagavadgita_book_java`, `legacy/legacy_bhagavadgita_book_swift`, `legacy/legacy_bhagavadgitabook_db`
- **Content Sources**: Для seed snapshot и сверки учитывать `data/` (основной нормализованный слой) и `bak/` (резерв/история, rich JSON с audio refs)
- **Backend Compatibility**: В первой версии Flutter должен использовать существующие endpoint'ы legacy backend без обязательного изменения серверного API
- **Offline-first**: Локальный слепок контента обязателен; отсутствие сети не должно ломать базовое чтение
- **Sync safety**: Обновление контента должно быть безопасным, чтобы не оставлять приложение с частично обновленной базой
- **User Data Isolation**: Закладки, заметки и прочие пользовательские локальные данные должны храниться отдельно от обновляемого серверного контента
- **Performance**: Первый рендер основных экранов должен опираться на локальные данные, без обязательного ожидания сети
- **Process**: Работа идет по SDD, поэтому после requirements нужно согласование перед переходом к specifications

## Open Questions

- [x] В качестве стартового backend/API использовать существующие legacy endpoint'ы: `Data/Languages`, `Data/Books`, `Data/Chapters`, `Data/Quotes`
- [ ] Нужен ли в первой версии аудио-функционал или его можно вынести в отдельный этап после текстового офлайн-first ядра?
- [ ] Какие платформы обязательны для первой поставки: только iOS/Android или также web/desktop из Flutter-шаблона?
- [ ] Должен ли встроенный слепок содержать всю книгу и все поддерживаемые языки, или только минимальный базовый набор?
- [ ] Какая стратегия обновления предпочтительнее: полный snapshot replace, инкрементальные diff-обновления или гибрид?
- [ ] Нужно ли переносить iPad/tablet split-view поведение в первой Flutter-версии?
- [ ] Должен ли splash screen быть только техническим bootstrap-экраном или также содержать quote/day branding и быстрый offline status?

## References

- `flows/sdd.md`
- `flows/sdd-gitabook-structure/01-requirements.md`
- `flows/sdd-gitabook-database/01-requirements.md`
- `legacy/legacy_bhagavadgita_book_java`
- `legacy/legacy_bhagavadgita_book_swift`
- `legacy/legacy_bhagavadgitabook_db`
- `data/`
- `bak/`
- `legacy/legacy_bhagavadgita_book_java/app/src/main/java/com/ethnoapp/bgita/server/DataService.java`
- `legacy/legacy_bhagavadgita_book_swift/Gita/Model/DataAccess/GitaRequestManager.swift`
- `legacy/legacy_bhagavadgita_book_swift/Gita/AppDelegate.swift`
- `app/bhagavadgita.book`

---

## Legacy Analysis Additions
> Added by /legacy on 2026-04-29

### Domain Entities from Legacy Code

| Entity | Swift Location | Java Location | Fields |
|--------|----------------|---------------|--------|
| Language | `DataClasses/Language.swift` | `model/Language.java` | id, name, code, isSelected* |
| Book | `DataClasses/Book.swift` | `model/Book.java` | id, languageId, name, initials, chaptersCount, isDownloaded* |
| Chapter | `DataClasses/Chapter.swift` | `model/Chapter.java` | id, bookId, name, order, shlokas[] |
| Shloka | `DataClasses/Shloka.swift` | `model/Sloka.java` | id, chapterId, name, text, transcription, translation, comment, order, audio, audioSanskrit, vocabularies[], isBookmark*, note* |
| Vocabulary | `DataClasses/Vocabulary.swift` | `model/Vocabulary.java` | shlokaId, text, translation |
| Quote | `DataClasses/Quote.swift` | `model/Quote.java` | author, text |
| Bookmark | `DataClasses/Bookmark.swift` | (in Sloka) | chapterOrder, shlokaOrder, isDeleted |

*\* = client-only field, not from API*

### API Contract Details

**Base URL**: `http://app.bhagavadgitaapp.online/api/`

| Endpoint | Method | Request | Response Structure |
|----------|--------|---------|-------------------|
| `Data/Languages` | POST | `{}` | `{code: 0, data: [Language]}` |
| `Data/Books` | POST | `{ids: [int]}` | `{code: 0, data: [Book]}` |
| `Data/Chapters` | POST | `{bookId: int}` | `{code: 0, data: [Chapter]}` (nested with slokas and vocabularies) |
| `Data/Quotes` | POST | `{}` | `{code: 0, data: Quote}` |

### Platform Differences to Unify

| Feature | iOS (Swift) | Android (Java) | Flutter Target |
|---------|-------------|----------------|----------------|
| Book download | DownloadInfo struct | STATUS_* int constants | Unified state enum |
| User notes | UserComment entity | note field in Sloka | Separate UserNote entity |
| Bookmarks | Separate Bookmarks table | isBookmark field + table | Separate Bookmarks table |
| Local DB | DbConnection/DbCommand | DbContext/DbSet ORM | Drift/SQLite |

### Verified Content Statistics

| Entity | Records | Source |
|--------|---------|--------|
| Languages | 4 | en, ru, de, spa |
| Books | 6 | 3 EN, 1 RU, 1 DE, 1 SPA |
| Chapters | 143 | 18 per book edition |
| Slokas | ~700 | All Bhagavad Gita verses |
| Vocabularies | ~5000 | Word-by-word breakdown |
| Quotes | ~150 | Multi-language |

### Legacy Source Files Reference

- Swift API: `GitaRequestManager.swift:84-151`
- Java API: `DataService.java:12-34`
- Full analysis: `flows/legacy/understanding/_root.md`

---

## Approval

- [ ] Reviewed by: [name]
- [ ] Approved on: [date]
- [ ] Notes: [any conditions or clarifications]
