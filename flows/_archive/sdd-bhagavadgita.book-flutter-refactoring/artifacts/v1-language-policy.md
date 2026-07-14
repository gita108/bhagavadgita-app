# V1 Language Policy (full vs partial)

> Generated from: `artifacts/content-matrix.*`  
> Last Updated: 2026-04-28  
> Scope: `data/` + fallback sources (`bak/`, `legacy_bhagavadgitabook_db`)

## Goals

- Определить, какие языки **показываем пользователю** в v1 как “полноценные” (full) и какие считаем “частичными” (partial).
- Определить поведение UI для partial: скрывать, показывать с предупреждением, или показывать только некоторые блоки (например, translit без sloka).
- Согласовать это с offline-first: seed snapshot должен быть пригоден для чтения без сети.

## Definitions

- **Full (v1)**: для всех 18 глав есть минимум `meta + sloka + translit` в `data/`.
  - Vocabulary/comments считаются опциональными для статуса “full” (они отображаются, если есть).
- **Seed-ok**: для всех 18 глав есть `meta` и хотя бы один из `sloka|translit`.
  - В UI такие языки могут быть доступны только в режиме “partial”.
- **Partial**: иная ситуация (рваное покрытие глав или отсутствует `meta` на части глав, или нет `sloka` на значимой части).

## Policy (v1)

### Show as Full (default visible)

По текущей матрице `data/`:
- `ru`, `en`, `de`, `es`
- `ko`, `th`, `zh-TW`
- `ar`, `he`

UI правила:
- Отображать язык в списке языков без предупреждений.
- В reader блоки `comment` и `vocabulary` показывать только если присутствуют.

### Show as Partial (visible with warning)

По текущей матрице `data/`:
- `sanskrit` (нет translit/vocabulary/comments в `data/` — ожидаемо)
- `zh-CN` (частично без `sloka`, есть `translit+meta`)
- `el`, `ka`, `hy` (есть `translit+meta`, но нет `sloka`)

UI правила:
- В списке языков помечать как **Partial**.
- В reader:
  - если `sloka` отсутствует, показывать доступные блоки (например, translit) + сообщение “текст перевода не полностью доступен”.
  - если `meta` есть, навигация по главам доступна.

### Hide in v1 (not selectable) until fixed

По текущей матрице `data/`:
- `ja` (рваное покрытие, отсутствует `meta` по главам и неполная структура)

UI правила:
- Не показывать язык в селекторе v1.
- Разрешить включение только через dev-flag (если понадобится для проверки).

### Not present in content tree (do not show)

В `data/meta/languages.json` перечислены, но в фактическом `data/` отсутствуют:
- `tr`, `sw`

UI правила:
- Не показывать в v1, пока не появится фактический контент в `data/translated/`.

## Backfill Strategy (future)

- `bak/chapters/original/chapter-XX.json` использовать как secondary источник для:
  - добора `audio refs`,
  - добора недостающих `sloka`/`vocabulary` там, где это возможно и корректно.
- `legacy/legacy_bhagavadgitabook_db` использовать как tertiary для:
  - сверки RU-среза и audio refs,
  - quotes.

## Follow-ups to add into plan (recommended)

- Автоматический “coverage gate” перед сборкой seed snapshot:
  - fail build, если в “full” языках пропал `sloka/translit/meta` по любой главе.
  - warn build, если в full языках резко изменилось количество `comment/vocabulary`.
