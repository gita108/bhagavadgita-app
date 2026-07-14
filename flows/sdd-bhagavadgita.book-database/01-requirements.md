# Requirements: GitaBook Database

> Version: 1.2
> Status: DRAFT
> Last Updated: 2026-03-26

## Problem Statement

Текущая структура данных в CSV файлах имеет ряд проблем:
- Несогласованность форматов (разные разделители, именование файлов)
- Отсутствие referential integrity (пропуски в ID последовательностях)
- Дублирование данных между таблицами
- Нет поддержки версионирования контента
- Сложно добавлять новые языки и издания

Нужна грамотная реляционная структура БД, которая:
- Обеспечит целостность данных
- Упростит добавление нового контента
- Поддержит расширяемость (новые языки, авторы, форматы)

## User Stories

### Primary

**As a** разработчик приложения
**I want** нормализованную структуру БД
**So that** можно эффективно запрашивать и обновлять контент

**As a** контент-менеджер
**I want** легко добавлять новые переводы и издания
**So that** приложение можно расширять на новые языки

**As a** пользователь приложения
**I want** быстро получать тексты с аудио и словарем
**So that** изучение Гиты было удобным

**As a** ученик (пользователь)
**I want** задать вопрос по шлоке духовному учителю
**So that** получить разъяснение сложного момента

**As a** духовный учитель
**I want** отвечать на вопросы учеников по конкретным шлокам
**So that** помогать в духовном развитии

### Secondary

**As a** администратор
**I want** отправлять push-уведомления пользователям
**So that** информировать о новом контенте

## Acceptance Criteria

### Must Have

1. **Given** структура БД
   **When** добавляется новый язык
   **Then** достаточно добавить запись в `languages` без изменения схемы

2. **Given** структура БД
   **When** добавляется новое издание книги
   **Then** все главы и шлоки наследуют связь автоматически

3. **Given** структура БД
   **When** запрашивается шлока с переводом
   **Then** возвращается: оригинал (санскрит), транслитерация, перевод, комментарий, аудио

4. **Given** структура БД
   **When** запрашивается словарь для шлоки
   **Then** возвращаются все слова с переводами в правильном порядке

5. **Given** структура БД
   **When** существует FK constraint
   **Then** нельзя удалить язык, если есть связанные книги

6. **Given** шлока
   **When** у неё есть комментарий от автора издания
   **Then** комментарий доступен вместе с текстом шлоки

7. **Given** ученик задает вопрос по шлоке
   **When** духовный учитель отвечает
   **Then** вопрос и ответ связаны с конкретной шлокой

### Should Have

- Поддержка версионирования переводов (history)
- Возможность помечать "цитату дня"
- Full-text search по текстам

### Won't Have (This Iteration)

- User accounts и персонализация (только device-based)
- Рейтинги/лайки на вопросах
- Offline sync mechanism
- Push notification logic (только хранение токенов)
- Аналитика активности (используем Firebase)

## Design Decisions (из обсуждения)

1. **Комментарии**: Поле `comment` в таблице slokas (один комментарий от автора издания)
2. **Вопрос-ответ**: Новая сущность `sloka_questions` (ученик) + `question_answers` (учитель)
3. **Аудио**: Хранить только пути к файлам, не BLOB
4. **Авторы**: Поле `initials` в таблице books (без отдельной таблицы)
5. **Analytics**: Убрать сырую аналитику, оставить минимум для push-токенов

## Domain Model

### Терминология
- **Шлока** (Sloka/Shloka) - стих из Бхагавад-гиты
- **Духовный учитель** (Guru/Teacher) - автор комментариев и ответов
- **Ученик** (Student/User) - пользователь приложения

### Сущности
```
Основной контент:
- Languages (языки)
- Books (издания/переводы)
- Chapters (главы, 18 в каждой книге)
- Slokas (шлоки/стихи + комментарий автора издания)
- SlokaVocabulary (пословный перевод)

Q&A (вопросы учеников):
- SlokaQuestions (вопросы учеников по шлокам)
- QuestionAnswers (ответы духовных учителей)

Вдохновение:
- Quotes (цитаты известных людей)

Техническое:
- Devices (push-токены для уведомлений)
```

## Constraints

- **Technical**: Совместимость с PostgreSQL и SQLite
- **Performance**: Получение шлоки с словарем < 100ms
- **Data Volume**: ~700 шлок × ~4 языка = ~2800 записей контента
- **Encoding**: UTF-8 для всех текстовых полей (санскрит, кириллица)

## Open Questions

- [x] ~~Нужна ли поддержка нескольких комментариев к одному стиху?~~ → Нет, один комментарий от автора издания (поле в slokas)
- [x] ~~Хранить ли аудио файлы в БД?~~ → Нет, только пути
- [x] ~~Нужна ли таблица авторов?~~ → Нет, поле в books
- [x] ~~Оставлять ли devices?~~ → Минимально, только для push-токенов

## References

- Legacy CSV analysis: `flows/legacy/understanding/_root.md`
- Original data: `/legacy/legacy_bhagavadgita.book.db/`

---

## Legacy Analysis Additions
> Added by /legacy on 2026-04-29

### Legacy Code Validation

Analyzed iOS Swift and Android Java implementations to validate domain model:

| Entity | Legacy Swift | Legacy Java | DB CSV | Matches Design |
|--------|--------------|-------------|--------|----------------|
| Languages | Language.swift | Language.java | db_languages.csv | Yes |
| Books | Book.swift | Book.java | db_books.csv | Yes (initials confirmed) |
| Chapters | Chapter.swift | Chapter.java | db_chapters.csv | Yes |
| Slokas | Shloka.swift | Sloka.java | Gita_Slokas.csv | Yes (comment field confirmed) |
| Vocabularies | Vocabulary.swift | Vocabulary.java | Gita_Vocabularies.csv | Yes |
| Quotes | Quote.swift | Quote.java | db_quoutes.csv | Yes |
| Bookmarks | Bookmark.swift | (in Sloka) | - | Design aligns |

### CSV Schema Confirmation

| File | Delimiter | Columns | Records |
|------|-----------|---------|---------|
| db_languages.csv | `,` | Id,Name,Code | 4 |
| db_books.csv | `,` | Id,LanguageId,Name,Initials | 6 |
| db_chapters.csv | `,` | Id,BookId,Name,Order | 143 |
| Gita_Slokas.csv | `;` | Id,ChapterId,Name,Text,Transcription,Translation,Comment,Order,Audio,AudioSanskrit | ~700 |
| Gita_Vocabularies.csv | `;` | Id,SlokaId,Text,Translation | ~5000 |
| db_quoutes.csv | `,` | Id,LanguageId,Author,Text,IsDay | ~150 |

### Key Design Decisions Confirmed

1. **Single comment per sloka**: Confirmed in both Swift (`Shloka.comment: String`) and Java (`private String comment`)
2. **Audio paths only**: Both platforms store paths (`/Files/*.mp3`), not BLOBs
3. **Initials in books**: Confirmed field in both platforms (`Book.initials`)
4. **Vocabulary per sloka**: Both platforms use `[Vocabulary]` array in Shloka

### Data Quality Notes

- Language ID=4 missing (gap in sequence)
- Book IDs have gaps: 1,2,5,8,11,14 (not sequential)
- German chapters have embedded newlines in names
- All CSV files use UTF-8 with BOM

### Source Files Reference

- Swift models: `legacy/legacy_bhagavadgita.book_swift/Gita/Model/DataAccess/DataClasses/`
- Java models: `legacy/legacy_bhagavadgita.book_java/app/src/main/java/com/ethnoapp/bgita/model/`
- Full analysis: `flows/legacy/understanding/_root.md`

---

## Approval

- [ ] Reviewed by: [name]
- [ ] Approved on: [date]
- [ ] Notes: [any conditions or clarifications]
