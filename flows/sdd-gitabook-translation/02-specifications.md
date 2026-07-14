# Specifications: GitaBook Batch Translation Completion

> Version: 1.0
> Status: DRAFT
> Last Updated: 2026-03-31
> Requirements: 01-requirements.md

## Overview

Система допереводит недостающий контент для TH и ZH-CN, используя батчинг: один вызов `/translate.sanscrit` генерирует переводы на ОБА языка одновременно.

## Affected Systems

| System | Impact | Notes |
|--------|--------|-------|
| `/data/translated/ko/` | Create | Недостающие sloka, translit, vocabulary, comment |
| `/data/translated/th/` | Create | Недостающие vocabulary, comment |
| `/data/translated/zh-CN/` | Create | Недостающие sloka, vocabulary, comment |
| `/data/translated/zh-TW/` | Create | Недостающие vocabulary, comment |
| `/data/translated/el/` | Create | Недостающие sloka, translit, vocabulary, comment |
| `/data/translated/ka/` | Create | Недостающие sloka, translit, vocabulary, comment |
| `/data/translated/hy/` | Create | Недостающие sloka, translit, vocabulary, comment |
| `/data/translated/ja/` | Create | Недостающие sloka, translit, vocabulary, comment |
| `/data/translated/he/` | Create | Недостающие vocabulary, comment |
| `/data/translated/ar/` | Create | Недостающие vocabulary, comment |
| `/translate.sanscrit` skill | Use | Один вызов на шлоку, все недостающие языки |

## Architecture

### Processing Pipeline

```
┌─────────────────────────────────────────────────────────────┐
│  1. SCAN PHASE                                              │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐   │
│  │ List all    │────▶│ Compare     │────▶│ Build       │   │
│  │ Sanskrit    │     │ with TH/    │     │ missing     │   │
│  │ slokas      │     │ ZH-CN       │     │ items list  │   │
│  └─────────────┘     └─────────────┘     └─────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  2. BATCH PHASE (per sloka/vocabulary)                      │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐   │
│  │ Load        │────▶│ Prepare     │────▶│ Invoke      │   │
│  │ sources     │     │ batch       │     │ /translate  │   │
│  │ ru/en/de/es │     │ payload     │     │ .sanscrit   │   │
│  └─────────────┘     └─────────────┘     └─────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  3. SAVE PHASE                                              │
│  ┌─────────────┐     ┌─────────────┐                       │
│  │ Write TH    │     │ Write       │                       │
│  │ files       │     │ ZH-CN files │                       │
│  └─────────────┘     └─────────────┘                       │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

**Все 5 источников → один вызов → ВСЕ 10 целевых языков**

```
┌─────────────────────────────────────────────────────────────┐
│  ВХОДНЫЕ ДАННЫЕ (загружаются ВСЕ 5 одновременно)           │
│                                                             │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│  │ Sanskrit │ │ Russian  │ │ English  │ │ Deutsch  │       │
│  │ (sa)     │ │ (ru)     │ │ (en)     │ │ (de)     │       │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘       │
│       │            │            │            │              │
│       │            │     ┌──────────┐        │              │
│       │            │     │ Español  │        │              │
│       │            │     │ (es)     │        │              │
│       │            │     └────┬─────┘        │              │
│       └────────────┴──────────┴──────────────┘              │
│                         │                                   │
│                         ▼                                   │
│              ┌───────────────────┐                         │
│              │ /translate.sanscrit│                         │
│              │   (single call)   │                         │
│              └─────────┬─────────┘                         │
│                        │                                    │
│     ┌──────────────────┼──────────────────┐                │
│     ▼        ▼         ▼         ▼        ▼                │
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐                  │
│  │ ko  │ │ th  │ │zh-CN│ │zh-TW│ │ el  │                  │
│  └─────┘ └─────┘ └─────┘ └─────┘ └─────┘                  │
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐                  │
│  │ ka  │ │ hy  │ │ ja  │ │ he  │ │ ar  │                  │
│  └─────┘ └─────┘ └─────┘ └─────┘ └─────┘                  │
└─────────────────────────────────────────────────────────────┘
```

**10 целевых языков:**
| Код | Язык | Код | Язык |
|-----|------|-----|------|
| ko | 한국어 (Korean) | ka | ქართული (Georgian) |
| th | ไทย (Thai) | hy | Հայերdelays (Armenian) |
| zh-CN | 简体中文 (Simplified) | ja | 日本語 (Japanese) |
| zh-TW | 繁體中文 (Traditional) | he | עברית (Hebrew) |
| el | Ελληνικά (Greek) | ar | العربية (Arabic) |

## Processing Order

### Phase 1: Slokas (все недостающие переводы)

Для каждой шлоки из Sanskrit:
1. Проверить какие языки уже переведены
2. Определить недостающие языки
3. Если есть недостающие → один вызов `/translate.sanscrit` на ВСЕ недостающие языки
4. Сохранить результаты

```
for chapter in 01..18:
    for sloka in chapter:
        missing_langs = find_missing(sloka, ALL_TARGET_LANGS)
        if missing_langs:
            translations = translate(sloka, missing_langs)
            save(translations)
