# 01. Requirements

## Goal

Generate complete Bhagavat-gita books in **Chinese (zh-CN)**, **Thai (th)**, and **Hebrew (he)** from existing chapter data in `/chapters`, formatted as `.md` files with proper structure, glossary, and comments.

## Stakeholders

- **Project Owner**: User requesting the book generation
- **End Users**: Readers of Bhagavat-gita in Chinese, Thai, and Hebrew

## Requirements

### Functional

#### REQ-1: Source Data Processing
- **REQ-1.1**: Read chapter data from `/data/chapters/original/chapter-XX.json` (18 chapters)
- **REQ-1.2**: Read Asian translations from `/data/chapters/asian/chapter-XX-asian-translations.json`
- **REQ-1.3**: Read vocabulary data from `/data/chapters/ch-XX/vocabulary-source.json`

#### REQ-2: Language Support
- **REQ-2.1**: Generate Chinese (Simplified) version using `zh-CN` translations
- **REQ-2.2**: Generate Thai version using `th` translations
- **REQ-2.3**: Generate Hebrew version - **mark as "awaiting translation"** since no Hebrew data exists

#### REQ-3: Book Structure
- **REQ-3.1**: Each book must include:
  - Title page with chapter name in target language
  - Table of contents
  - All 18 chapters with slokas
  - Glossary/vocabulary section
  - Comments section for untranslated content

#### REQ-4: Markdown Format
- **REQ-4.1**: Use proper Markdown formatting:
  - `#` for chapter titles
  - `##` for sloka numbers
  - `###` for sections (Sanskrit, Translation, Vocabulary, Comments)
  - Code blocks for Sanskrit text
  - Blockquotes for translations
  - Tables for vocabulary

#### REQ-5: Untranslated Content Handling
- **REQ-5.1**: Mark missing translations with `> ⚠️ **Ожидает перевода** / Await translation`
- **REQ-5.2**: Include English reference for untranslated content
- **REQ-5.3**: Create summary of missing translations in comments section

### Non-Functional

#### REQ-6: Output Quality
- **REQ-6.1**: Maintain proper text direction (RTL for Hebrew)
- **REQ-6.2**: Preserve Sanskrit diacritics in transliteration
- **REQ-6.3**: UTF-8 encoding for all output files

#### REQ-7: File Organization
- **REQ-7.1**: Output directory structure:
  ```
  /data/chapters/generated/
  ├── chinese/
  │   ├── README.md
  │   ├── chapter-01.md
  │   ├── chapter-02.md
  │   │   ...
  │   ├── glossary.md
  │   └── comments.md
  ├── thai/
  │   └── ...
  └── hebrew/
      └── ...
  ```

## Constraints

- **Hebrew Translation**: No Hebrew data available in source - must be marked as awaiting translation
- **Korean/Japanese**: Some vocabulary has `ko`, `ja` fields but not requested for output
- **Approval Status**: Some translations marked `"approved": false` - include with note

## Acceptance Criteria

1. ✅ Three separate book directories created (chinese, thai, hebrew)
2. ✅ All 18 chapters generated for each language
3. ✅ Glossary compiled from vocabulary data
4. ✅ Comments section documents missing translations
5. ✅ Proper Markdown formatting throughout
6. ✅ Chinese and Thai use existing translations
7. ✅ Hebrew clearly marked as awaiting translation

---

**Status**: Draft  
**Created**: 2026-03-27  
**Approved**: Pending
