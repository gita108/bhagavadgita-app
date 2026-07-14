# Visual Mockups: Settings (Languages + Audio) — Bhagavad Gita Flutter

> Version: 1.0  
> Status: DRAFT  
> Last Updated: 2026-04-30

## Overview

ASCII-макеты и UX-флоу для Settings в `app/bhagavadgita.book`, основанные на legacy:

- Android: `SettingsActivity` (switches + download/delete confirmation + progress)
- iOS: `SettingsViewController` (sections + languages multi-select + audio + interpretations/books)

---

## Screen: Settings

Главный экран настроек: секции, строки, состояния “disabled” и прогресс внутри строки.

```
+--------------------------------------------------+
|  = Settings                                       |
+--------------------------------------------------+
|  LANGUAGES                                        |
|  [ Content languages ]     English, Русский   >   |
|  [ App language ]          System default     >   |
|  ------------------------------------------------ |
|  DISPLAY                                          |
|  Show Sanskrit                             [ON]   |
|  Show transliteration                      [ON]   |
|  Show translation                           [ON]  |
|  Show comments                              [ON]  |
|  Show vocabulary                            [ON]  |
|  ------------------------------------------------ |
|  AUDIO                                            |
|  Translation audio                        [OFF]   |
|    (if downloading)           Loading…    (25%)   |
|    (if no audio)              Not available  [-]  |
|  Sanskrit audio                           [OFF]   |
|    (if downloading)           Loading…    (..)    |
|  Auto-play next                          [OFF]    |
|  ------------------------------------------------ |
|  INTERPRETATIONS / BOOKS                          |
|  Hidden Treasure (EN)                 [✓]     >   |
|  Bhagavad Gita (RU)                   [↓]     >   |
|  Visvanath... (EN)                    [↓]     >   |
|  (downloading) “Loading…”            (34%)        |
|  (downloaded) swipe left → [Delete]               |
|  ------------------------------------------------ |
|  ABOUT (optional)                                 |
|  Version                                  1.0.0   |
+--------------------------------------------------+
```

### Notes

- “Content languages” — множественный выбор (legacy iOS/Android).
- “App language” — UI locale override: `System default` + конкретные локали.
- Audio toggles:
  - если `hasAudio == false` → toggle disabled (legacy iOS)
  - если включили и нужно скачать → confirmation → progress → toggle disabled пока качается
  - выключили → confirmation delete
- Books/Interpretations:
  - список фильтруется по выбранным языкам контента
  - “default book” всегда виден и не удаляется (legacy iOS)

---

## Screen: Content Languages (multi-select)

Выбор языков контента/переводов (переводы глав/шлок + доступные книги/трактовки).

```
+--------------------------------------------------+
|  <  Choose content languages                      |
+--------------------------------------------------+
|  English                                   [✓]    |
|  Русский                                   [✓]    |
|  Deutsch                                   [ ]    |
|  Español                                   [ ]    |
+--------------------------------------------------+
|  * At least one language must remain selected     |
+--------------------------------------------------+
```

### Rules

- Нельзя снять “последний” выбранный язык (legacy: нельзя deselect defaultLanguageId).
- При изменении выбора:
  - обновляется summary на Settings (“English, Русский”)
  - обновляется фильтр списка книг/трактовок на Settings

### State: Last language selected (blocked)

```
+--------------------------------------------------+
|  ! Can't deselect                                 |
+--------------------------------------------------+
|  You must keep at least one content language.     |
|  [OK]                                             |
+--------------------------------------------------+
```

(Legacy key: `Settings.Language.SingleLanguage`.)

---

## Screen: App Language (UI locale)

Выбор языка интерфейса приложения (override системного).

```
+--------------------------------------------------+
|  <  App language                                  |
+--------------------------------------------------+
|  System default                            (O)    |
|  English                                   ( )    |
|  Русский                                   ( )    |
+--------------------------------------------------+
```

### Notes

- По умолчанию: `System default`.
- При выборе конкретного языка: UI перерисовывается на выбранной локали.
- Этот выбор **не** влияет на языки контента (они отдельно).

---

## Component: SettingRow (navigates)

Используется для “Content languages” и “App language”.

```
+----------------------------------------------+
|  Title                          Summary   >  |
+----------------------------------------------+
```

---

## Component: ToggleRow (with optional progress / disabled)

Используется для Display + Audio.

```
+----------------------------------------------+
|  Title                                  [ON] |
|  (optional subtitle)   Loading… (34%)        |
+----------------------------------------------+
```

States:
- Enabled ON/OFF
- Disabled (Not available)
- Disabled while downloading (shows progress)

---

## Flow: Change Content Languages

```
[Settings] --tap Content languages--> [Content Languages]
    ^                |
    |---back---------|
```

Step-by-step:
1. User opens Content Languages
2. Toggles one or more languages
3. Back → Settings refreshes:
   - Content languages summary
   - Books list filtered

---

## Flow: Enable Audio Download

```
[Settings] --toggle Translation audio ON--> [Confirm download]
    |                                         |
    |<---Cancel-------------------------------|
    |
    +--> (OK) start download → row shows progress, switch disabled
```

---

## Flow: Delete Audio

```
[Settings] --toggle Sanskrit audio OFF--> [Confirm delete]
    |                                      |
    |<---Cancel----------------------------|
    |
    +--> (Yes) delete files → switch OFF
```

---

## Notes (Design + Accessibility)

- Заголовки секций uppercase с letterSpacing (как текущий Flutter Settings делает `DISPLAY`).
- Переключатели с красным accent (`red1`) как в legacy.
- Тап-зоны: строки выбора языков должны быть полноценными “ListTile” (не мелкие иконки).
- Для прогресса: текст “Loading…” + процент; для VoiceOver/ TalkBack прогресс должен быть доступен как semantic value.

---

## Approval

- [ ] Reviewed by: Anton
- [ ] Approved on: [date]
- [ ] Notes: [any conditions or clarifications]
