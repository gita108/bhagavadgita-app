# Requirements: GitaBook Folder Structure

> Version: 1.1
> Status: APPROVED
> Last Updated: 2026-03-29

## Problem Statement

Текущая структура папок в проекте GitaBook неоптимальна:
- Оригинальные тексты и переводы смешаны в одних JSON-файлах
- Сложно работать с переводами отдельных языков
- Нет чёткого разделения между исходными текстами и машинными переводами
- Сложно добавлять новые языки и управлять статусом переводов
- Транслитерация санскрита не адаптирована под нативные письменности

Нужна новая структура, где:
- Оригинальные тексты (ru, en, de, es + санскрит) хранятся отдельно
- Каждый перевод - в своём файле
- Каждая шлока - отдельный файл (.txt)
- Транслитерация - отдельный файл для каждого языка в нативной письменности

## Current Structure Analysis

### Текущие папки:
```
data/
├── chapters/
│   ├── original/           # JSON со всеми переводами в одном файле
│   │   └── chapter-XX.json
│   ├── ch-XX/              # Разбивка по главам
│   │   ├── chapter-source.json
│   │   ├── chapter-asian.json
│   │   ├── chapter-other.json
│   │   ├── vocabulary-source.json
│   │   ├── vocabulary-asian.json
│   │   └── vocabulary-other.json
│   └── generated/          # Сгенерированные MD файлы
│       └── {lang}/
│           └── chapter-XX.md
├── vocabulary/
│   └── original/
│       └── vocab_XX.json
├── translations/           # Промпты для перевода
│   └── chapter-XX-prompt.txt
├── meta/
│   └── languages.json
└── schema/
    ├── chapter.schema.json
    └── vocabulary.schema.json
```

### Языки

**Оригиналы (source: "original")**:
- ru (русский) - кириллица
- en (английский) - латиница
- de (немецкий) - латиница
- es (испанский) - латиница

**Машинные переводы**:
- ko (корейский) - хангыль
- th (тайский) - тайское письмо
- zh-CN (китайский упрощённый) - ханьцзы
- zh-TW (китайский традиционный) - ханьцзы
- el (греческий) - греческое письмо
- ka (грузинский) - грузинское письмо (мхедрули)
- hy (армянский) - армянское письмо
- he (иврит) - ивритское письмо
- ar (арабский) - арабское письмо
- tr (турецкий) - латиница
- sw (суахили) - латиница

### Транслитерация санскрита по языкам

| Группа | Языки | Транслитерация |
|--------|-------|----------------|
| Кириллица | ru | дхр̣тара̄ш̣т̣ра ува̄ча |
| Латиница (IAST) | en, de, es, tr, sw | dhṛtarāṣṭra uvāca |
| Хангыль | ko | 드리타라슈트라 우바차 |
| Тайское | th | ธฤตราษฏระ อุวาจ |
| Ханьцзы (упр.) | zh-CN | 德里塔拉施特拉·乌瓦查 |
| Ханьцзы (трад.) | zh-TW | 德里塔拉施特拉·烏瓦查 |
| Греческое | el | Δριταράστρα Ουβάτσα |
| Грузинское | ka | დჰრიტარაშტრა უვაჩა |
| Армянское | hy | Դdelays Դհdelays |
| Ивритское | he | דהריטראשטרה אובאצ'ה |
| Арабское | ar | دهريتاراشترا أوفاتشا |

## User Stories

### Primary

**As a** переводчик
**I want** иметь каждый перевод в отдельном файле
**So that** я могу работать над конкретным языком независимо

**As a** разработчик
**I want** иметь чёткое разделение оригиналов и переводов
**So that** я понимаю, какие данные являются первоисточником

**As a** контент-менеджер
**I want** простой формат для глав (текстовый, а не JSON)
**So that** легко редактировать содержимое без технических знаний

### Secondary

**As a** система сборки
**I want** предсказуемую структуру папок
**So that** я могу автоматически генерировать книги для разных языков

## Acceptance Criteria

### Must Have

1. **Given** структура папок
   **When** добавляю новый язык перевода
   **Then** это требует только создания нового файла/папки без изменения существующих

2. **Given** оригинальные тексты (ru, en, de, es)
   **When** просматриваю структуру
   **Then** они чётко отделены от машинных переводов в папке `original/`

3. **Given** машинные переводы
   **When** просматриваю структуру
   **Then** они находятся в папке `translated/` с подпапками по языкам

4. **Given** глава перевода
   **When** хочу её отредактировать
   **Then** она находится в отдельном текстовом файле (md/txt)

### Should Have

- Версионирование и метаданные для каждого файла
- Совместимость с GitBook для публикации
- Лёгкая миграция из текущей структуры

### Won't Have (This Iteration)

