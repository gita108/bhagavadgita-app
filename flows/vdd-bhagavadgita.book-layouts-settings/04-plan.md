# Implementation Plan: Settings (Languages + Audio) — Bhagavad Gita Flutter

> Version: 1.1
> Status: DRAFT
> Last Updated: 2026-04-30
> Specifications: `03-specifications.md`

## Summary

Сделать Settings как в legacy (Android/iOS): секции, подэкраны выбора языков (контент vs UI), базовые аудио-переключатели с UX "confirm download/delete" и прогрессом, и блок "Interpretations/Books" (список книг по выбранным языкам) — с постепенной интеграцией с данными (seed → repository/cache).

---

## Current Status (Post-Sync)

| Phase | Status |
|-------|--------|
| Phase 0 | **PENDING** — critical fixes required |
| Phase 1 | Done (controllers created) |
| Phase 2 | **BROKEN** — settings_screen.dart + app_language_screen.dart не компилируются |
| Phase 3 | Placeholder only |
| Phase 4 | Pending |

---

## Task Breakdown

### Phase 0: Critical Fixes (NEW — код не компилируется)

#### Task 0.1: Fix `settings_screen.dart` — remove duplicate code
- **Description**: Удалить дублирующийся/сломанный код после строки 370
- **Files**: `settings_screen.dart`
- **Verification**: `flutter analyze lib/features/settings/settings_screen.dart` — no syntax errors
- **Complexity**: Low

#### Task 0.2: Fix `settings_screen.dart` — add missing import
- **Description**: Добавить `import '../../ui/theme/app_text.dart';`
- **Files**: `settings_screen.dart`
- **Verification**: `AppText` resolves
- **Complexity**: Low

#### Task 0.3: Fix `app_language_screen.dart` — replace RadioGroup
- **Description**: `RadioGroup<T>` не существует в Flutter; заменить на стандартные `RadioListTile` с `groupValue`/`onChanged`
- **Files**: `app_language_screen.dart`
- **Verification**: код компилируется; radio selection работает
- **Complexity**: Low

#### Task 0.4: Fix deprecated `activeColor`
- **Description**: Заменить `activeColor` → `activeThumbColor` в SwitchListTile (9 мест)
- **Files**: `settings_screen.dart`
- **Verification**: no deprecation warnings
- **Complexity**: Low

### Phase 1: Foundation (state + persistence) — DONE

#### Task 1.1: App language controller + app locale wiring — DONE
- **Status**: ✅ Implemented
- **Files**: `app_language_controller.dart`, `app.dart`

#### Task 1.2: Flutter localization bootstrap (en/ru) — DONE
- **Status**: ✅ Implemented
- **Files**: `l10n/app_en.arb`, `l10n/app_ru.arb`, `l10n/l10n.dart`

#### Task 1.3: Content languages controller (multi-select + guard) — DONE
- **Status**: ✅ Implemented
- **Files**: `content_languages_controller.dart`

#### Task 1.4: Audio settings controller (flags only) — DONE
- **Status**: ✅ Implemented
- **Files**: `audio_settings_controller.dart`

### Phase 2: Settings UI (screens + widgets) — PARTIAL (blocked by Phase 0)

#### Task 2.1: Refactor Settings screen into sections + reusable rows — BROKEN
- **Status**: ⚠️ Code exists but has syntax errors (see Phase 0)
- **Files**: `settings_screen.dart`
- **Remaining**: Fix Phase 0, then verify layout matches `02-visual.md`

#### Task 2.2: Content languages screen (multi-select) — DONE
- **Status**: ✅ Implemented
- **Files**: `content_languages_screen.dart`

#### Task 2.3: App language screen (radio list) — BROKEN
- **Status**: ⚠️ Uses non-existent `RadioGroup` (see Task 0.3)
- **Files**: `app_language_screen.dart`

#### Task 2.4: Audio toggle UX (confirm dialogs + progress placeholders) — PARTIAL
- **Status**: ⚠️ Dialogs work, but:
  - toggle NOT disabled while downloading (Logic Gap G1)
  - "Not available" state not implemented (Logic Gap G2)
- **Remaining**: Fix after Phase 0

### Phase 2.5: Logic Gaps (NEW — после Phase 0)

#### Task 2.5.1: Disable audio toggle while downloading
- **Description**: `onChanged` должен быть `null` когда `audioDownloadController.isBusy`
- **Files**: `settings_screen.dart`
- **Verification**: toggle greyed out во время скачивания
- **Complexity**: Low

