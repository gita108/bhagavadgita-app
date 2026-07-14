# Plan: GitaBook Folder Structure

> Version: 1.0
> Status: APPROVED
> Last Updated: 2026-03-29
> Specifications: [02-specifications.md](./02-specifications.md)

## Task Breakdown

### Phase 1: Подготовка

| # | Задача | Файлы | Зависимости |
|---|--------|-------|-------------|
| 1.1 | Создать скрипт миграции | `scripts/migrate-structure.py` | - |
| 1.2 | Создать backup текущих данных | `data.backup/` | - |

### Phase 2: Создание структуры директорий

| # | Задача | Файлы | Зависимости |
|---|--------|-------|-------------|
| 2.1 | Создать `data/sanskrit/` с 18 папками глав | `sanskrit/chapter-{01-18}-sanskrit/` | 1.1 |
| 2.2 | Создать `data/original/` с 4 языками × 18 глав | `original/{ru,en,de,es}/chapter-{01-18}-{lang}/` | 1.1 |
| 2.3 | Создать `data/translated/` с 11 языками × 18 глав | `translated/{ko,th,...}/chapter-{01-18}-{lang}/` | 1.1 |
| 2.4 | Создать `data/meta/` | `meta/` | 1.1 |

### Phase 3: Миграция санскрита

| # | Задача | Источник | Назначение |
|---|--------|----------|------------|
| 3.1 | Извлечь шлоки санскрита | `chapters/original/chapter-XX.json` → `slokas[].sanskrit` | `sanskrit/chapter-XX-sanskrit/chapter-XX-{sloka}-sanskrit_sloka.txt` |
| 3.2 | Создать meta для санскрита | Извлечь из JSON | `sanskrit/chapter-XX-sanskrit/chapter-XX-sanskrit_meta.json` |

### Phase 4: Миграция original языков (ru, en, de, es)

| # | Задача | Источник | Назначение |
|---|--------|----------|------------|
| 4.1 | Извлечь переводы шлок | `slokas[].translations.{lang}.text` | `chapter-XX-{sloka}-{lang}_sloka.txt` |
| 4.2 | Извлечь транслитерацию | `slokas[].transliteration` | `chapter-XX-{sloka}-{lang}_translit.txt` |
| 4.3 | Извлечь комментарии | `slokas[].comment.{lang}.text` | `chapter-XX-{sloka}-{lang}_comment.txt` |
| 4.4 | Создать meta | `chapter`, `title.{lang}` | `chapter-XX-{lang}_meta.json` |
| 4.5 | Создать vocabulary | `slokas[].vocabulary[]` | `chapter-XX-{lang}_vocabulary.json` |

### Phase 5: Миграция translated языков (ko, th, zh-CN, etc.)

| # | Задача | Источник | Назначение |
|---|--------|----------|------------|
| 5.1 | Извлечь переводы шлок | `slokas[].translations.{lang}.text` | `chapter-XX-{sloka}-{lang}_sloka.txt` |
| 5.2 | Извлечь/генерировать транслитерацию | `slokas[].transliteration` или генерация | `chapter-XX-{sloka}-{lang}_translit.txt` |
| 5.3 | Извлечь комментарии | `slokas[].comment.{lang}.text` | `chapter-XX-{sloka}-{lang}_comment.txt` |
| 5.4 | Создать meta | - | `chapter-XX-{lang}_meta.json` |

### Phase 6: Миграция meta

| # | Задача | Источник | Назначение |
|---|--------|----------|------------|
| 6.1 | Обновить languages.json | `data/meta/languages.json` | Добавить новые поля (type, script, transliteration) |
| 6.2 | Создать chapters.json | Извлечь из всех глав | `meta/chapters.json` |

### Phase 7: Валидация

| # | Задача | Описание |
|---|--------|----------|
| 7.1 | Проверить количество файлов | Ожидается ~23,000 файлов |
| 7.2 | Валидировать JSON | Проверить все _meta.json и _vocabulary.json |
| 7.3 | Сравнить содержимое | Выборочная проверка соответствия |
| 7.4 | Проверить именование | Все файлы соответствуют паттерну |

### Phase 8: Очистка

| # | Задача | Описание |
|---|--------|----------|
| 8.1 | Удалить старую структуру | `data/chapters/`, `data/vocabulary/` |
| 8.2 | Удалить backup (опционально) | `data.backup/` после подтверждения |

## Script Structure

```python
# scripts/migrate-structure.py

def main():
    # Phase 1
    create_backup()

    # Phase 2
    create_directory_structure()

    # Phase 3
    migrate_sanskrit()

    # Phase 4
    for lang in ['ru', 'en', 'de', 'es']:
        migrate_original_language(lang)

    # Phase 5
    for lang in ['ko', 'th', 'zh-CN', 'zh-TW', 'el', 'ka', 'hy', 'he', 'ar', 'tr', 'sw']:
        migrate_translated_language(lang)

    # Phase 6
    update_meta_files()

    # Phase 7
    validate_migration()

    # Phase 8 (manual confirmation)
    # cleanup_old_structure()
```

## File Changes Summary

| Действие | Количество |
|----------|------------|
| Создать директорий | ~290 |
| Создать .txt файлов | ~22,500 |
| Создать .json файлов | ~360 |
| Удалить директорий | ~40 |
| Удалить файлов | ~100 |

## Rollback Strategy

1. Сохранить backup перед миграцией
2. Не удалять старую структуру до валидации
3. При ошибках - восстановить из backup

## Testing Strategy

### Автоматические проверки
- [ ] Количество файлов соответствует ожидаемому
- [ ] Все JSON файлы валидны
- [ ] Все файлы соответствуют naming convention
- [ ] Нет пустых файлов (кроме отсутствующих переводов)

### Ручная верификация
- [ ] Проверить chapter-01-ru (полностью)
- [ ] Проверить chapter-18-en (полностью)
- [ ] Проверить vocabulary для 3 языков
- [ ] Проверить RTL языки (he, ar)

## Estimated Work

| Фаза | Описание |
|------|----------|
| Phase 1-2 | Подготовка и структура |
| Phase 3-5 | Миграция данных |
| Phase 6-7 | Meta и валидация |
| Phase 8 | Очистка |

---

## Approval

- [x] Reviewed by: User
- [x] Approved on: 2026-03-29
- [x] Notes: Plan approved. Proceeding to implementation.
