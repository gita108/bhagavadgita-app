# Specifications: bhagavadgita.book-layout-swift

> Version: 1.0  
> Status: DRAFT  
> Last Updated: 2026-04-29  
> Requirements: `01-requirements.md`

## Overview

Перенос UI-вёрстки и ассетов из legacy Swift (`legacy/legacy_bhagavadgita.book_swift/Gita`) в Flutter-приложение (`app/bhagavadgita.book`) будет выполнен через:

- выделение дизайн-токенов (цвета/типографика/spacing) и общих Flutter-виджетов (карточки/ячейки/кнопки/пустые состояния),
- реализацию экранов в Flutter с адаптивными брейкпоинтами,
- перенос графики из `Assets.xcassets` в Flutter-ассеты (с вариантами плотности),
- проверку на типовых размерах экранов и при увеличенном textScaleFactor.

## Affected Systems

| System | Impact | Notes |
|--------|--------|------|
| `app/bhagavadgita.book/lib/` | Modify | UI-слой: новые виджеты/экраны/токены |
| `app/bhagavadgita.book/assets/` | Create/Modify | перенос изображений/иконок из legacy |
| `app/bhagavadgita.book/pubspec.yaml` | Modify | декларация ассетов/шрифтов |
| `legacy/legacy_bhagavadgita.book_swift/Gita/` | Reference-only | источник макетов/ассетов/структуры UI |

## Architecture

### Component Diagram

```
Flutter App
 ├─ app/theme (tokens, ThemeData)
 ├─ ui/widgets (reusable components)
 ├─ ui/screens (pages)
 └─ ui/adaptive (breakpoints, responsive layout helpers)
```

### Data Flow

```
Repositories / Data sources
     ↓
ViewModel / Controller (если уже есть в проекте)
     ↓
Screen widgets → reusable widgets → render + adaptive decisions
```

## UI Scope (initial)

Перечень экранов уточняется по фактическому наличию/структуре legacy и текущего Flutter UI. Ожидаемые кандидаты по legacy:

- Chapters / Books list
- Shloka (reader)
- Bookmarks
- Search
- Quote
- Settings
- Guide / onboarding (если используется)

## Assets Migration

### Source

Legacy ассеты берём из:

- `legacy/legacy_bhagavadgita.book_swift/Gita/Assets.xcassets/*`
- `legacy/legacy_bhagavadgita.book_swift/Gita/Resources/Fonts/*` (если применимо)
- storyboard launch screen / splash графика (как источник изображений)

### Target

В Flutter:

- `app/bhagavadgita.book/assets/images/...`
- `app/bhagavadgita.book/assets/icons/...`
- `pubspec.yaml` содержит пути до ассетов.

Правила:

- Иконки по возможности переводим в SVG только если уже есть зависимость и это оправдано; иначе оставляем PNG и используем resolution-aware variants.
- Для ассетов с `@2x/@3x` делаем структуру Flutter вариантов (`image.png`, `2.0x/image.png`, `3.0x/image.png`) или используем текущую практику проекта (если уже есть).

## Adaptive Layout Strategy

### Breakpoints

Принцип:

- **compact**: phone portrait
- **medium**: phone landscape / small tablet
- **expanded**: tablet/desktop/web wide

### Layout Rules

- Ограничение ширины текста на wide экранах (например, maxWidth для читательских экранов).
- Использование двухколоночной компоновки там, где полезно (например, список + детали) — при наличии навигационной архитектуры в проекте.
- Без overflow/RenderFlex overflow на типовых брейкпоинтах.

### Accessibility

- Проверка при повышенном `textScaleFactor` (как минимум 1.3–1.6).
- Тап-таргеты не меньше рекомендованных размеров Material.

## Legacy Style Tokens (to port)

Из `legacy/legacy_bhagavadgita.book_swift/Gita/Resources/Style.swift`:

### Colors

- `red1`: \(#FF5252\) (primary accent, nav bar / highlights)
- `red2`: \(#FB9A6A\)
- `gray1`: \(#4A4A4A\) (primary text)
- `gray2`: \(#9B9B9B\) (secondary text)
- `gray3`: \(#C7C7CC\)
- `gray4`: \(#E8E8E8\)
- `gray5`: \(#F9F9F9\) (surfaces like player background)

### Typography

- PT Sans (Regular/Bold/Italic/BoldItalic) — основной UI шрифт
- Kohinoor Devanagari (Regular/Light/Semibold) — для санскрита (legacy использует Semibold 18)

### Reader layout rules (legacy-derived)

- Заголовок шлоки: номер крупно, title по центру, кнопки previous/next (иконки `left`/`right`) по краям.
- Sanskrit/Translation/… — центрированные блоки с предсказуемыми боковыми отступами (например 58 для санскрита, 16–56 для других блоков).
- Переводы: разделитель `divider_language` с короткой меткой языка по центру (красным).
- Аудиоплеер: нижняя панель высоты 57 + safe area, с прогресс-линией 2px (red1) и кнопкой play/pause.

## Testing Strategy

### Automated

- Widget tests для ключевых адаптивных решений (брейкпоинты, maxWidth, отсутствие overflow при больших шрифтах) — по минимуму, если в проекте уже есть тестовая инфраструктура.

### Manual Verification

- Запуск на iPhone-size, iPad-size, web/desktop window resizing.
- Проверка ключевых экранов и состояний (empty/loading/error).

## Open Design Questions

- [ ] Токены: использовать существующий `ThemeData` проекта или ввести новый слой токенов?
- [ ] Навигация на tablet/desktop: нужен ли split-view (master/detail) или достаточно center-column?

---

## Approval

- [ ] Reviewed by: Anton
- [ ] Approved on: 2026-04-29
- [ ] Notes: -
