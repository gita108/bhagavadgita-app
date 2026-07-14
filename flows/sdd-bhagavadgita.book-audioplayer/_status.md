# Status: sdd-vdd-bhagavadgita.book-audioplayer

## Current Phase

PLAN

## Phase Status

DRAFTED

## Last Updated

2026-04-30 by Claude Opus 4.5

## Blockers

- Нет (ожидание подтверждения плана).

## Progress

- [x] Requirements drafted
- [x] Requirements approved
- [x] Specifications drafted
- [x] Specifications approved
- [x] Plan drafted  ← current
- [ ] Plan approved
- [ ] Implementation started
- [ ] Implementation complete
- [ ] Documentation drafted
- [ ] Documentation approved

## Context Notes

Key decisions and context for resuming:

- В репозитории найдены два legacy‑референса аудио:
  - iOS Swift: `legacy/legacy_bhagavadgita.book_swift/` (`AVPlayer` + таймер прогресса/окончания, UI `ShlokaPlayerView`, настройки скачивания аудио санскрит/перевод + autoplay)
  - Android Java: `legacy/legacy_bhagavadgita.book_java/` (`MediaPlayer` + audio focus, скачивание аудио через `DownloadManager` и `AudioState`)
- Остальные указанные референсы пока отсутствуют в этом репозитории.
- Требования включают UX для phone/tablet/desktop и вариант desktop tray.
- В проекте есть предустановленные mp3 для Chapter 1:
  - `chapter_1_ru.mp3` (~10 MB)
  - `chapter_1_sanskrit.mp3` (~25 MB)
- Главы 2-18 скачиваются онлайн через AudioVeda API (credentials в `.env`).

## References

- Legacy iOS audio: `legacy/legacy_bhagavadgita.book_swift/Gita/Libraries/SoundManager/SoundManager.swift`, `.../Views/ShlokaPlayerView.swift`
- Legacy Android audio: `legacy/legacy_bhagavadgita.book_java/app/.../utils/SoundManager.java`, `.../model/audio/*`
- Current Flutter audio:
  - `app/bhagavadgita.book/lib/app/audio/audio_controller.dart`
  - `app/bhagavadgita.book/lib/app/audio/audio_download_controller.dart`
  - `app/bhagavadgita.book/lib/app/audio/audioveda_client.dart`
- **Предустановленные файлы (offline bootstrap)**:
  - `assets/audio/ru/chapter_1_ru.mp3` (~10 MB)
  - `assets/audio/sanskrit/chapter_1_sanskrit.mp3` (~25 MB)
- **Конфигурация** (`.env`):
  - `AUDIOVEDA_RUSSIAN_URL`, `AUDIOVEDA_SANSKRIT_URL` — endpoints для глав 2-18
  - `AUDIOVEDA_USERNAME`, `AUDIOVEDA_PASSWORD` — credentials

## Next Actions

1. Получить доступ/пути к референсам: `avadhuta`, `legacy-cookbook-swift`, `legacy-gitanjali-swift`, `legacy-sgg-ru-v1-swift`
2. После обновления требований — перейти к `02-specifications.md` (только после явного approval requirements)

