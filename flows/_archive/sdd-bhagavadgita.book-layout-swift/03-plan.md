# Implementation Plan: bhagavadgita.book-layout-swift

> Version: 1.0  
> Status: DRAFT  
> Last Updated: 2026-04-29  
> Specifications: `02-specifications.md`

## Summary

Сначала делаем инвентаризацию legacy UI и ассетов и фиксируем target-структуру Flutter UI. Затем переносим ассеты и вводим дизайн-токены/адаптивный слой. После — по одному переносим экраны, начиная с тех, что критичны для UX чтения (chapters/shloka/bookmarks), и доводим до отсутствия overflow на основных брейкпоинтах.

## Task Breakdown

### Phase 1: Inventory & Foundations

#### Task 1.1: Inventory legacy Swift UI + mapping
- **Description**: Выписать legacy экраны/вьюхи/ячейки + их ассеты, сопоставить с Flutter структурами.
- **Files**:
  - `flows/sdd-bhagavadgita.book-layout-swift/artifacts/ui-inventory.md` - Create
- **Dependencies**: None
- **Verification**: список экранов/компонентов и используемых ассетов покрывает legacy target scope.
- **Complexity**: Medium

#### Task 1.2: Assets migration into Flutter assets/
- **Description**: Перенести картинки/иконки/сплэш в `assets/` и подключить в `pubspec.yaml`.
- **Files**:
  - `app/bhagavadgita.book/assets/**` - Create/Modify
  - `app/bhagavadgita.book/pubspec.yaml` - Modify
- **Dependencies**: Task 1.1
- **Verification**: `flutter run` отображает ассеты на тестовом экране/в местах использования.
- **Complexity**: Medium

#### Task 1.3: Introduce theme tokens + adaptive helpers
- **Description**: Добавить слой токенов (colors/textStyles/spacing) и брейкпоинты/хелперы.
- **Files**:
  - `app/bhagavadgita.book/lib/**` - Modify/Create (конкретизировать после инвентаризации)
- **Dependencies**: Task 1.1
- **Verification**: базовый экран использует токены и корректно реагирует на ширину.
- **Complexity**: Medium

### Phase 2: Screens migration (core)

#### Task 2.1: Chapters/Books list layout
- **Description**: Перенести верстку списка (ячейки/пустые состояния/иконки).
- **Dependencies**: Phase 1
- **Verification**: работает на phone + tablet, нет overflow.
- **Complexity**: Medium

#### Task 2.2: Shloka reader layout
- **Description**: Перенести UI чтения (заголовок, текст, перевод/комментарии, кнопки).
- **Dependencies**: Phase 1
- **Verification**: читабельно при wide + при textScaleFactor>1.3.
- **Complexity**: High

#### Task 2.3: Bookmarks layout
- **Description**: Перенести экран закладок и empty-state из legacy.
- **Dependencies**: Phase 1
- **Verification**: пусто/список корректно на разных размерах.
- **Complexity**: Medium

### Phase 3: Secondary screens

#### Task 3.1: Search layout
#### Task 3.2: Quote layout
#### Task 3.3: Settings layout

### Phase 4: Testing & Polish

#### Task 4.1: Widget/manual verification pass
- **Description**: Проверка брейкпоинтов, больших шрифтов, основных сценариев.
- **Verification**: нет RenderFlex overflow, UI стабильный.
- **Complexity**: Medium

## Dependency Graph

```
Task 1.1 ─→ Task 1.2 ─┬─→ (Screens)
          └→ Task 1.3 ┘
```

## File Change Summary

| File | Action | Reason |
|------|--------|--------|
| `flows/sdd-bhagavadgita.book-layout-swift/artifacts/ui-inventory.md` | Create | трассировка legacy→Flutter |
| `app/bhagavadgita.book/assets/**` | Create/Modify | перенос ассетов |
| `app/bhagavadgita.book/pubspec.yaml` | Modify | подключение ассетов/шрифтов |
| `app/bhagavadgita.book/lib/**` | Modify/Create | адаптив + UI |

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Legacy UI зависит от iOS-специфичных паттернов | Med | Med | адаптировать в Flutter-эквиваленты, не копировать напрямую |
| Текстовые переполнения при больших шрифтах | High | High | проверить `textScaleFactor`, использовать гибкие лэйауты, скролл |
| Ассеты без корректных размеров/вариантов | Med | Med | нормализовать размеры, добавить variants, прогнать на разных DPI |

## Rollback Strategy

1. Откатить UI-изменения коммитом.
2. Ассеты оставлять только если реально используются; иначе удалить при откате.

## Open Implementation Questions

- [ ] Где лучше разместить breakpoints/tokens в текущей структуре проекта (после анализа `lib/`)?

---

## Approval

- [ ] Reviewed by: Anton
- [ ] Approved on: 2026-04-29
- [ ] Notes: -