- Автоматическая конвертация из текущей структуры (отдельная задача)
- Веб-интерфейс для редактирования
- CI/CD пайплайн для сборки

## Constraints

- **Technical**: Структура должна работать с GitBook
- **Format**: Простые данные в текстовом формате (MD), сложные в JSON
- **Naming**: Единообразное именование файлов для всех языков

## Resolved Questions

- [x] Формат файлов: **plain text (.txt)** - без форматирования
- [x] Структура: **Language-First** (по языкам, затем по главам)
- [x] Шлоки: **отдельный файл на каждую шлоку** (1.1_sloka.txt, 1.2_sloka.txt, 1.4-6_sloka.txt)
- [x] Транслитерация: **отдельный файл** (1.1_translit.txt) для каждой шлоки
- [x] Комментарии: **отдельный файл рядом** (1.1_comment.txt) если есть
- [x] Транслитерация: **нативная письменность** для каждого языка
- [x] Санскрит: **на верхнем уровне** `sanskrit/` (первоисточник, не перевод)
- [x] Именование файлов: **chapter-{N}-{sloka}-{lang}_{type}.txt** (chapter-01-1.1-ru_sloka.txt)
- [x] Именование папок: **chapter-{N}-{lang}/** (chapter-01-ru/)
- [x] Vocabulary: **только в original/** языках (`_vocabulary.json` в папке главы)
- [x] Vocabulary: **перевод слов с санскрита** (содержит sanskrit + word + meaning)
- [x] Vocabulary для translated: **генерируется конкатенацией** смыслов из original

## Open Questions

- [ ] Нужен ли файл audio-ссылок или оставить в _meta.json?

## Final Structure

```
data/
├── sanskrit/                               # Первоисточник (деванагари)
│   └── chapter-01-sanskrit/
│       ├── chapter-01-1.1-sanskrit_sloka.txt
│       ├── chapter-01-1.2-sanskrit_sloka.txt
│       ├── chapter-01-1.4-6-sanskrit_sloka.txt
│       └── chapter-01-sanskrit_meta.json
│
├── original/                               # Оригинальные переводы с санскрита
│   │
│   ├── ru/
│   │   └── chapter-01-ru/
│   │       ├── chapter-01-1.1-ru_sloka.txt
│   │       ├── chapter-01-1.1-ru_translit.txt
│   │       ├── chapter-01-1.1-ru_comment.txt     # (если есть)
│   │       ├── chapter-01-ru_meta.json
│   │       └── chapter-01-ru_vocabulary.json
│   │
│   ├── en/
│   │   └── chapter-01-en/
│   │       ├── chapter-01-1.1-en_sloka.txt
│   │       ├── chapter-01-1.1-en_translit.txt    # IAST
│   │       ├── chapter-01-1.1-en_comment.txt
│   │       ├── chapter-01-en_meta.json
│   │       └── chapter-01-en_vocabulary.json
│   │
│   ├── de/
│   │   └── chapter-01-de/...
│   │
│   └── es/
│       └── chapter-01-es/...
│
├── translated/                             # Машинные переводы (переводы переводов)
│   │                                       # Vocabulary генерируется конкатенацией
│   │                                       # смыслов из original
│   │
│   ├── ko/
│   │   └── chapter-01-ko/
│   │       ├── chapter-01-1.1-ko_sloka.txt
│   │       ├── chapter-01-1.1-ko_translit.txt    # хангыль
│   │       ├── chapter-01-1.1-ko_comment.txt     # (если есть)
│   │       └── chapter-01-ko_meta.json
│   │
│   ├── th/
│   │   └── chapter-01-th/...
│   │
│   ├── zh-CN/
│   │   └── chapter-01-zh-CN/...
│   │
│   ├── zh-TW/
│   │   └── chapter-01-zh-TW/...
│   │
│   ├── el/
│   │   └── chapter-01-el/...
│   │
│   ├── ka/
│   │   └── chapter-01-ka/...
│   │
│   ├── hy/
│   │   └── chapter-01-hy/...
│   │
│   ├── he/
│   │   └── chapter-01-he/...
│   │
│   ├── ar/
│   │   └── chapter-01-ar/...
│   │
│   ├── tr/
│   │   └── chapter-01-tr/...
│   │
│   └── sw/
│       └── chapter-01-sw/...
│
└── meta/
    ├── languages.json
    └── chapters.json
```

### Примеры файлов

**`sanskrit/chapter-01-sanskrit/chapter-01-1.1-sanskrit_sloka.txt`**:
```
धृतराष्ट्र उवाच ।
धर्मक्षेत्रे कुरुक्षेत्रे समवेता युयुत्सवः ।
मामकाः पाण्डवाश्चैव किमकुर्वत सञ्जय ॥१॥
```

**`original/ru/chapter-01-ru/chapter-01-1.1-ru_sloka.txt`**:
```
Дхритараштра сказал:
Санджая! Что произошло, когда мои сыновья и сыновья Панду сошлись для битвы на священной земле Курукшетры?
```

**`original/ru/chapter-01-ru/chapter-01-1.1-ru_translit.txt`**:
```
дхр̣тара̄ш̣т̣ра ува̄ча
дхарма-кш̣етре куру-кш̣етре, самавета̄ йуйутсавах̣
ма̄мака̄х̣ па̄н̣д̣ава̄ш́ чаива, ким акурвата сан̃джайа
```

**`original/ru/chapter-01-ru/chapter-01-ru_meta.json`**:
```json
{
  "chapter": 1,
  "language": "ru",
  "title": "Осмотр Армий",
  "totalSlokas": 37,
  "approved": true
}
```

**`original/ru/chapter-01-ru/chapter-01-ru_vocabulary.json`**:
```json
{
  "meta": {
    "chapter": 1,
    "language": "ru"
  },
  "slokas": {
    "1.1": [
      {
        "sanskrit": "धर्मक्षेत्रे",
        "word": "дхарма-кш̣етре",
        "meaning": "на поле дхармы",
        "order": 1
      },
      {
        "sanskrit": "कुरुक्षेत्रे",
        "word": "куру-кш̣етре",
        "meaning": "на поле Куру",
        "order": 2
      }
    ],
    "1.2": [...]
  }
}
```

**`original/en/chapter-02-en/chapter-02-2.11-en_comment.txt`**:
```
*Birth, existence, growth, maturity, diminution, and destruction.
```

### JSON структуры

**`original/ru/chapter-01-ru/chapter-01-ru_vocabulary.json`**:
```json
{
  "meta": {
    "chapter": 1,
    "language": "ru",
    "totalWords": 498,
    "lastUpdated": "2026-03-29"
  },
  "slokas": {
    "1.1": [
      {
        "sanskrit": "धर्मक्षेत्रे",
        "word": "дхарма-кш̣етре",
        "meaning": "на поле дхармы",
        "order": 1
      },
      {
        "sanskrit": "कुरुक्षेत्रे",
        "word": "куру-кш̣етре",
        "meaning": "на поле Куру",
        "order": 2
      },
      {
        "sanskrit": "समवेताः",
        "word": "самавета̄х̣",
        "meaning": "собравшись",
        "order": 3
      }
    ],
    "1.2": [...],
    "1.4-6": [...]
  }
}
```

**`original/ru/chapter-01-ru/chapter-01-ru_meta.json`**:
```json
{
  "chapter": 1,
  "language": "ru",
  "title": "Осмотр Армий",
  "totalSlokas": 37,
  "approved": true,
  "lastUpdated": "2026-03-29",
  "audio": {
    "recitation": "/audio/chapter-01-recitation.mp3"
  }
}
```

**`sanskrit/chapter-01-sanskrit/chapter-01-sanskrit_meta.json`**:
```json
{
  "chapter": 1,
  "language": "sanskrit",
  "totalSlokas": 37,
  "lastUpdated": "2026-03-29",
  "slokaList": ["1.1", "1.2", "1.3", "1.4-6", "1.7", "1.8-9", "..."]
}
```

**`meta/languages.json`**:
```json
{
  "sanskrit": {
    "name": "Sanskrit",
    "nativeName": "संस्कृतम्",
    "script": "devanagari",
    "direction": "ltr",
    "type": "source"
  },
  "ru": {
    "name": "Russian",
    "nativeName": "Русский",
    "script": "cyrillic",
    "direction": "ltr",
    "type": "original",
    "transliteration": "cyrillic"
  },
  "en": {
    "name": "English",
    "nativeName": "English",
    "script": "latin",
    "direction": "ltr",
    "type": "original",
    "transliteration": "iast"
  },
  "ko": {
    "name": "Korean",
    "nativeName": "한국어",
    "script": "hangul",
    "direction": "ltr",
    "type": "translated",
    "transliteration": "hangul"
  },
  "he": {
    "name": "Hebrew",
    "nativeName": "עברית",
    "script": "hebrew",
    "direction": "rtl",
    "type": "translated",
    "transliteration": "hebrew"
  }
}
```

**`meta/chapters.json`**:
```json
{
  "totalChapters": 18,
  "chapters": [
    {
      "number": 1,
      "slokaCount": 37,
      "slokaList": ["1.1", "1.2", "1.3", "1.4-6", "1.7", "..."]
    },
    {
      "number": 2,
      "slokaCount": 72,
      "slokaList": ["2.1", "2.2", "..."]
    }
  ]
}
```

---

## Approval

- [x] Reviewed by: User
- [x] Approved on: 2026-03-29
- [x] Notes: Requirements approved. Proceeding to specifications.
