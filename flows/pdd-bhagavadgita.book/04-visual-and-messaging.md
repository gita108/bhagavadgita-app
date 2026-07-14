# Visual and messaging: Bhagavad Gita Book

> Version: 2.0 (Flutter design system)  
> Status: DRAFT  
> Last updated: 2026-05-04

## 1. Visual principles

- **Single design system**: `lib/ui/theme/app_theme.dart`, `app_colors.dart`, `app_text.dart` — one place for light/dark, spacing, verse styles.
- **Legacy as moodboard only**: Android red toolbar / iOS asset chrome informed early Flutter choices; **not** pixel-compatibility requirement across three codebases.
- **Typography**: Readable verse body first; support dynamic type; RU/EN via `lib/l10n/`.
- **Iconography**: Prefer Material symbols or bundled SVGs consistent across iOS/Android from same widget set.

## 2. Platform polish

- **Material 3** on Android and as default where appropriate.
- **Cupertino** touches on iOS where it improves feel (navigation patterns), without forking business logic.
- **Desktop / web**: density breakpoints, mouse/keyboard where applicable.

## 3. Messaging

- **Tone**: Calm, respectful; errors user-facing via l10n strings (replace hardcoded legacy `strings.xml` over time).
- **Onboarding**: Single copy set in ARB / gen-l10n, not duplicated per platform codebase.

## 4. Generative prompts (optional)

```
Flutter reading app UI for Bhagavad Gita, Material 3, deep red accents on toolbar and FABs,
warm paper-like reading background, large verse typography, chapter list with circular initials,
tablet master-detail, Russian + English labels, subtle motion, accessible contrast, light and dark theme.
```

## 5. Traceability

| UX rule (doc 03) | Flutter expression |
|------------------|-------------------|
| Reader focus | `sloka_screen` layout + theme verse styles |
| Bookmark clarity | Icon buttons consistent on reader + bookmarks list |

## Approvals

**Approval phrase to advance**: “visual and messaging approved”
