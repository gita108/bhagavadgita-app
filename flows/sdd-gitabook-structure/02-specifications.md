# Specifications: GitaBook Folder Structure

> Version: 1.0
> Status: APPROVED
> Last Updated: 2026-03-29
> Requirements: [01-requirements.md](./01-requirements.md)

## Overview

Реорганизация структуры данных проекта GitaBook для разделения первоисточника (санскрит), оригинальных переводов и машинных переводов. Каждый файл содержит в имени информацию о главе и языке.

## Affected Systems

| Путь | Действие | Описание |
|------|----------|----------|
| `data/sanskrit/` | Create | Первоисточник (деванагари) |
| `data/original/` | Create | Оригинальные переводы (ru, en, de, es) |
| `data/translated/` | Create | Машинные переводы (11 языков) |
| `data/meta/` | Modify | Обновить languages.json, chapters.json |
| `data/chapters/` | Delete | Заменяется новой структурой |
| `data/vocabulary/` | Delete | Перемещается в original/{lang}/ |

## Architecture

### Структура директорий

```
data/
├── sanskrit/                           # Первоисточник
│   ├── chapter-01-sanskrit/
│   ├── chapter-02-sanskrit/
│   └── ...chapter-18-sanskrit/
│
├── original/                           # Оригинальные переводы
│   ├── ru/
│   │   ├── chapter-01-ru/
│   │   └── ...
│   ├── en/
│   ├── de/
│   └── es/
│
├── translated/                         # Машинные переводы
│   ├── ko/
│   ├── th/
│   ├── zh-CN/
│   ├── zh-TW/
│   ├── el/
│   ├── ka/
│   ├── hy/
│   ├── he/
│   ├── ar/
│   ├── tr/
│   └── sw/
│
└── meta/
    ├── languages.json
    └── chapters.json
```

### Содержимое папки главы

**Sanskrit:**
```
chapter-01-sanskrit/
├── chapter-01-1.1-sanskrit_sloka.txt
├── chapter-01-1.2-sanskrit_sloka.txt
├── chapter-01-1.4-6-sanskrit_sloka.txt
└── chapter-01-sanskrit_meta.json
```

**Original (ru, en, de, es):**
```
chapter-01-ru/
├── chapter-01-1.1-ru_sloka.txt
├── chapter-01-1.1-ru_translit.txt
├── chapter-01-1.1-ru_comment.txt        # если есть
├── chapter-01-1.2-ru_sloka.txt
├── chapter-01-1.2-ru_translit.txt
├── chapter-01-ru_meta.json
└── chapter-01-ru_vocabulary.json
```

**Translated (ko, th, zh-CN, etc.):**
```
chapter-01-ko/
├── chapter-01-1.1-ko_sloka.txt
├── chapter-01-1.1-ko_translit.txt
├── chapter-01-1.1-ko_comment.txt        # если есть
├── chapter-01-ko_meta.json
└── (без vocabulary - генерируется из original)
```

## Naming Conventions

### Файлы

| Тип | Паттерн | Пример |
|-----|---------|--------|
| Шлока | `chapter-{N}-{sloka}-{lang}_sloka.txt` | `chapter-01-1.1-ru_sloka.txt` |
| Транслитерация | `chapter-{N}-{sloka}-{lang}_translit.txt` | `chapter-01-1.1-ru_translit.txt` |
| Комментарий | `chapter-{N}-{sloka}-{lang}_comment.txt` | `chapter-02-2.11-en_comment.txt` |
| Метаданные | `chapter-{N}-{lang}_meta.json` | `chapter-01-ru_meta.json` |
| Словарь | `chapter-{N}-{lang}_vocabulary.json` | `chapter-01-ru_vocabulary.json` |

### Папки

| Тип | Паттерн | Пример |
|-----|---------|--------|
| Глава | `chapter-{N}-{lang}/` | `chapter-01-ru/` |

### Номера шлок

- Простые: `1.1`, `1.2`, `2.15`
- Объединённые: `1.4-6`, `1.8-9`, `6.11-12`

## Data Models

### chapter-{N}-{lang}_meta.json

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

### chapter-{N}-sanskrit_meta.json

```json
{
  "chapter": 1,
  "language": "sanskrit",
  "totalSlokas": 37,
  "lastUpdated": "2026-03-29",
  "slokaList": ["1.1", "1.2", "1.3", "1.4-6", "1.7", "1.8-9", "..."]
}
```