```

### Phase 2: Vocabulary (все недостающие)

Для каждой главы, для каждого языка без vocabulary.json:
- Перевести vocabulary со всех 5 источников

### Phase 3: Comments (все недостающие)

Только для шлок, где есть comment в original.

## Interfaces

### Input Detection

```python
def find_missing_slokas(lang: str) -> List[SlokaRef]:
    """
    Compare sanskrit/*.txt with translated/{lang}/*.txt
    Return list of missing sloka references
    """
    sanskrit_slokas = glob("data/sanskrit/chapter-*/*.txt")
    translated = glob(f"data/translated/{lang}/chapter-*/*_sloka.txt")

    # Extract sloka IDs and find missing
    return [s for s in sanskrit_slokas if not exists_translation(s, lang)]
```

### Batch Payload Structure

**ВАЖНО**: Все 5 источников (ru, en, de, es, sanskrit) загружаются и передаются агенту ОДНОВРЕМЕННО в каждом вызове.

```json
{
  "type": "sloka",
  "chapter": 7,
  "sloka_id": "7.15",
  "sources": {
    "sanskrit": "धृतराष्ट्र उवाच। धर्मक्षेत्रे कुरुक्षेत्रे...",
    "ru": "Дхритараштра сказал: О Санджая, что делали мои сыновья...",
    "en": "Dhritarashtra said: O Sanjaya, what did my sons...",
    "de": "Dhritarashtra sprach: O Sanjaya, was taten meine Söhne...",
    "es": "Dhritarashtra dijo: Oh Sanjaya, ¿qué hicieron mis hijos..."
  },
  "target_languages": ["ko", "th", "zh-CN", "zh-TW", "el", "ka", "hy", "ja", "he", "ar"],
  "output_types": ["sloka", "translit"]
}
```

### Output Structure

```json
{
  "translations": {
    "ko": { "sloka": "드리타라슈트라가 말했다...", "translit": "Dhṛtarāṣṭra uvāca..." },
    "th": { "sloka": "ธฤตราษฏระกล่าวว่า...", "translit": "Dhṛtarāṣṭra uvāca..." },
    "zh-CN": { "sloka": "持国王说...", "translit": "Dhṛtarāṣṭra uvāca..." },
    "zh-TW": { "sloka": "持國王說...", "translit": "Dhṛtarāṣṭra uvāca..." },
    "el": { "sloka": "Ο Ντριταράστρα είπε...", "translit": "Dhṛtarāṣṭra uvāca..." },
    "ka": { "sloka": "დჰრიტარაშტრამ თქვა...", "translit": "Dhṛtarāṣṭra uvāca..." },
    "hy": { "sloka": "Դdelays delays...", "translit": "Dhṛtarāṣṭra uvāca..." },
    "ja": { "sloka": "ドリタラーシュトラは言った...", "translit": "Dhṛtarāṣṭra uvāca..." },
    "he": { "sloka": "דריטראשטרה אמר...", "translit": "Dhṛtarāṣṭra uvāca..." },
    "ar": { "sloka": "قال دريتاراشترا...", "translit": "Dhṛtarāṣṭra uvāca..." }
  }
}
```

**Оптимизация**: В target_languages передаются только НЕДОСТАЮЩИЕ языки для данной шлоки. Если ko/th/zh-TW уже переведены, они не запрашиваются повторно.
```

