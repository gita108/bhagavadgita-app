# Implementation Plan: GitaBook Batch Translation Completion

> Version: 1.0
> Status: DRAFT
> Last Updated: 2026-03-31
> Specifications: 02-specifications.md

## Summary

Последовательная обработка шлок по главам. Для каждой шлоки: определить недостающие языки → вызвать `/translate.sanscrit` → сохранить результаты.

## Constants

```
SOURCE_LANGS = ["sa", "ru", "en", "de", "es"]
TARGET_LANGS = ["ko", "th", "zh-CN", "zh-TW", "el", "ka", "hy", "ja", "he", "ar"]
CHAPTERS = 01..18
```

## Task Breakdown

### Phase 1: Slokas Translation

#### Task 1.1: Scan & Build Missing List

- **Description**: Для каждой главы построить список шлок с недостающими языками
- **Method**:
  ```
  for each sanskrit_file in data/sanskrit/chapter-{NN}-sanskrit/:
      sloka_id = extract_id(file)  # e.g., "1.1", "7.4-6"
      missing = []
      for lang in TARGET_LANGS:
          if not exists(data/translated/{lang}/chapter-{NN}-{lang}/chapter-{NN}-{sloka_id}-{lang}_sloka.txt):
              missing.append(lang)
      if missing:
          add_to_queue(chapter, sloka_id, missing)
  ```
- **Output**: Queue of (chapter, sloka_id, missing_langs[])
- **Complexity**: Low

#### Task 1.2: Process Each Sloka

For each item in queue:

- **Description**: Перевести одну шлоку на все недостающие языки
- **Steps**:
  1. Load source files:
     - `data/sanskrit/chapter-{NN}-sanskrit/chapter-{NN}-{sloka_id}-sanskrit_sloka.txt`
     - `data/original/ru/chapter-{NN}-ru/chapter-{NN}-{sloka_id}-ru_sloka.txt`
     - `data/original/en/chapter-{NN}-en/chapter-{NN}-{sloka_id}-en_sloka.txt`
     - `data/original/de/chapter-{NN}-de/chapter-{NN}-{sloka_id}-de_sloka.txt`
     - `data/original/es/chapter-{NN}-es/chapter-{NN}-{sloka_id}-es_sloka.txt`
  2. Call `/translate.sanscrit` with all sources and missing_langs
  3. Save outputs:
     - `data/translated/{lang}/chapter-{NN}-{lang}/chapter-{NN}-{sloka_id}-{lang}_sloka.txt`
     - `data/translated/{lang}/chapter-{NN}-{lang}/chapter-{NN}-{sloka_id}-{lang}_translit.txt`
- **Verification**: Files created, non-empty, valid UTF-8
- **Complexity**: Medium (per sloka)

### Phase 2: Vocabulary Translation

#### Task 2.1: Scan Missing Vocabulary

- **Description**: Определить какие vocabulary.json отсутствуют
- **Method**:
  ```
  for chapter in 01..18:
      for lang in TARGET_LANGS:
          if not exists(data/translated/{lang}/chapter-{NN}-{lang}_vocabulary.json):
              add_to_vocab_queue(chapter, lang)
  ```
- **Complexity**: Low

#### Task 2.2: Process Each Vocabulary

- **Description**: Перевести vocabulary для одной главы на недостающие языки
- **Steps**:
  1. Load source vocabularies (ru, en, de, es)
  2. Call `/translate.sanscrit` for vocabulary type
  3. Save `data/translated/{lang}/chapter-{NN}-{lang}_vocabulary.json`
- **Complexity**: Medium

### Phase 3: Comments Translation

#### Task 3.1: Scan Existing Comments

- **Description**: Найти все comment файлы в original
- **Method**: `find data/original -name "*_comment.txt"`
- **Complexity**: Low

#### Task 3.2: Process Each Comment

- **Description**: Перевести comment на недостающие языки
- **Steps**: Similar to sloka processing
- **Complexity**: Medium

## Execution Strategy

### Sequential by Chapter (Priority: TH, ZH-CN first)

```
Chapter 01:
  - Scan slokas → find missing langs for each
  - For each sloka with missing:
      - /translate.sanscrit → save all missing langs
  - Scan vocabulary → translate if missing
  - Scan comments → translate if missing
  - Update progress

Chapter 02:
  ... (repeat)

...

Chapter 18:
  ... (repeat)
```

### Progress Tracking

После каждой шлоки:
- Update TodoWrite с прогрессом
- Log: `Chapter {NN}: {sloka_id} → translated {n} langs`

После каждой главы:
- Summary: `Chapter {NN} complete: {total_slokas} slokas, {total_files} files created`

## File Operations Summary

| Operation | Count (estimated) |
|-----------|-------------------|
| Sloka files to create | ~3000-4000 |
| Translit files to create | ~3000-4000 |
| Vocabulary files to create | ~150 |
| Comment files to create | ~200 |
| Total new files | ~6000-8000 |

## Dependency Graph

```
Task 1.1 (Scan slokas)
    │
    ▼
Task 1.2 (Process slokas) ──────────────────┐
    │                                        │
    ▼                                        │
Task 2.1 (Scan vocabulary)                   │
    │                                        │
    ▼                                        │
Task 2.2 (Process vocabulary)                │
    │                                        │
    ▼                                        │
Task 3.1 (Scan comments)                     │
    │                                        │
    ▼                                        │
Task 3.2 (Process comments) ◄────────────────┘
    │
    ▼
  DONE
```

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Agent timeout | Medium | Low | Retry once, then skip |
| Missing source file | Low | Low | Log warning, continue |
| Rate limiting | Low | Medium | Add delay between calls |
| Context overflow | Low | High | Process one sloka at a time |

## Checkpoints

After each chapter:
- [ ] All slokas processed
- [ ] Missing files created
- [ ] No errors logged
- [ ] Progress updated

## Implementation Command

Для запуска:
```
Process chapter by chapter, sloka by sloka:
1. Read sanskrit sloka
2. Check which target langs are missing
3. If any missing: invoke /translate.sanscrit with all 5 sources
4. Save outputs to respective directories
5. Continue to next sloka
```

---

## Approval

- [ ] Reviewed by: Anton
- [ ] Approved on:
- [ ] Notes:
