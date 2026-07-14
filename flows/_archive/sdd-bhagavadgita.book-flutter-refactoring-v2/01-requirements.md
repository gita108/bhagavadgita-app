# Requirements: BhagavadGita Book Flutter Refactoring v2

> Version: 1.0  
> Status: DRAFT  
> Last Updated: 2026-04-29

## Problem Statement

Текущий продукт и бизнес-логика распределены по legacy-проектам:
- Android Java: `legacy/legacy_bhagavadgita.book_java`
- iOS Swift: `legacy/legacy_bhagavadgita.book_swift`
- Legacy DB/data source: `legacy/legacy_bhagavadgita.book_db`

Целевая кодовая база находится в `app/bhagavadgita.book` (Flutter), но перенос логики, данных, офлайн-поведения и пользовательских сценариев из legacy в единый Flutter-runtime нужно завершить в рамках нового цикла рефакторинга v2.

Цель v2: получить единый Flutter-продукт, который функционально покрывает legacy Java/Swift, использует данные из legacy DB и продолжает работать offline-first без потери пользовательских данных.

## User Stories

### Primary

**As a** пользователь приложения Bhagavad Gita  
**I want** полный функционал чтения, поиска, закладок и заметок в Flutter версии  
**So that** не использовать разные платформенные реализации

**As a** пользователь со слабой сетью  
**I want** запускать и читать приложение офлайн на локальном snapshot  
**So that** иметь стабильный доступ к контенту в любой момент

**As a** владелец продукта  
**I want** перенести доменную и контентную логику из Java/Swift/DB в Flutter  
**So that** дальше развивать одну кодовую базу для iOS и Android

### Secondary

**As a** разработчик  
**I want** унифицировать расхождения между Java и Swift моделями  
**So that** снизить сложность поддержки и уменьшить риск багов при синхронизации

**As a** пользователь  
**I want** чтобы контент обновлялся в фоне и не ломал текущую сессию чтения  
**So that** UX оставался быстрым и надежным

## Acceptance Criteria

### Must Have

1. **Given** legacy-источники Java/Swift/DB  
   **When** выполнен рефакторинг v2  
   **Then** ключевые сценарии (главы, шлоки, переводы, комментарии, словарь, закладки, заметки, поиск, настройки) работают в `app/bhagavadgita.book`

2. **Given** устройство без сети  
   **When** пользователь открывает Flutter-приложение  
   **Then** приложение работает на локальном snapshot без блокировки основного чтения

3. **Given** сеть доступна  
   **When** запускается bootstrap/sync  
   **Then** контент обновляется в фоне, а UI показывает локальные данные без долгого ожидания

4. **Given** пользовательские закладки/заметки уже существуют  
   **When** обновляется контент из сервера/legacy DB  
   **Then** пользовательские данные не теряются и не перезаписываются контентным слоем

5. **Given** целевой runtime Flutter  
   **When** миграция завершена  
   **Then** Java/Swift остаются только как legacy references, а продуктовая логика выполняется в `app/bhagavadgita.book`

### Should Have

- Явный migration checklist по подсистемам (domain, storage, sync, UI screens)
- Единая стратегия сериализации/десериализации для контента и user-data
- Трассировка соответствия сущностей Java/Swift -> Flutter

### Won't Have (This Iteration)

- Миграция всех внешних SDK/аналитики, если они не блокируют core UX
- Внедрение нового backend API, несовместимого с legacy контрактом
- Нефункциональные редизайн-изменения UI вне scope рефакторинга

## Constraints

- **Technical**: Целевая реализация строго в `app/bhagavadgita.book` на Flutter/Dart
- **Source of Truth**: Анализ и перенос из `legacy/legacy_bhagavadgita.book_java`, `legacy/legacy_bhagavadgita.book_swift`, `legacy/legacy_bhagavadgita.book_db`
- **Compatibility**: Сохранить совместимость с текущим backend контрактом legacy
- **Offline-first**: Локальный snapshot обязателен для первого рендера и offline работы
- **Data Safety**: user-data слой должен быть изолирован от обновляемого контентного слоя

## Open Questions

- [ ] Полный перенос экранов 1:1 с legacy обязателен или допускается функциональный эквивалент?
- [ ] Аудио-функции включаются в v2 или выделяются в отдельный этап?
- [ ] В первой поставке обязательны только iOS/Android, или нужен web/desktop профиль Flutter?
- [ ] Какая стратегия обновления выбрана как baseline в v2: full snapshot replace, incremental diff или hybrid?

## References

- `flows/sdd.md`
- `flows/sdd-bhagavadgita.book-flutter-refactoring/01-requirements.md`
- `legacy/legacy_bhagavadgita.book_java`
- `legacy/legacy_bhagavadgita.book_swift`
- `legacy/legacy_bhagavadgita.book_db`
- `app/bhagavadgita.book`

---

## Approval

- [ ] Reviewed by: [name]
- [ ] Approved on: [date]
- [ ] Notes: [any conditions or clarifications]