#### Task 2.5.2: Audio "Not available" state
- **Description**: Если `hasAudioTranslation == false` или `hasAudioSanskrit == false`, toggle disabled + показать subtitle "Not available"
- **Files**: `settings_screen.dart`, возможно `audio_download_controller.dart`
- **Verification**: toggle недоступен для track без аудио
- **Complexity**: Medium

#### Task 2.5.3: Localize download button labels
- **Description**: Заменить hardcoded "Download RU (AudioVeda)" на l10n ключи
- **Files**: `settings_screen.dart`, `app_en.arb`, `app_ru.arb`
- **Verification**: кнопки показывают локализованный текст
- **Complexity**: Low

### Phase 3: Books/Interpretations section (data plumbing) — PLACEHOLDER

#### Task 3.1: Define books settings contract (UI model + controller)
- **Status**: ⏸️ Placeholder only — intentionally deferred
- **Description**: Создать `BooksSettingsController` и `BookSummary` модель
- **Complexity**: Medium

#### Task 3.2: Integrate with real data source (incremental)
- **Status**: ⏸️ Deferred
- **Description**: Подключить реальный репозиторий
- **Complexity**: High

### Phase 4: Testing & Polish — PENDING

#### Task 4.1: Unit + widget tests for controllers and key UX rules
- **Status**: ⏸️ Pending Phase 0 fix
- **Description**: Покрыть guard и locale override
- **Complexity**: Medium

#### Task 4.2: Localization audit
- **Status**: ⏸️ Pending
- **Description**: Проверить что все строки Settings локализованы
- **Complexity**: Low

## Dependency Graph (Updated)

```
Phase 0 (Critical Fixes)
   │
   ├─→ Task 0.1 (remove duplicate code)
   ├─→ Task 0.2 (add import AppText)
   ├─→ Task 0.3 (fix RadioGroup)
   └─→ Task 0.4 (deprecated activeColor)
         │
         ▼
Phase 2.5 (Logic Gaps)
   │
   ├─→ Task 2.5.1 (disable toggle while downloading)
   ├─→ Task 2.5.2 (not available state)
   └─→ Task 2.5.3 (l10n download buttons)
         │
         ▼
Phase 4 (Testing)
   │
   ├─→ Task 4.1 (tests)
   └─→ Task 4.2 (l10n audit)
```

**Note**: Phase 1 ✅ done, Phase 2 partially done, Phase 3 deferred.

## File Change Summary

| File | Action | Reason |
|------|--------|--------|
| `app/bhagavadgita.book/lib/features/settings/settings_screen.dart` | Modify | New Settings layout + sections + navigation |
| `app/bhagavadgita.book/lib/features/settings/app_language_*` | Create | UI locale override |
| `app/bhagavadgita.book/lib/features/settings/content_languages_*` | Create | Multi-select content language |
| `app/bhagavadgita.book/lib/features/settings/audio_settings_controller.dart` | Create | Audio prefs flags |
| `app/bhagavadgita.book/lib/l10n/*` | Create/Modify | UI localization (en/ru) |

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Locale override complexity | Med | Med | keep `system` fallback; validate supportedLocales |
| Data source mismatch (seed vs legacy backend) | Med | High | start with fixtures/seed; design repo abstraction |
| Audio downloads not ready | High | Med | stub progress state; integrate real download manager later |

## Rollback Strategy

1. Keep old `ReaderSettingsController` keys unchanged.
2. If new localization wiring breaks build, fallback to hardcoded strings temporarily (only during dev), then re-enable gen-l10n.
3. Feature-flag new Settings sections if needed (optional).

## Checkpoints

- [x] Phase 1: prefs controllers stable; no crashes on startup — DONE
- [ ] Phase 0: `flutter analyze lib/features/settings/` — 0 errors
- [ ] Phase 2: Settings UI matches `02-visual.md` (after Phase 0)
- [ ] Phase 2.5: Audio toggle disabled while downloading; "Not available" works
- [ ] Phase 3: books list shows correct filtering — DEFERRED
- [ ] Phase 4: tests green; strings localized

## Open Implementation Questions

- [ ] Where is the best place to host global controllers (DI vs globals), given current code uses a global `readerSettingsController`?
- [ ] Do we want M3 widgets or legacy-like styling (may affect switch visuals)?

---

## Approval

- [ ] Reviewed by: Anton
- [ ] Approved on: [date]
- [ ] Notes: [any conditions or clarifications]
