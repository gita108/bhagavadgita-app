# UI Inventory (legacy Swift → Flutter)

> Flow: `flows/sdd-bhagavadgita.book-layout-swift/`  
> Last Updated: 2026-04-29

## Legacy iOS (Swift) - Entry Points

### ViewControllers

- `SplashViewController.swift`
- `ContentsViewController.swift`
- `ContentsSearchResultViewController.swift`
- `ShlokaViewController.swift`
- `BookmarksViewController.swift`
- `QuoteViewController.swift`
- `SettingsViewController.swift`
- `SettingsLanguageViewController.swift`
- `GuideViewController.swift`
- `GuideItemViewController.swift`
- `GuideNotesViewController.swift`
- `CommentViewController.swift`
- `CustomNavigationController.swift`

### Storyboards

- `Resources/LaunchScreen.storyboard`
- `Resources/LaunchScreen_iPad.storyboard`

### Reusable Views / Cells

- Bookmarks: `BookmarkTableViewCell`, `EmptyBookmarksView`
- Quotes: `QuoteTableViewCell`, `QuoteView`
- Reader (Shloka): `ShlokaHeaderTableViewCell`, `ShlokaSanskritTableViewCell`, `ShlokaTranscriptionTableViewCell`, `ShlokaTranslationTableViewCell`, `ShlokaInterpretationTableViewCell`, `ShlokaWordsTableViewCell`, `ShlokaShowHideButtonTableViewCell`, `ShlokaSeparatorTableViewCell`, `ShlokaChapterContentsTableViewCell`, `ShlokaNumberCollectionViewCell`, `ShlokaPlayerView`
- Settings: `LanguageSettingsTableViewCell`, `InterpretationSettingsTableViewCell`, `UnitSettingsTableViewCell`
- Common: `CircularProgress`, `ProgressButton`, `ChapterContentsHeaderView`

## Flutter (current) - Screen files

- Splash: `lib/features/splash/splash_screen.dart`
- Contents: `lib/features/contents/contents_screen.dart`
- Reader (chapter): `lib/features/reader/chapter_screen.dart`
- Reader (sloka): `lib/features/reader/sloka_screen.dart`
- Search: `lib/features/search/search_screen.dart`
- Settings: `lib/features/settings/settings_screen.dart`, `lib/features/settings/reader_settings.dart`

## Initial Mapping (to refine)

| Legacy | Flutter | Notes |
|--------|---------|------|
| `SplashViewController` | `SplashScreen` | перенос сплэша/лого/прогресса |
| `ContentsViewController` | `ContentsScreen` | список глав/содержания |
| `ContentsSearchResultViewController` | `SearchScreen` | оформить результаты как в legacy |
| `ShlokaViewController` | `SlokaScreen` | основной ридер: типографика, секции, кнопки |
| `BookmarksViewController` + `EmptyBookmarksView` | (уточнить в Flutter) | возможно часть `reader`/отдельный экран отсутствует |
| `QuoteViewController` + `QuoteView` | (уточнить в Flutter) | есть DTO `quote_dto.dart`, нужен экран/виджет |
| `Settings*` | `SettingsScreen` + `ReaderSettings` | перенос ячеек/секций |

## Next

1. Прочитать ключевые legacy контроллеры/вьюхи и выписать: layout-структуру, размеры/отступы, используемые ассеты, состояния.
2. Прочитать текущие Flutter экраны и отметить расхождения по UI.
3. Сформировать список ассетов для переноса и их назначение.

## Notes from initial code read (legacy)

### Contents (legacy)

- **Nav bar**: красная навигация (`setUpNavigationBar(isRed: true)`), светлые иконки.
- **Nav icons**:
  - `ic_settings`
  - `ic_search_white`
  - `ic_bookmarks`
- **Layout**:
  - таблица с секциями-главами, раскрывающийся header (`ChapterContentsHeaderView`)
  - внутри раскрытой секции кастомная сетка/лейаут шлок (`ShlokasChapterContentsTableViewCell`)
  - опционально: секция с цитатой вверху (`QuoteTableViewCell`)
- **iPad behavior**: split-view (master: contents/bookmarks, detail: shloka)

### Shloka reader (legacy)

- **Structure**: `UITableView` с 11 секциями, каждая — отдельный “блок” (header / separators / sanskrit / transcription / vocabulary / translations / interpretations / show-more button).
- **Nav icons**:
  - comment: `ic_comment`, `ic_commented`, `ic_commented_white`
  - bookmark: `ic_bookmark`, `ic_bookmarked`, `ic_bookmarked_white`
  - back: `ic_back`
- **Audio**: нижняя панель `ShlokaPlayerView` (высота 57 + safe area), скрывается если аудио выключено/нет файла.
- **Gestures**: свайпы влево/вправо для next/previous.

## Notes from initial code read (Flutter)

- `ContentsScreen` и `SlokaScreen` сейчас используют стандартный `AppBar` и `Icons.*`.
- `SlokaScreen` уже имеет секции контента (sanskrit/transliteration/translation/comment/vocabulary) через `ReaderSettings`, но нет legacy-структуры (header-блок с next/prev, разделители, show/hide интерпретаций, аудиопанель, кастомные ассеты).
