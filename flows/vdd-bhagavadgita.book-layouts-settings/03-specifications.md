# Specifications: Settings (Languages + Audio) — Bhagavad Gita Flutter

> Version: 1.1
> Status: DRAFT
> Last Updated: 2026-04-30
> Requirements: `01-requirements.md`
> Visual: `02-visual.md`

---

## Implementation Status (Post-Sync)

### Implemented Files

| File | Status | Notes |
|------|--------|-------|
| `settings_screen.dart` | **BROKEN** | Код не компилируется — см. Known Issues |
| `app_language_controller.dart` | OK | Persistence + effectiveLocale работает |
| `app_language_screen.dart` | **BROKEN** | `RadioGroup` не существует в Flutter |
| `content_languages_controller.dart` | OK | Multi-select + "at least one" logic |
| `content_languages_screen.dart` | OK | CheckboxListTile + validation dialog |
| `audio_settings_controller.dart` | OK | Persistence flags |
| `app.dart` | OK | `locale = settings.effectiveLocale` подключен |
| `l10n/app_en.arb`, `app_ru.arb` | OK | Все ключи Settings присутствуют |

### Known Issues (Critical)

| # | Файл | Строки | Проблема |
|---|------|--------|----------|
| C1 | `settings_screen.dart` | 371+ | Дублирующийся/сломанный код после класса `_SectionHeader` |
| C2 | `settings_screen.dart` | all | Отсутствует `import '../../ui/theme/app_text.dart';` |
| C3 | `app_language_screen.dart` | 18 | `RadioGroup<T>` — не существует; заменить на стандартные `RadioListTile` |

### Known Issues (Warnings)

| # | Файл | Проблема |
|---|------|----------|
| W1 | `settings_screen.dart` | `activeColor` deprecated → `activeThumbColor` (9 мест) |

### Logic Gaps (Spec vs Code)

| # | Spec требует | Текущее состояние | Fix |
|---|--------------|-------------------|-----|
| G1 | Audio toggle **disabled while downloading** | Toggle остаётся enabled | Добавить `enabled: !audioDownloadController.isBusy` |
| G2 | Audio "Not available" если `hasAudio == false` | Не проверяется | Добавить `hasAudioTranslation`/`hasAudioSanskrit` в `AudioDownloadController` или отдельный provider |
| G3 | Download buttons l10n | Hardcoded "Download RU (AudioVeda)" | Добавить ключи в arb |
| G4 | Books/Interpretations real data | Placeholder list | Intentional — отдельный flow |

---

## Overview

Спецификация описывает, как реализовать Settings для `app/bhagavadgita.book` с тремя “осями”:

1) **Reader display toggles** (уже есть) — показывать/скрывать блоки в `SlokaScreen`  
2) **Languages**:
   - **Content languages** — выбор переводов/книг (множественный)  
   - **App language** — язык интерфейса (UI locale override)  
3) **Audio settings**:
   - Translation audio / Sanskrit audio: enable + download/delete + progress + “not available”
   - Auto-play next

Цель: повторить поведение legacy Settings (Android/iOS), но интегрировать в существующую архитектуру Flutter приложения.

## Affected Systems

| System | Impact | Notes |
|--------|--------|------|
| `app/bhagavadgita.book/lib/features/settings/settings_screen.dart` | Modify | Перестроить UI под секции + language rows + audio + books |
| `app/bhagavadgita.book/lib/features/settings/reader_settings.dart` | Modify (small) | Сохранить обратную совместимость ключей; возможно расширить |
| `app/bhagavadgita.book/lib/features/reader/sloka_screen.dart` | Modify | Использовать новые настройки при показе/воспроизведении |
| `app/bhagavadgita.book/lib/app/app.dart` (или аналог) | Modify | Добавить локализацию Flutter + app-locale override |
| `app/bhagavadgita.book/lib/features/settings/*` | Create | `app_language_controller.dart`, `content_languages_controller.dart`, models |
| `app/bhagavadgita.book/lib/features/settings/widgets/*` | Create | Reusable `SettingsSectionHeader`, `SettingRow`, `ToggleRow` |
| `app/bhagavadgita.book/lib/features/settings/content_languages_screen.dart` | Create | Multi-select languages |
| `app/bhagavadgita.book/lib/features/settings/app_language_screen.dart` | Create | UI locale selection |
| `app/bhagavadgita.book/lib/features/settings/books_settings/*` | Create/Modify | Books list row + download state glue (stub if backend not ready) |
| `app/bhagavadgita.book/lib/features/audio/*` | Integrate later | Здесь лишь интерфейсы/контракт под аудио |

## Architecture

### Component Diagram (high level)

