# 03. Plan

## Implementation Steps

### Step 1: Create Python Generation Script
**File**: `/scripts/generate_gitabook_md.py`

**Responsibilities**:
- Load JSON source data from all chapters
- Process translations for each target language
- Generate Markdown files with proper formatting
- Handle missing translations gracefully
- Create glossary from vocabulary data
- Generate comments/notes files

**Dependencies**:
- Python 3.8+
- Standard library only (json, os, pathlib)

### Step 2: Generate Chinese Version
**Output**: `/data/chapters/generated/chinese/`

**Tasks**:
1. Create directory structure
2. Generate README.md with table of contents
3. Generate 18 chapter files (chapter-01.md through chapter-18.md)
4. Compile glossary from all vocabulary
5. Create comments file noting any unapproved translations

### Step 3: Generate Thai Version
**Output**: `/data/chapters/generated/thai/`

**Tasks**:
1. Create directory structure
2. Generate README.md with table of contents (Thai)
3. Generate 18 chapter files
4. Compile glossary (ศัพท์บัญญัติ)
5. Create comments file (หมายเหตุ)

### Step 4: Generate Hebrew Version
**Output**: `/data/chapters/generated/hebrew/`

**Tasks**:
1. Create directory structure
2. Generate README.md with RTL support notice
3. Generate 18 chapter files with English references
4. Mark all content as "⚠️ Ожидает перевода / Await translation"
5. Create comprehensive translation needed list

### Step 5: Verification
**Checklist**:
- [ ] All directories created
- [ ] All 18 chapters per language (54 total chapter files)
- [ ] 3 README files (one per language)
- [ ] 3 glossary files
- [ ] 3 comments files
- [ ] No JSON parsing errors
- [ ] Proper UTF-8 encoding
- [ ] Hebrew RTL markers present

## Timeline

| Step | Duration | Dependencies |
|------|----------|--------------|
| Step 1: Script | 1 hour | None |
| Step 2: Chinese | 10 min | Step 1 |
| Step 3: Thai | 10 min | Step 1 |
| Step 4: Hebrew | 10 min | Step 1 |
| Step 5: Verify | 15 min | Steps 2-4 |

**Total**: ~2 hours

## File Checklist

### Scripts
- [ ] `/scripts/generate_gitabook_md.py`

### Output - Chinese
- [ ] `/data/chapters/generated/chinese/README.md`
- [ ] `/data/chapters/generated/chinese/chapter-01.md` through `chapter-18.md`
- [ ] `/data/chapters/generated/chinese/glossary.md`
- [ ] `/data/chapters/generated/chinese/comments.md`

### Output - Thai
- [ ] `/data/chapters/generated/thai/README.md`
- [ ] `/data/chapters/generated/thai/chapter-01.md` through `chapter-18.md`
- [ ] `/data/chapters/generated/thai/glossary.md`
- [ ] `/data/chapters/generated/thai/comments.md`

### Output - Hebrew
- [ ] `/data/chapters/generated/hebrew/README.md`
- [ ] `/data/chapters/generated/hebrew/chapter-01.md` through `chapter-18.md`
- [ ] `/data/chapters/generated/hebrew/glossary.md`
- [ ] `/data/chapters/generated/hebrew/comments.md`

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Missing source data | Mark as "awaiting translation", include English reference |
| Encoding issues | Explicit UTF-8 encoding in script |
| Hebrew RTL rendering | Include HTML dir="rtl" markers |
| Large vocabulary | Aggregate and deduplicate across chapters |

---

**Status**: Ready for implementation  
**Created**: 2026-03-27  
**Approved**: Pending