## File Naming Convention

### Sloka/Translit

```
data/translated/{lang}/chapter-{NN}-{lang}/chapter-{NN}-{X.Y}-{lang}_sloka.txt
data/translated/{lang}/chapter-{NN}-{lang}/chapter-{NN}-{X.Y}-{lang}_translit.txt
```

Examples:
- `data/translated/zh-CN/chapter-07-zh-CN/chapter-07-7.15-zh-CN_sloka.txt`
- `data/translated/th/chapter-07-th/chapter-07-7.15-th_translit.txt`

### Vocabulary

```
data/translated/{lang}/chapter-{NN}-{lang}_vocabulary.json
```

Note: vocabulary файлы лежат в корне языковой папки, не в chapter-XX-lang/.

### Comment

```
data/translated/{lang}/chapter-{NN}-{lang}/chapter-{NN}-{X.Y}-{lang}_comment.txt
```

## Behavior Specifications

### Happy Path

1. Scan sanskrit directory for all slokas
2. For each sloka, check existence in th/ and zh-CN/
3. If missing in either:
   - Load all source texts (ru, en, de, es, sanskrit)
   - Call `/translate.sanscrit` with target_languages=["th", "zh-CN"]
   - Save outputs to respective directories
4. Update progress in TodoWrite
5. After each chapter, update meta.json if needed

### Edge Cases

| Case | Trigger | Expected Behavior |
|------|---------|-------------------|
| Missing source | ru/en/de/es file not found | Skip sloka, log warning |
| Partial translation | Some langs exist, others missing | Translate ONLY missing langs |
| All langs exist | Sloka fully translated | Skip, no API call |
| Combined slokas | `7.4-6` instead of `7.4` | Handle as single unit |
| Agent failure | Translation fails | Retry once, then skip and log |

### Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| Source not found | File missing | Log, skip, continue |
| Agent timeout | Translation takes too long | Retry with smaller batch |
| Invalid output | Malformed JSON | Log, skip, continue |

## Dependencies

### Requires

- All original source files exist (ru, en, de, es)
- Sanskrit files exist
- `/translate.sanscrit` skill is functional

### Blocks

- Nothing (standalone operation)

## Testing Strategy

### Verification Steps

1. After each sloka translation:
   - [ ] File created with correct name
   - [ ] Content is non-empty
   - [ ] UTF-8 encoding valid

2. After each chapter:
   - [ ] All slokas present
   - [ ] File count matches sanskrit

### Manual Verification

- [ ] Sample check: read 3 random translations per language
- [ ] Verify Sanskrit terms preserved
- [ ] Check proper script (Thai/Chinese characters)

## Rollback Strategy

If implementation fails:
1. Delete newly created files in `/data/translated/th/` and `/data/translated/zh-CN/`
2. No existing files are modified, so no data loss risk

## Open Design Questions

- [x] Batch size: one sloka per call (simpler) vs multiple slokas (more efficient)?
  → **Decision: one sloka per call** for reliability and progress tracking

- [ ] Should we update meta.json `totalSlokas` after translation?

---

## Approval

- [ ] Reviewed by: Anton
- [ ] Approved on:
- [ ] Notes:
