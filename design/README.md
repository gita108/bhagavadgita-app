# Bhagavad Gita — Flutter App

Full Flutter implementation of the layouts from
`flows/vdd-bhagavadgita.book-layouts/` (requirements + visual mockups),
informed by the legacy Swift and Java apps.

## Run

```
flutter pub get
flutter run
```

## Structure

```
lib/
├── main.dart
├── app/
│   └── app.dart                          # MaterialApp + theme
├── data/
│   ├── models.dart                       # Chapter, Sloka, VocabEntry, Commentary
│   ├── mock_content.dart                 # 18 chapters + sample slokas
│   └── user_data_store.dart              # in-memory bookmarks + notes
├── features/
│   ├── splash/splash_screen.dart         # red gradient + Om logo + progress
│   ├── onboarding/onboarding_screen.dart # 3-page guide with PageDots
│   ├── contents/contents_screen.dart     # phone + tablet master-detail
│   ├── reader/
│   │   ├── chapter_screen.dart           # sloka list, bookmark indicators
│   │   └── sloka_screen.dart             # all sections + audio bar
│   ├── search/search_screen.dart         # circular reveal + highlight
│   ├── bookmarks/bookmarks_screen.dart   # swipe-to-delete via Slidable
│   └── settings/
│       ├── settings_screen.dart
│       ├── language_screen.dart
│       └── reader_settings.dart
└── ui/
    ├── theme/
    │   ├── app_colors.dart               # red1/2/3, gray1-5
    │   ├── app_text.dart                 # PT Sans + Devanagari styles
    │   └── app_theme.dart                # global ThemeData
    └── widgets/
        ├── om_logo.dart                  # Om (ॐ) mark + splash wordmark
        ├── author_badge.dart             # circle initials for commentaries
        ├── page_dots.dart                # PageView indicator + QuoteCard
        ├── audio_player_bar.dart         # dual-track + progress + auto-play
        └── section_label.dart            # uppercase gray section header
```

## Design tokens

Lifted from `legacy/legacy_bhagavadgita.book_swift/Gita/Resources/Style.swift`
and `legacy/legacy_bhagavadgita.book_java/.../res/values/colors.xml`:

| Token            | Value     | Usage                            |
|------------------|-----------|----------------------------------|
| `red1`           | `#FF5252` | AppBar, primary, switches        |
| `red2`           | `#FB9A6A` | Splash gradient, accents         |
| `red3`           | `#C94545` | StatusBar (Android), destructive |
| `gray1`          | `#4A4A4A` | Primary text                     |
| `gray2`          | `#9B9B9B` | Captions / labels                |
| `gray3`          | `#C7C7CC` | Borders                          |
| `gray4`          | `#E8E8E8` | Light dividers                   |
| `gray5`          | `#F9F9F9` | Surface backgrounds              |

Type pairing: **PT Sans** for UI (via `google_fonts`), **Noto Sans Devanagari**
as a libre stand-in for Kohinoor Devanagari for Sanskrit verses (the spec
calls Kohinoor's licensing out as an open question).

## Screens implemented

1. **Splash** — gradient bg, Om wordmark, progress bar + percentage, optional
   "Download audio" dialog.
2. **Onboarding** — 3 pages with `PageView`, animated `PageDots`, conditional
   Skip / Back / Next / Done buttons.
3. **Contents** — chapter list with optional Quote of the Day card; tablet
   layout switches to a 40/60 master-detail at `width >= 720`.
4. **Chapter** — sloka list with bookmark indicator per row.
5. **Sloka detail** — Previous/Next, label + transcription title, all five
   sections (Sanskrit, Transcription, Vocabulary, Translation, Commentary
   with `AuthorBadge`), personal note + Save button, persistent
   `AudioPlayerBar` with track selector, progress, auto-play toggle.
6. **Settings** — Display, Audio (download tiles with progress), Language nav,
   Books & Commentaries, Notifications. All toggles wired to a
   `ReaderSettingsController` that other screens listen to.
7. **Search** — opens with a Material **circular reveal** transition from
   the AppBar icon position, `_Highlighted` rich text marks matches in red,
   scope chips for All / Bookmarks.
8. **Bookmarks** — `flutter_slidable` swipe-to-delete, note preview block
   under each row, friendly empty state.
9. **Language** — list with red checkmark on the selected language.

## Components reused

- `AuthorBadge` — red-bordered circle with white background and red initials,
  matching the Swift `circle_initials.png` asset behavior.
- `OmLogo` / `SplashWordmark` — text-based Om glyph; no raster assets needed.
- `AudioPlayerBar` — single component used on every sloka screen.
- `PageDots` — animated indicator (active dot widens to 22px).
- `QuoteCard` — gradient card with `format_quote` glyph.

## Notes / next steps

- The mock `MockContent` and `UserDataStore` should be swapped for the
  existing Drift-backed repos (`AppDatabase` + `UserDataRepository`) before
  shipping; all screens read through value-notifiers so the swap is local.
- `just_audio` + `audio_service` are listed in `pubspec.yaml` for the audio
  bar; the bar currently animates a mock progress value.
- Kohinoor Devanagari licensing should be resolved before swapping
  `notoSansDevanagari` back to the bundled font.
