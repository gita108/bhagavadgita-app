# Requirements: bhagavadgita.book CI/CD (Windows build + portable)

> Version: 1.0  
> Status: DRAFT  
> Last Updated: 2026-04-30

## Problem Statement

Нужна воспроизводимая Windows‑сборка приложения в GitHub Actions, чтобы получать готовые артефакты для распространения и тестирования на Windows, включая **portable** версию.

## User Stories

### Primary

**As a** maintainer  
**I want** GitHub Actions workflow/job, который собирает Windows desktop релиз  
**So that** я могу скачивать готовую сборку после тега релиза или ручного запуска.

### Secondary

**As a** tester  
**I want** portable zip (без инсталлятора)  
**So that** я могу запускать приложение без установки и быстро проверять релизы.

## Acceptance Criteria

### Must Have

1. **Given** ручной запуск workflow (workflow_dispatch) или пуш тега `vX.Y.Z`  
   **When** выполняется Windows job  
   **Then** публикуются артефакты:
   - **Portable**: `.zip` с содержимым Windows release bundle (exe + dll + data).

2. **Given** workflow run завершился успешно  
   **When** я скачиваю portable zip и распаковываю  
   **Then** приложение запускается на Windows 10/11 без дополнительных шагов установки.

3. **Given** базовые проверки доступны  
   **When** выполняется job  
   **Then** выполняются `flutter pub get`, `flutter analyze`, `flutter test` (если тесты есть) до сборки.

### Should Have

- Кеширование Flutter/Dart зависимостей.
- Имена артефактов содержат ref (tag/branch) и/или sha.

### Won't Have (This Iteration)

- Подписанный инсталлятор (MSIX/EXE) и публикация в Microsoft Store.
- Автоматическая раздача обновлений.

## Constraints

- Repo layout: Flutter проект находится в `app/bhagavadgita.book/`.
- Windows runner: GitHub `windows-latest`.
- Portable должен быть самодостаточен (включая `data/` и нужные DLL рядом с `.exe`).

## Open Questions

- [ ] Нужен ли дополнительно “installer” артефакт (например MSIX) или достаточно portable на этом этапе?

---

## Approval

- [ ] Reviewed by: [name]
- [ ] Approved on: [date]
- [ ] Notes: [any conditions or clarifications]

