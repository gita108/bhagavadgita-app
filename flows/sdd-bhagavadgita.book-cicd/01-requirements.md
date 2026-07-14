# Requirements: bhagavadgita.book CI/CD (GitHub Actions build)

> Version: 1.0  
> Status: DRAFT  
> Last Updated: 2026-04-29

## Problem Statement

Сейчас в репозитории нет CI, который гарантированно собирает релизные артефакты приложения. Нужны воспроизводимые сборки в GitHub Actions для Android (`.apk`) и iOS (`.ipa`) с сохранением артефактов, чтобы ускорить релизы и сократить “works on my machine”.

## User Stories

### Primary

**As a** maintainer  
**I want** GitHub Actions workflow, который собирает Android `.apk` и iOS `.ipa`  
**So that** я могу получать готовые артефакты на каждый релиз/ручной запуск и быстро выкатывать в сторах.

### Secondary

**As a** reviewer  
**I want** чтобы workflow выполнял базовые проверки (pub get, analyze, tests при наличии)  
**So that** сборка ломалась раньше, чем уйдёт в релиз.

## Acceptance Criteria

### Must Have

1. **Given** репозиторий на GitHub  
   **When** я запускаю workflow вручную (workflow_dispatch)  
   **Then** получаю артефакты сборки:
   - Android: `.apk` (release)
   - iOS: `.ipa` (release, подписанный)

2. **Given** пуш тега релиза (например `v1.2.3`)  
   **When** запускается workflow  
   **Then** собираются те же артефакты и доступны для скачивания из run artifacts.

3. **Given** что secrets для подписи не настроены  
   **When** workflow запускается  
   **Then** Android job может собрать unsigned/debug (или fail с понятным сообщением), а iOS job должен fail с понятным сообщением о недостающих secrets.

### Should Have

- Кеширование Flutter/Dart/Pods для ускорения прогонов.
- Публикация артефактов с читаемыми именами, включающими ref/commit.

### Won't Have (This Iteration)

- Автозагрузка в Google Play / App Store Connect (Fastlane deliver / upload_to_play_store).
- Автоматическая генерация/обновление сертификатов и профилей.
- Сборка `.aab` (можно добавить отдельным расширением).

## Constraints

- **Repo layout**: Flutter проект находится в `app/bhagavadgita.book/`.
- **iOS**: сборка `.ipa` требует macOS runner и codesigning (Apple cert + provisioning profile).
- **Android**: релизная подпись требует keystore; локальная сборка должна продолжать работать без secrets.

## Open Questions

- [ ] Каким методом подписываем iOS `.ipa`: `app-store` (для TestFlight/App Store) или `ad-hoc` (для ручной установки)?
- [ ] Нужен ли отдельный workflow для PR (без подписи) или достаточно manual/tag?

## References

- Flutter CI docs (GitHub Actions): `https://docs.flutter.dev/deployment/cd`

---

## Approval

- [ ] Reviewed by: [name]
- [ ] Approved on: [date]
- [ ] Notes: [any conditions or clarifications]
