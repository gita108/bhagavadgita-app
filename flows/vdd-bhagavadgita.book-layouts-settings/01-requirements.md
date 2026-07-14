# Requirements: Settings (Languages + Audio) for Bhagavad Gita Flutter App

> Version: 1.0  
> Status: DRAFT  
> Last Updated: 2026-04-30

## Problem Statement

В `app/bhagavadgita.book` сейчас есть только базовые “reader toggles” (показывать санскрит/транслит/перевод/комментарий/словарь), но нет полноценного экрана настроек, который:

- управляет **языками контента** (переводы глав/шлок и связанные книги/трактовки)
- управляет **языком интерфейса** (локализация UI внутри приложения)
- управляет **аудио** (перевод/санскрит: включить, скачать/удалить, прогресс, автоплей)
- управляет **наборами книг/трактовок** (скачивание/удаление книг по выбранным языкам)

Нужно перенести UX-паттерны из legacy-проектов (Android Java + iOS Swift и связанных приложений) и оформить их как VDD-артефакты для реализации во Flutter.

## User Stories

### Primary

**As a** читатель  
**I want** управлять отображаемыми блоками на экране шлоки (санскрит/транслит/перевод/комментарий/словарь)  
**So that** чтение было удобным под мой сценарий.

**As a** многоязычный пользователь  
**I want** выбрать язык(и) контента (переводы глав/шлок)  
**So that** я видел переводы на предпочитаемом языке и мог сравнивать.

**As a** пользователь приложения  
**I want** выбрать язык интерфейса приложения  
**So that** UI был на нужном мне языке независимо от системных настроек (при желании).

**As a** пользователь, который слушает  
**I want** включать/выключать аудио (перевод и/или санскрит), скачивать/удалять и видеть прогресс  
**So that** я мог слушать оффлайн и контролировать место на устройстве.

### Secondary

**As a** исследователь/читатель  
**I want** скачивать и удалять книги/трактовки (“Interpretations/Books”) по выбранным языкам  
**So that** я мог читать разные трактовки и не хранить лишнее.

## Acceptance Criteria

### Must Have

1. **Given** я открываю Settings  
   **When** экран загружается  
   **Then** я вижу секции: Languages, Display, Audio, Interpretations/Books (как в legacy).

2. **Given** секция “Display”  
   **When** я меняю переключатели (Sanskrit/Transliteration/Translation/Comments/Vocabulary)  
   **Then** изменения сохраняются и применяются к `SlokaScreen` сразу и после перезапуска (как сейчас через `ReaderSettingsController`).

3. **Given** секция “Languages”  
   **When** я открываю выбор языков контента  
   **Then** я могу включать несколько языков контента, а минимум один язык остаётся выбранным (legacy: нельзя снять “последний” язык, связанный с default book).

4. **Given** секция “Languages”  
   **When** я открываю выбор языка интерфейса  
   **Then** я могу выбрать “System default” или конкретный язык из поддерживаемых UI-локалей приложения (минимум `en`, `ru`).

5. **Given** секция “Audio”  
   **When** я включаю “Translation audio” или “Sanskrit audio”  
   **Then** если аудио не скачано, показывается подтверждение скачивания; при согласии начинается скачивание и показывается прогресс; во время скачивания переключатель недоступен (legacy iOS/Android).

6. **Given** секция “Audio”  
   **When** я выключаю “Translation audio” или “Sanskrit audio”  
   **Then** показывается подтверждение удаления; при согласии удаляются файлы и состояние обновляется.

7. **Given** секция “Audio”  
   **When** я включаю “Auto-play”  
   **Then** после окончания трека (перевод/санскрит в зависимости от выбранного режима) автоматически воспроизводится следующий (behavior как в legacy, даже если реализация аудио будет в другом флоу — здесь фиксируем настройку).

8. **Given** секция “Interpretations/Books”  
   **When** я выбираю языки контента  
   **Then** список книг/трактовок фильтруется по выбранным языкам и всегда включает “default book” (legacy iOS).

### Should Have

1. Состояния для аудио: “нет аудио для этого набора” → disabled toggle (legacy iOS `hasAudio`).
2. Отображение прогресса скачивания аудио/книг прямо в строке (progress indicator + текст “Loading…”).
3. Возможность удалить скачанную книгу свайпом (legacy iOS).
4. “About” секция: версия приложения, ссылки (опционально).

### Won't Have (This Iteration)

- Полная реализация аудиоплеера и background audio (это отдельный флоу/реализация; здесь только UX/модель настроек и интеграционные точки).
- Полная оффлайн-синхронизация с сервером и сложная миграция данных.
- Продвинутые настройки (темы, шрифты, размеры) — можно добавить позже.

## Constraints

- **Legacy parity**: UX и поведение должны повторять ключевые моменты legacy:
  - Android: `SettingsActivity` (переключатели + подтверждение download/delete + прогресс и polling)  
  - iOS: `SettingsViewController` (секции, multi-select languages, audio toggle + progress, books download)
- **Flutter baseline**: не ломать текущие reader toggles и их ключи (`reader_settings.*`).
- **Persistence**: настройки должны переживать перезапуск (`shared_preferences` + при необходимости Drift для сложных сущностей).
- **Localization**: UI должен быть готов к расширению локалей; начальный минимум — `en`/`ru`.
- **Performance**: Settings должен быть быстрым; загрузка списков языков/книг не должна блокировать UI.

## Open Questions

- [ ] Что считается “переводами глав”: только локализованные названия глав/оглавления, или ещё и переводы самих шлок (в legacy это связано с “books/interpretations”)?
- [ ] Должны ли “языки контента” быть **множественным выбором** (как legacy) или 1 активный язык + “сравнение” отдельно?
- [ ] Источник языков/книг в Flutter v1: только seed JSON, или подключаем legacy backend (`DataService.getLanguages/getBooks`) и кэшируем?
- [ ] Как синхронизировать “default book” в Flutter: один фиксированный (seed), или выбираемый в Settings?

## References

- Legacy Android Settings: `legacy/legacy_bhagavadgita.book_java/app/src/main/java/com/ethnoapp/bgita/screens/SettingsActivity.java`
- Legacy Android Languages: `legacy/legacy_bhagavadgita.book_java/app/src/main/java/com/ethnoapp/bgita/screens/LanguagesActivity.java`
- Legacy iOS Settings: `legacy/legacy_bhagavadgita.book_swift/Gita/ViewControllers/SettingsViewController.swift`
- Legacy iOS Language select: `legacy/legacy_bhagavadgita.book_swift/Gita/ViewControllers/SettingsLanguageViewController.swift`
- Legacy iOS localization keys: `legacy/legacy_bhagavadgita.book_swift/Gita/Resources/*/Localizable.strings`
- Legacy DB exports: `legacy/legacy_bhagavadgita.book_db/Books/db_languages.csv`, `db_books.csv`
- Current Flutter Settings baseline:
  - `app/bhagavadgita.book/lib/features/settings/settings_screen.dart`
  - `app/bhagavadgita.book/lib/features/settings/reader_settings.dart`

---

## Approval

- [ ] Reviewed by: Anton
- [ ] Approved on: [date]
- [ ] Notes: [any conditions or clarifications]
