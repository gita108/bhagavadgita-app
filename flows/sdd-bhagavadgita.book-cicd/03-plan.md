# Implementation Plan: bhagavadgita.book CI/CD (GitHub Actions build)

> Version: 1.0  
> Status: DRAFT  
> Last Updated: 2026-04-29  
> Specifications: `flows/sdd-bhagavadgita.book-cicd/02-specifications.md`

## Summary

Сделать минимально‑надёжный CI для сборки Android `.apk` и iOS `.ipa` с артифактами, добавив безопасную схему подписи через GitHub Secrets и не ломая локальную разработку.

## Task Breakdown

### Phase 1: Flow scaffolding & repo index

#### Task 1.1: Add SDD flow files
- **Description**: Создать `flows/sdd-bhagavadgita.book-cicd/*` с REQ/SPEC/PLAN/IMPL log и `_status.md`
- **Files**:
  - `flows/sdd-bhagavadgita.book-cicd/*` - Create
- **Dependencies**: None
- **Verification**: файлы присутствуют, `_status.md` корректен
- **Complexity**: Low

#### Task 1.2: Update active flows index
- **Description**: Добавить новый SDD flow в `CLAUDE.md`
- **Files**:
  - `CLAUDE.md` - Modify
- **Dependencies**: Task 1.1
- **Verification**: таблица `Active Flows Summary` содержит новый flow
- **Complexity**: Low

### Phase 2: Android release signing + build

#### Task 2.1: Add release signing configuration with env fallback
- **Description**: Настроить `android/app/build.gradle.kts` на release signing через переменные окружения; fallback на debug, если secrets не заданы
- **Files**:
  - `app/bhagavadgita.book/android/app/build.gradle.kts` - Modify
- **Dependencies**: None
- **Verification**: `flutter build apk --release` работает локально; в CI при secrets создаётся signed APK
- **Complexity**: Medium

### Phase 3: GitHub Actions workflows

#### Task 3.1: Add Android build workflow job
- **Description**: Создать workflow с `build-android` job (ubuntu) + artifacts + cache
- **Files**:
  - `.github/workflows/build-artifacts.yml` - Create
- **Dependencies**: Task 2.1
- **Verification**: workflow валиден; job собирает `.apk` и публикует artifact
- **Complexity**: Medium

#### Task 3.2: Add iOS build workflow job
- **Description**: Добавить `build-ios` job (macos) с импортом `.p12`, установкой provisioning profile и сборкой `.ipa`
- **Files**:
  - `.github/workflows/build-artifacts.yml` - Modify
  - `app/bhagavadgita.book/ios/ExportOptions.plist` - Create (template)
- **Dependencies**: Task 3.1
- **Verification**: при корректных secrets workflow выдаёт `.ipa` artifact
- **Complexity**: High

### Phase 4: Verification & polish

#### Task 4.1: Validate YAML + run basic checks
- **Description**: Проверить, что workflow запускается (синтаксис), а команды Flutter корректны по путям
- **Files**:
  - `.github/workflows/build-artifacts.yml` - Modify (if needed)
- **Dependencies**: Phase 3
- **Verification**: `act`/local checks where possible; `flutter analyze` passes
- **Complexity**: Low

## File Change Summary

| File | Action | Reason |
|------|--------|--------|
| `flows/sdd-bhagavadgita.book-cicd/*` | Create | Документация и трассируемость изменений |
| `CLAUDE.md` | Modify | Индексация активных флоу |
| `app/bhagavadgita.book/android/app/build.gradle.kts` | Modify | Release signing из CI secrets |
| `.github/workflows/build-artifacts.yml` | Create | CI сборка `.apk` и `.ipa` |
| `app/bhagavadgita.book/ios/ExportOptions.plist` | Create | Экспорт `.ipa` через `flutter build ipa` |

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| iOS codesigning fragile | Medium | High | Fail-fast validation of secrets; explicit export options; keep logs |
| Android signing misconfig | Low | Medium | Fallback to debug when env vars missing; document required secrets |
| Long CI times | Medium | Low | Cache Flutter/Dart/Pods |

## Rollback Strategy

1. Удалить `.github/workflows/build-artifacts.yml`
2. Откатить изменения в `android/app/build.gradle.kts`
3. Оставить SDD docs (не мешают) или удалить flow directory при необходимости

## Open Implementation Questions

- [ ] Нужно ли собирать iOS также в `.xcarchive`/`.app` для отладки?

---

## Approval

- [ ] Reviewed by: [name]
- [ ] Approved on: [date]
- [ ] Notes: [any conditions or clarifications]