```
SettingsScreen
  ├─ ReaderSettingsController (existing; shared_preferences)
  ├─ ContentLanguagesController (new; shared_preferences + optional Drift)
  ├─ AppLanguageController (new; shared_preferences)
  ├─ AudioSettingsController (new; shared_preferences)
  └─ BooksSettingsController (new; depends on repository + download manager)

MaterialApp
  └─ locale = AppLanguageController.effectiveLocale (null = system)
```

### Data Flow

```
UI interaction (toggle/select)
  └─> Controller.update(...)
       ├─ updates ValueNotifier state
       └─ persists to SharedPreferences

SlokaScreen
  ├─ observes ReaderSettingsController → show/hide sections
  └─ observes AudioSettingsController → choose track + autoplay behavior

SettingsScreen
  ├─ observes ContentLanguagesController → languages summary + books filter
  └─ observes BooksSettingsController → download/progress states
```

## Data Models

### 1) Reader Settings (existing)

`ReaderSettingsController` already persists with prefix `reader_settings.`:

- `reader_settings.showSanskrit`
- `reader_settings.showTransliteration`
- `reader_settings.showTranslation`
- `reader_settings.showComment`
- `reader_settings.showVocabulary`

**Compatibility rule**: keys and defaults MUST NOT change.

### 2) Content Languages

Legacy source-of-truth examples:
- `legacy/legacy_bhagavadgita.book_db/Books/db_languages.csv` (id/name/code)
- In legacy apps: selected languages stored locally (DB in iOS; model list in Android)

Proposed Flutter preference keys:

- `content_languages.selectedCodes` = `List<String>` (e.g. `["en","ru"]`)
- `content_languages.defaultCode` (optional; derived from default book or seed)

Rules:
- Multi-select.
- Enforce at least 1 language selected.
- If a “default language” is defined, it MUST remain selected (legacy behavior).

### 3) App Language (UI locale override)

Preference keys:

- `app_language.mode` = enum `system | explicit`
- `app_language.code` = `String?` when explicit (e.g. `en`, `ru`)

Rules:
- Default: `system`.
- When explicit:
  - `MaterialApp.locale = Locale(code)`
  - `supportedLocales` must include it

### 4) Audio Settings (flags only in this scope)

Legacy mapping:
- Android `AppSettings`: `audioTranslate`, `audioSanskrit`, `playAuto`
- iOS `Settings`: `useTranslationAudio`, `useSanskritAudio`, `autoPlayAudio`

Proposed keys:

- `audio.useTranslation` (bool, default true to match iOS legacy; confirm later)
- `audio.useSanskrit` (bool, default false)
- `audio.autoPlayNext` (bool, default false)

Download progress/state keys (optional; if download manager persists elsewhere, keep in separate storage):

- `audio.translation.downloadState` = `none|downloading|downloaded|error`
- `audio.sanskrit.downloadState` = `none|downloading|downloaded|error`
- `audio.*.progress` = 0..1 (optional, if we want resume UI)

**Important**: actual download orchestration is out-of-scope here, but Settings must be designed to display progress and lock toggles while downloading.

### 5) Books / Interpretations Settings (minimal contract)

Legacy:
- Android: books list in Settings, depends on selected languages; merge books + local statuses
- iOS: list of `Book` filtered by selected languages; download/delete; swipe-to-delete
- Legacy DB export: `legacy/.../db_books.csv` includes book name + initials + languageId

Flutter contract (repository-driven):

- `BookSummary { id, languageCode, title, initials, hasAudioTranslation, hasAudioSanskrit, downloadState, progress }`
- `BooksRepository.watchBooks(...)` → stream/listenable
- `BooksDownloadManager.downloadBook(bookId)` / `deleteBook(bookId)`

UI rules:
- defaultBook всегда в списке и не удаляется
- row states: download button (↓), progress (..%), downloaded (✓), swipe delete (if allowed)

## Behavior Specifications

### Happy Path

1) User opens Settings.
2) User changes Display toggles → `ReaderSettingsController.update(...)` → `SlokaScreen` reacts.
3) User opens Content languages:
   - toggles languages
   - leaves screen → `SettingsScreen` updates summary + books filter.
4) User opens App language:
   - selects `System default` or explicit locale
   - app UI updates immediately.
5) User enables Translation audio:
   - if not downloaded → confirm → start download → show progress → lock toggle while downloading.

### Edge Cases

