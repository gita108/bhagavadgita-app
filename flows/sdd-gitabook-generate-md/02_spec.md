# 02. Specification

## Overview

This specification defines the technical design for generating Bhagavat-gita books in Traditional Chinese (zh-TW) and Thai from existing JSON source data.

> **Note**: Hebrew generation is deferred until Phase 3 of `sdd-gitabook-translations-combined` is complete.

## Data Sources

### Source Files

| Source | Path Pattern | Content |
|--------|--------------|---------|
| Chapter Source | `/data/chapters/ch-{01-18}/chapter-source.json` | Sanskrit slokas, transliteration, translations (ru, en, de, es) |
| Asian Translations | `/data/chapters/ch-{01-18}/chapter-asian.json` | Asian translations (th, zh-TW, ko, ja) |
| Vocabulary | `/data/chapters/ch-{01-18}/vocabulary-source.json` | Word-by-word meanings (en approved, others pending) |

### Data Structure

**Chapter Asian JSON** (`ch-XX/chapter-asian.json`):
```json
{
  "chapter": 1,
  "title": {
    "th": "การสังเกตกองทัพ",
    "zh-TW": "觀軍",
    "ko": "군대 관망",
    "ja": "..."
  },
  "slokas": {
    "1.1": {
      "th": {"text": "...", "approved": false},
      "zh-TW": {"text": "...", "approved": false}
    }
  }
}
```

**Chapter Source JSON** (`ch-XX/chapter-source.json`):
```json
{
  "chapter": 1,
  "title": {
    "sanskrit": "...",
    "transliteration": "...",
    "ru": {"text": "...", "approved": true},
    "en": {"text": "...", "approved": true}
  },
  "slokas": [
    {
      "number": "1.1",
      "sanskrit": "धृतराष्ट्र उवाच...",
      "transliteration": "...",
      "translations": {
        "ru": {"text": "...", "approved": true},
        "en": {"text": "...", "approved": true}
      },
      "vocabulary": [...]
    }
  ]
}
```

## Output Specification

### Directory Structure

```
/generated/
├── th/
│   ├── README.md           # ภควัทคีตา - สารบัญ
│   ├── chapter-01.md       # บทที่ 1: การสังเกตกองทัพ
│   ├── chapter-02.md
│   │   ...
│   ├── chapter-18.md
│   ├── glossary.md         # ศัพท์บัญญัติ
│   └── comments.md         # หมายเหตุ
└── zh-TW/
    ├── README.md           # 《博伽梵歌》- 目錄
    ├── chapter-01.md       # 第一章：觀軍
    ├── chapter-02.md
    │   ...
    ├── chapter-18.md
    ├── glossary.md         # 詞彙表
    └── comments.md         # 註釋
```

### Markdown Template

**Chapter File Template**:
```markdown
# {Chapter Title in Target Language}

> {Total slokas} verses

---

## {Sloka Number}

### Sanskrit
{sanskrit text}

### Transliteration
{transliteration}

### Translation
> {translation text}

### Vocabulary
| Word | Transliteration | Meaning |
|------|-----------------|---------|
| ... | ... | ... |

---
```

**README Template**:
```markdown
# {Book Title}

## Table of Contents

1. [{Chapter 1 Title}](chapter-01.md)
2. [{Chapter 2 Title}](chapter-02.md)
...
18. [{Chapter 18 Title}](chapter-18.md)

- [Glossary](glossary.md)
- [Notes](comments.md)
```

## Language-Specific Details

### Thai (th)
- **Title**: ภควัทคีตา
- **Chapter format**: บทที่ {N}: {title}
- **Verse format**: โศลก {number}
- **Glossary**: ศัพท์บัญญัติ
- **Comments**: หมายเหตุ
- **Font direction**: LTR

### Traditional Chinese (zh-TW)
- **Title**: 《博伽梵歌》
- **Chapter format**: 第{N}章：{title}
- **Verse format**: 詩節 {number}
- **Glossary**: 詞彙表
- **Comments**: 註釋
- **Font direction**: LTR

## Translation Status Matrix

| Language | Chapter Titles | Slokas | Status |
|----------|---------------|--------|--------|
| th | ✅ All 18 | ✅ All 18 | **Ready** |
| zh-TW | ✅ All 18 | ✅ All 18 | **Ready** |
| he | ❌ Missing | ❌ Missing | Deferred |

## Processing Rules

### Rule 1: Translation Priority
1. Use `approved: true` translations when available
2. Fall back to `approved: false` if no approved version
3. Mark as "awaiting translation" if completely missing

### Rule 2: Untranslated Content
For any missing translation:
```markdown
> ⚠️ **Awaiting translation**
>
> **English reference**: {english text}
```

### Rule 3: Vocabulary
- Include vocabulary table for each sloka
- Use English meaning as fallback if target language unavailable

## Quality Checks

- [x] All 18 chapters present for Thai
- [x] All 18 chapters present for zh-TW
- [ ] Chapter titles match source data
- [ ] Sloka numbers sequential and complete
- [ ] Sanskrit text preserved without modification
- [ ] Glossary alphabetically organized

---

**Status**: Approved
**Updated**: 2026-03-27
**Changes**: zh-CN → zh-TW, Hebrew deferred