### chapter-{N}-{lang}_vocabulary.json

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
      }
    ]
  }
}
```

### meta/languages.json

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
  "de": {
    "name": "German",
    "nativeName": "Deutsch",
    "script": "latin",
    "direction": "ltr",
    "type": "original",
    "transliteration": "iast"
  },
  "es": {
    "name": "Spanish",
    "nativeName": "Español",
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
  "th": {
    "name": "Thai",
    "nativeName": "ไทย",
    "script": "thai",
    "direction": "ltr",
    "type": "translated",
    "transliteration": "thai"
  },
  "zh-CN": {
    "name": "Chinese (Simplified)",
    "nativeName": "简体中文",
    "script": "hanzi-simplified",
    "direction": "ltr",
    "type": "translated",
    "transliteration": "hanzi-simplified"
  },
  "zh-TW": {
    "name": "Chinese (Traditional)",
    "nativeName": "繁體中文",
    "script": "hanzi-traditional",
    "direction": "ltr",
    "type": "translated",
    "transliteration": "hanzi-traditional"
  },
  "el": {
    "name": "Greek",
    "nativeName": "Ελληνικά",
    "script": "greek",
    "direction": "ltr",
    "type": "translated",
    "transliteration": "greek"
  },
  "ka": {
    "name": "Georgian",
    "nativeName": "ქართული",
    "script": "georgian",
    "direction": "ltr",
    "type": "translated",
    "transliteration": "georgian"
  },
  "hy": {
    "name": "Armenian",
    "nativeName": "Հայdelays",
    "script": "armenian",
    "direction": "ltr",
    "type": "translated",
    "transliteration": "armenian"
  },
  "he": {
    "name": "Hebrew",
    "nativeName": "עברית",
    "script": "hebrew",
    "direction": "rtl",
    "type": "translated",
    "transliteration": "hebrew"
  },
  "ar": {
    "name": "Arabic",
    "nativeName": "العربية",
    "script": "arabic",
    "direction": "rtl",
    "type": "translated",
    "transliteration": "arabic"
  },
  "tr": {
    "name": "Turkish",
    "nativeName": "Türkçe",
    "script": "latin",
    "direction": "ltr",
    "type": "translated",
    "transliteration": "iast"
  },
  "sw": {
    "name": "Swahili",
    "nativeName": "Kiswahili",
    "script": "latin",
    "direction": "ltr",
    "type": "translated",
    "transliteration": "iast"
  }
}
```

### meta/chapters.json

```json
{
  "totalChapters": 18,
  "chapters": [
    {
      "number": 1,
      "slokaCount": 37,
      "slokaList": ["1.1", "1.2", "1.3", "1.4-6", "1.7", "1.8-9", "1.10", "..."]
    },
    {
      "number": 2,
      "slokaCount": 72,
      "slokaList": ["2.1", "2.2", "..."]
    }
  ]
}
```

## Migration Strategy

### Этап 1: Создание структуры

1. Создать директории `sanskrit/`, `original/`, `translated/`, `meta/`
2. Создать поддиректории для всех языков
3. Создать поддиректории для всех глав (18 × 16 языков = 288 папок)

### Этап 2: Миграция данных

**Из `data/chapters/original/chapter-XX.json`:**
- Извлечь санскрит → `sanskrit/chapter-XX-sanskrit/`
- Извлечь ru, en, de, es → `original/{lang}/chapter-XX-{lang}/`
- Извлечь ko, th, zh-* → `translated/{lang}/chapter-XX-{lang}/`

**Из `data/vocabulary/original/vocab_XX.json`:**
- Извлечь по языкам → `original/{lang}/chapter-XX-{lang}/chapter-XX-{lang}_vocabulary.json`

### Этап 3: Валидация

1. Проверить количество файлов
2. Сравнить содержимое с оригиналом
3. Проверить JSON структуры

### Этап 4: Удаление старой структуры

1. Удалить `data/chapters/`
2. Удалить `data/vocabulary/`
3. Обновить `data/meta/`

## File Statistics (Expected)

| Категория | Количество |
|-----------|------------|
| Языков (total) | 16 (1 sanskrit + 4 original + 11 translated) |
| Глав | 18 |
| Шлок (примерно) | ~700 |
| Папок глав | 288 (18 × 16) |
| Файлов шлок | ~11,200 (700 × 16) |
| Файлов транслит | ~11,200 |
| Файлов комментариев | ~200 (не все шлоки) |
| Файлов vocabulary | 72 (18 × 4 original) |
| Файлов meta | 288 |
| **Итого файлов** | ~23,000 |

## Edge Cases

| Случай | Описание | Решение |
|--------|----------|---------|
| Объединённые шлоки | 1.4-6, 1.8-9 | Использовать дефис: `chapter-01-1.4-6-ru_sloka.txt` |
| Отсутствующий перевод | Не все языки имеют все переводы | Файл не создаётся |
| RTL языки | he, ar | Указать в languages.json `direction: "rtl"` |
| Отсутствующий комментарий | Не все шлоки имеют комментарии | Файл не создаётся |

## Dependencies

### Requires

- Существующие данные в `data/chapters/`
- Python или Node.js для скрипта миграции

### Blocks

- Генерация GitBook (нужно обновить после миграции)
- Любые скрипты читающие старую структуру

## Open Design Questions

- [x] Формат именования файлов - решено
- [x] Структура vocabulary - решено
- [ ] Нужен ли скрипт обратной миграции?
- [ ] Как обрабатывать аудио-файлы?

---

## Approval

- [x] Reviewed by: User
- [x] Approved on: 2026-03-29
- [x] Notes: Specifications approved. Proceeding to plan.