| Case | Trigger | Expected Behavior |
|------|---------|-------------------|
| Last language deselect attempt | user taps to uncheck last remaining language | block and show message (legacy: `Settings.Language.SingleLanguage`) |
| UI locale not supported | persisted code not in `supportedLocales` | fallback to system locale; reset to system mode |
| No audio for selected default book | `hasAudio==false` | disable corresponding toggle; show “Not available” hint |
| Download failure | download manager reports error | show “Cannot download…” message; toggle returns to OFF; keep retry possible |

### Error Handling

| Error | Cause | Response |
|-------|------|----------|
| languages/books load error | repository/network failed | show cached data if any; else show error row + retry |
| preferences read/write error | rare platform failure | keep in-memory state; show snack “Couldn’t save settings” |

## Dependencies

### Requires

- `shared_preferences` (already present)
- Flutter localization tooling:
  - `flutter_localizations` SDK
  - `intl` (may be required by generated l10n)

### Optional / Future

- Audio playback stack (separate flow): `just_audio`, `audio_service`
- Downloads: `dio` + background isolate/service, or platform download manager wrappers

## Integration Points

### Internal Systems

- `ReaderSettingsController` is already used in `SlokaScreen` via `ValueListenableBuilder`.
- Books/languages data source is currently seed JSON only; spec allows future switch to repository + cache.

### External Systems (legacy backend)

Legacy has endpoints (`DataService.getLanguages/getBooks`). If reused:
- define `LanguagesRepository` and `BooksRepository`
- cache locally (Drift) and hydrate UI from cache first

## Testing Strategy

### Unit Tests

- [ ] `AppLanguageController` persists mode/code; unsupported locale fallback works
- [ ] `ContentLanguagesController` enforces “at least one selected”

### Widget Tests

- [ ] Settings shows section headers and correct summary values
- [ ] Content Languages screen blocks deselect last language
- [ ] App Language screen toggles selection and triggers locale rebuild

### Manual Verification

- [ ] Change Display toggles → Sloka screen updates immediately
- [ ] Change App language → Settings UI text updates without restart
- [ ] Toggle audio ON (not downloaded) → confirm dialog appears; shows progress state (can be stubbed)

## Migration / Rollout

- No schema migrations required for the Settings UI itself.
- Preference keys should be namespaced (`reader_settings.*`, `content_languages.*`, `app_language.*`, `audio.*`) to avoid collisions.

## Open Design Questions

- [ ] Default values for audio flags: iOS legacy sets Translation audio default ON; Android seems user-driven — confirm expected default in Flutter v1.
- [ ] Content languages vs "default book": do we allow choosing default book in Settings now, or keep fixed to seed?
- [ ] What is the exact mapping "переводы глав" in current seed JSON and DB schema (where chapter titles are stored per language)?

---

## Implementation Fixes Required

Порядок исправлений (Critical → Warnings → Gaps):

### Phase 1: Critical (код не компилируется)

1. **C2** — `settings_screen.dart`: добавить `import '../../ui/theme/app_text.dart';`
2. **C1** — `settings_screen.dart`: удалить дублирующийся код после строки 370
3. **C3** — `app_language_screen.dart`: заменить `RadioGroup` на стандартный паттерн:
   ```dart
   ListView(
     children: [
       RadioListTile<String?>(
         title: Text(...),
         value: null,
         groupValue: selected,
         onChanged: (v) => ...,
       ),
       for (final locale in AppLanguageController.supported)
         RadioListTile<String?>(
           title: Text(_labelFor(context, locale.languageCode)),
           value: locale.languageCode,
           groupValue: selected,
           onChanged: (v) => ...,
         ),
     ],
   )
   ```

### Phase 2: Warnings (deprecated API)

4. **W1** — `settings_screen.dart`: заменить `activeColor` → `activeThumbColor` (9 мест)

### Phase 3: Logic Gaps

5. **G1** — Audio toggle disabled while downloading:
   ```dart
   SwitchListTile(
     ...
     onChanged: audioDownloadController.isBusy ? null : (v) async { ... },
   )
   ```

6. **G2** — Audio "Not available":
   - Добавить `hasAudioTranslation` / `hasAudioSanskrit` getter в `AudioDownloadController` (или отдельный provider на основе seed/repository)
   - В UI: если `!hasAudio` → toggle disabled + subtitle "Not available"

7. **G3** — l10n для download buttons:
   - Добавить ключи `downloadAudioTranslation`, `downloadAudioSanskrit`, `downloadingEllipsis` в arb
   - Заменить hardcoded strings

### Phase 4: Polish (optional)

8. Вынести `_SectionHeader` в `lib/features/settings/widgets/section_header.dart`
9. Вынести confirm dialogs в reusable helper

---

## Approval

- [ ] Reviewed by: Anton
- [ ] Approved on: [date]
- [ ] Notes: [any conditions or clarifications]
