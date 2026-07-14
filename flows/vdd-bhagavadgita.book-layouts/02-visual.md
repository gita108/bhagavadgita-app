# Visual Mockups: Bhagavad Gita Book Layouts

> Version: 1.0
> Status: APPROVED
> Last Updated: 2026-04-30
> Requirements: `01-requirements.md`

## Overview

ASCII mockups for all screens in the Bhagavad Gita Flutter app. Includes phone and tablet variants.

### Symbol Legend

| Symbol | Meaning |
|--------|---------|
| `=` | Header/AppBar |
| `-` | Divider/Separator |
| `\|` | Container edge |
| `[ ]` | Button/Input field |
| `[x]` | Checkbox checked |
| `( )` | Radio unchecked |
| `(*)` | Radio selected |
| `[====]` | Progress bar |
| `<` `>` | Navigation arrows |
| `*` | Active indicator |
| `.` | Inactive indicator |
| `~` | Text content |
| `#` | Icon placeholder |

---

## Screen 1: Splash Screen

First screen shown on app launch. Red gradient background with loading progress.

### Default State (Loading)

```
+------------------------------------------+
|//////////// GRADIENT RED ////////////////|
|//////////  #FB9A6A → #FF5252  ///////////|
|                                          |
|                                          |
|                                          |
|                  OM                       |
|                 LOGO                     |
|              BHAGAVAD                    |
|                GITA                      |
|                                          |
|                                          |
|           Loading data...                |
|                                          |
|            [========>    ]               |
|                 67%                      |
|                                          |
|                                          |
+------------------------------------------+
```

### Download Dialog State

```
+------------------------------------------+
|//////////// GRADIENT RED ////////////////|
|                                          |
|                  OM                       |
|                 LOGO                     |
|                                          |
|   +----------------------------------+   |
|   |                                  |   |
|   |   Download audio files?          |   |
|   |                                  |   |
|   |   Sanskrit and translation       |   |
|   |   audio (~150 MB)                |   |
|   |                                  |   |
|   |   [  Yes  ]    [  No  ]          |   |
|   |                                  |   |
|   +----------------------------------+   |
|                                          |
+------------------------------------------+
```

---

## Screen 2: Onboarding Guide (3 Pages)

Shown only on first launch. Horizontal swipe between pages.

### Page 1: Welcome

```
+------------------------------------------+
|//////////// GRADIENT RED ////////////////|
|                                          |
|                                          |
|                 #ICON                    |
|                                          |
|            Welcome to the                |
|            Bhagavad Gita                 |
|                                          |
|     Ancient wisdom for modern life.      |
|     700 verses of spiritual guidance     |
|     in Sanskrit with translations.       |
|                                          |
|                                          |
|                                          |
|                                          |
|   [Skip]                     [Next >]    |
|                                          |
|                * . .                     |
+------------------------------------------+
```

### Page 2: Navigation

```
+------------------------------------------+
|//////////// GRADIENT RED ////////////////|
|                                          |
|                                          |
|                 #ICON                    |
|                                          |
|              Easy Reading                |
|                                          |
|     Browse 18 chapters with 700+         |
|     verses. Swipe between slokas,        |
|     bookmark favorites, and add          |
|     personal notes.                      |
|                                          |
|                                          |
|                                          |
|                                          |
|   [< Back]                   [Next >]    |
|                                          |
|                . * .                     |
+------------------------------------------+
```

### Page 3: Features

```
+------------------------------------------+
|//////////// GRADIENT RED ////////////////|
|                                          |
|                                          |
|                 #ICON                    |
|                                          |
|            Listen & Learn                |
|                                          |
|     Play Sanskrit pronunciation and      |
|     translation audio. Customize         |
|     display settings to focus on         |
|     what matters to you.                 |
|                                          |
|                                          |
|                                          |
|                                          |
|   [< Back]                   [Done]      |
|                                          |
|                . . *                     |
+------------------------------------------+
```

---

## Screen 3: Contents Screen (Main)

Primary navigation screen with chapters list.

### Default State

```
+------------------------------------------+
|########## RED APPBAR #FF5252 ############|
|=                                        =|
|=  #back      Contents      #srch #sett  =|
|=                                        =|
+------------------------------------------+
|                                          |
|  +------------------------------------+  |
|  |  " Quote of the day text here     |  |
|  |    spanning multiple lines...     |  |
|  |                          - Author |  |
|  +------------------------------------+  |
|                                          |
|  ----------------------------------------|
|  | Chapter 1                         > | |
|  | Arjuna Vishada Yoga                 | |
|  ----------------------------------------|
|  | Chapter 2                         > | |
|  | Sankhya Yoga                        | |
|  ----------------------------------------|
|  | Chapter 3                         > | |
|  | Karma Yoga                          | |
|  ----------------------------------------|
|  | Chapter 4                         > | |
|  | Jnana Karma Sanyasa Yoga            | |
|  ----------------------------------------|
|  | Chapter 5                         > | |
|  | Karma Sanyasa Yoga                  | |
|  ----------------------------------------|
|  |             ...                     | |
|  | Chapter 18                        > | |
|  | Moksha Sanyasa Yoga                 | |
|  ----------------------------------------|
|                                          |
+------------------------------------------+
```

### Expanded Chapter (Verse Grid)

Chapters expand in-place to show verse chips (single numbers and ranges). **Full ASCII mockups, legend, and the canonical Universal Verse Grid Format (UVGF)** live in the dedicated flow: [`../vdd-verse-grid/02-visual.md`](../vdd-verse-grid/02-visual.md) and [`../vdd-verse-grid/03-specifications.md`](../vdd-verse-grid/03-specifications.md).

### With Search Open (Circular Reveal)

```
+------------------------------------------+
|########## WHITE APPBAR ##################|
|=                                        =|
|=  #X    [_Search slokas..._____]    #clr=|
|=                                        =|
+------------------------------------------+
|##############  SCRIM  ###################|
|########  Black 20% overlay  #############|
|                                          |
|  Search results:                         |
|                                          |
|  ----------------------------------------|
|  | 2.47 Karmanye vadhikaraste...     > | |
|  | Chapter 2 - **karma** highlighted   | |
|  ----------------------------------------|
|  | 3.19 Tasmad asaktah satatam...    > | |
|  | Chapter 3 - **karma** highlighted   | |
|  ----------------------------------------|
|  | 4.18 Karmany akarma yah...        > | |
|  | Chapter 4 - **karma** highlighted   | |
|  ----------------------------------------|
|                                          |
|                                          |
+------------------------------------------+
```

### Empty State

```
+------------------------------------------+
|########## RED APPBAR ####################|
|=         Contents          #srch #sett  =|
+------------------------------------------+
|                                          |
|                                          |
|                                          |
|                                          |
|                 #ICON                    |
|                                          |
|          No chapters found               |
|                                          |
|     Please check your connection         |
|     and try again.                       |
|                                          |
|            [  Retry  ]                   |
|                                          |
|                                          |
+------------------------------------------+
```

---

## Screen 4: Chapter Screen

List of slokas within a chapter.

```
+------------------------------------------+
|########## RED APPBAR ####################|
|=                                        =|
|=  <back     Chapter 2           #bkmrk  =|
|=            Sankhya Yoga                =|
+------------------------------------------+
|                                          |
|  ----------------------------------------|
|  | 2.1                              #bk | |
|  | Sanjaya uvaca                       | |
|  ----------------------------------------|
|  | 2.2                                 | |
|  | Kutah tva kashmalam idam            | |
|  ----------------------------------------|
|  | 2.3                                 | |
|  | Klaibyam ma sma gamah               | |
|  ----------------------------------------|
|  | 2.4                                 | |
|  | Arjuna uvaca                        | |
|  ----------------------------------------|
|  | 2.5                                 | |
|  | Gurun ahatva hi mahanubhavan        | |
|  ----------------------------------------|
|  |                                     | |
|  |              ...                    | |
|  |                                     | |
|  | 2.72                             #bk | |
|  | Esha brahmi sthitih                 | |
|  ----------------------------------------|
|                                          |
+------------------------------------------+

#bk = Bookmark indicator (filled if bookmarked)
```

---

## Screen 5: Sloka Detail Screen

Full sloka view with all sections and audio player.

### Default State (All Sections Visible)

```
+------------------------------------------+
|########## RED APPBAR ####################|
|=                                        =|
|=  <back        Sloka             #bkmrk =|
|=                                        =|
+------------------------------------------+
|                                          |
|  [< Previous]              [Next >]      |
|                                          |
|  ----------------------------------------|
|                                          |
|              2.47                        |
|        Karmanye Vadhikaraste             |
|                                          |
|  ----------------------------------------|
|                                          |
|  SANSKRIT                                |
|                                          |
|      कर्मण्येवाधिकारस्ते मा फलेषु          |
|      कदाचन। मा कर्मफलहेतुर्भूर्मा ते        |
|      सङ्गोऽस्त्वकर्मणि॥                    |
|                                          |
|  ----------------------------------------|
|                                          |
|  TRANSCRIPTION                           |
|                                          |
|  karmanye vadhikaraste ma phaleshu       |
|  kadachana, ma karma-phala-hetur bhur    |
|  ma te sango 'stv akarmani               |
|                                          |
|  ----------------------------------------|
|                                          |
|  VOCABULARY                              |
|                                          |
|  karmanye   - in work                    |
|  vadhikaraste - your right               |
|  ma         - never                      |
|  phaleshu   - in the fruits              |
|  kadachana  - at any time                |
|                                          |
|  ----------------------------------------|
|                                          |
|  TRANSLATION                             |
|                                          |
|  You have a right to perform your        |
|  prescribed duties, but you are not      |
|  entitled to the fruits of your          |
|  actions. Never consider yourself to     |
|  be the cause of results, nor be         |
|  attached to inaction.                   |
|                                          |
|  ----------------------------------------|
|                                          |
|  COMMENTARY                              |
|                                          |
|  (SP) Srila Prabhupada:                  |
|  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~     |
|  This verse establishes the principle    |
|  of nishkama karma...                    |
|  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~     |
|                                          |
|  (BG) Bhaktivedanta:                     |
|  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~     |
|  The essence of karma yoga is...         |
|  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~     |
|                                          |
|  ----------------------------------------|
|                                          |
|  NOTE                                    |
|  +------------------------------------+  |
|  | Write your personal note here...  |  |
|  |                                    |  |
|  +------------------------------------+  |
|                                          |
|         [    Save Note    ]              |
|                                          |
+------------------------------------------+
|########## AUDIO PLAYER BAR ##############|
|                                          |
|  (*)Sanskrit  ( )Translation    #auto    |
|                                          |
|  #play   [=========>          ]   2:34   |
|                                          |
+------------------------------------------+

(SP) = Author badge with initials in red circle
#auto = Auto-play toggle
```

### White Topbar + Round Nav + Mini-Player (Tablet / Compact)

```
+------------------------------------------+
|########## WHITE TOPBAR ##################|
|= <  К оглавлению            #cmt  #bkmrk=|
+------------------------------------------+
|      (◀)                     (▶)         |
|                                          |
|                 4.26                     |
|     Йога обретения духовного знания      |
|                 ---                      |
|  Sanskrit block...                       |
|                 ---                      |
|  Vocabulary / word-by-word...            |
|                 ---                      |
|  Translation / commentary blocks...      |
|                                          |
+------------------------------------------+
|########## MINI PLAYER ###################|
|  4.26 Йога обретения духовн...   [▶]     |
|  [=====>                     ]          |
+------------------------------------------+
```

Legend:
- `(◀)/(▶)` = round previous/next buttons overlaying content
- `#cmt` = comments/notes icon
- `MINI PLAYER` = compact audio bar with progress + play

### Multi-Version Translation / Commentary (Pills)

Multiple translations/commentaries may appear in the same scroll, separated by ornaments and labeled by a pill.

```
+------------------------------------------+
|                 [ En VC ]                |
|  ~ The wise say that he is learned...    |
|                 ---                      |
|                 [ En SP ]                |
|  ~ One is understood to be in full...    |
|                 ---                      |
|  (VC) Visvanath Cakravarti Thakur        |
|  commentary on Bhagavad-Gita...          |
|  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~     |
|  ...                                     |
+------------------------------------------+
```

### Collapsed Sections State

```
+------------------------------------------+
|########## RED APPBAR ####################|
|=  <back        Sloka             #bkmrk =|
+------------------------------------------+
|                                          |
|  [< Previous]              [Next >]      |
|                                          |
|              2.47                        |
|        Karmanye Vadhikaraste             |
|                                          |
|  ----------------------------------------|
|                                          |
|  TRANSLATION                             |
|                                          |
|  You have a right to perform your        |
|  prescribed duties, but you are not      |
|  entitled to the fruits of your          |
|  actions.                                |
|                                          |
|  ----------------------------------------|
|                                          |
|  (Sanskrit, Transcription, Vocabulary,   |
|   Commentary hidden via Settings)        |
|                                          |
+------------------------------------------+
|  (*)Sanskrit  ( )Translation    #auto    |
|  #play   [=========>          ]   2:34   |
+------------------------------------------+
```

---

## Screen 6: Settings Screen

Configuration options with toggles and sections.

```
+------------------------------------------+
|########## RED APPBAR ####################|
|=                                        =|
|=  <back       Settings                  =|
|=                                        =|
+------------------------------------------+
|                                          |
|  DISPLAY                                 |
|  ----------------------------------------|
|  | Show Sanskrit              [====]   | |
|  ----------------------------------------|
|  | Show Transcription         [====]   | |
|  ----------------------------------------|
|  | Show Translation           [====]   | |
|  ----------------------------------------|
|  | Show Vocabulary            [    ]   | |
|  ----------------------------------------|
|  | Show Commentary            [====]   | |
|  ----------------------------------------|
|                                          |
|  AUDIO                                   |
|  ----------------------------------------|
|  | Sanskrit Audio            [====]    | |
|  |                           150 MB    | |
|  |                      [=====>  ] 67% | |
|  ----------------------------------------|
|  | Translation Audio         [    ]    | |
|  |                           200 MB    | |
|  ----------------------------------------|
|  | Auto-play Next            [    ]    | |
|  ----------------------------------------|
|                                          |
|  LANGUAGE                                |
|  ----------------------------------------|
|  | Translation Language              > | |
|  | English                             | |
|  ----------------------------------------|
|                                          |
|  BOOKS & COMMENTARIES                    |
|  ----------------------------------------|
|  | (SP) Srila Prabhupada      [====]   | |
|  ----------------------------------------|
|  | (BG) Bhaktivedanta         [====]   | |
|  ----------------------------------------|
|  | (VS) Visvanatha            [    ]   | |
|  ----------------------------------------|
|                                          |
|  NOTIFICATIONS                           |
|  ----------------------------------------|
|  | Quote of the Day          [====]    | |
|  ----------------------------------------|
|                                          |
+------------------------------------------+

[====] = Toggle ON (red color)
[    ] = Toggle OFF
```

### Compact Settings (as in Store Screenshots)

Focuses on content visibility, audio toggles, and traktovki selection.

```
+------------------------------------------+
|########## RED APPBAR ####################|
|=  <back       Настройки                 =|
+------------------------------------------+
|  Язык                                    |
|  English, Русский                        |
|                                          |
|  Показывать                              |
|  ----------------------------------------|
|  | Санскрит                    [    ]  | |
|  ----------------------------------------|
|  | Транскрипция                [    ]  | |
|  ----------------------------------------|
|  | Пословный перевод            [    ]  | |
|  ----------------------------------------|
|  | Комментарии                 [    ]  | |
|  ----------------------------------------|
|                                          |
|  Аудио                                   |
|  ----------------------------------------|
|  | Перевод                    [====]  | |
|  ----------------------------------------|
|  | Санскрит                    [--]   | |
|  ----------------------------------------|
|  | Проигрывать автоматически    [    ]  | |
|  ----------------------------------------|
|                                          |
|  Трактовки                               |
|  ----------------------------------------|
|  | Жемчужина мудрости Востока     [✓]  | |
|  ----------------------------------------|
|  | Srimad Bhagavad-gita...         [✓]  | |
|  ----------------------------------------|
|  | Bhagavad-gita As It Is Book     [✓]  | |
|  ----------------------------------------|
|  | Visvanath Cakravarti Thakur   [Скачать]|
|  ----------------------------------------|
+------------------------------------------+
```

Legend:
- `[--]` = toggle disabled (depends on another setting)
- `[✓]` = selected traktovki item (multi-select)
- `[Скачать]` = download/install action for traktovki

---

## Screen 7: Search Screen

Full-screen search with circular reveal animation.

### Animation Sequence

```
Step 1: Icon tap          Step 2: Reveal          Step 3: Full
                          (300ms animation)
     +--+                     +------+            +------------------+
     |#S|  ──────────>       /        \   ──>    | Search...        |
     +--+                   (  reveal  )          +------------------+
                             \        /           | Results...       |
                              +------+            +------------------+
```

### Search Active State

```
+------------------------------------------+
|########## WHITE APPBAR ##################|
|=                                        =|
|=  #X    [_karma yoga__________]     #clr=|
|=                                        =|
|=  Scope: (*) All  ( ) Bookmarks         =|
+------------------------------------------+
|                                          |
|  Found 23 results                        |
|                                          |
|  ----------------------------------------|
|  | 2.47                              > | |
|  | ...perform your **karma**...        | |
|  | Chapter 2 - Sankhya Yoga            | |
|  ----------------------------------------|
|  | 3.3                               > | |
|  | ...two paths: **karma** and...      | |
|  | Chapter 3 - Karma Yoga              | |
|  ----------------------------------------|
|  | 3.19                              > | |
|  | ...without attachment to **karma**  | |
|  | Chapter 3 - Karma Yoga              | |
|  ----------------------------------------|
|  | 4.18                              > | |
|  | ...sees inaction in **karma**...    | |
|  | Chapter 4 - Jnana Yoga              | |
|  ----------------------------------------|
|  | 5.2                               > | |
|  | ...**karma** yoga is better...      | |
|  | Chapter 5 - Karma Sanyasa Yoga      | |
|  ----------------------------------------|
|                                          |
+------------------------------------------+

#X = Close button
#clr = Clear search text
**text** = Highlighted match
```

### No Results State

```
+------------------------------------------+
|########## WHITE APPBAR ##################|
|=  #X    [_xyzabc123__________]      #clr=|
+------------------------------------------+
|                                          |
|                                          |
|                                          |
|                 #ICON                    |
|                                          |
|          No results found                |
|                                          |
|     Try different keywords               |
|                                          |
|                                          |
+------------------------------------------+
```

---

## Screen 8: Bookmarks Screen

List of saved slokas with swipe actions.

### Default State

```
+------------------------------------------+
|########## RED APPBAR ####################|
|=                                        =|
|=  <back      Bookmarks           #srch  =|
|=                                        =|
+------------------------------------------+
|                                          |
|  ----------------------------------------|
|  | 2.47                              > | |
|  | Karmanye Vadhikaraste               | |
|  | Chapter 2                           | |
|  | Note: My favorite verse about...    | |
|  ----------------------------------------|
|  | 4.7                               > | |
|  | Yada yada hi dharmasya              | |
|  | Chapter 4                           | |
|  ----------------------------------------|
|  | 9.22                              > | |
|  | Ananyash chintayanto mam            | |
|  | Chapter 9                           | |
|  | Note: Beautiful promise of...       | |
|  ----------------------------------------|
|  | 11.33                             > | |
|  | Tasmat tvam uttishtha               | |
|  | Chapter 11                          | |
|  ----------------------------------------|
|  | 18.66                             > | |
|  | Sarva dharman parityajya            | |
|  | Chapter 18                          | |
|  | Note: Ultimate surrender...         | |
|  ----------------------------------------|
|                                          |
+------------------------------------------+
```

### Simple List (Compact)

```
+------------------------------------------+
|########## RED APPBAR ####################|
|=  <back      Закладки              #srch=|
+------------------------------------------+
|  1.14  Осмотр Армий                      |
|  ----------------------------------------|
|  1.15  Осмотр Армий                      |
|  ----------------------------------------|
|  1.20  Осмотр Армий                      |
|  ----------------------------------------|
|  1.25  Осмотр Армий                      |
|  ----------------------------------------|
|  1.32-34  Осмотр Армий                   |
|  ----------------------------------------|
|  ...                                     |
+------------------------------------------+
```

### Swipe to Delete (SwipeLayout)

```
+------------------------------------------+
|########## RED APPBAR ####################|
|=  <back      Bookmarks           #srch  =|
+------------------------------------------+
|                                          |
|  ----------------------------------------|
|  | 2.47                              > | |
|  | Karmanye Vadhikaraste               | |
|  ----------------------------------------|
|                    SWIPED LEFT                |
|  +----------------------------------+---+|
|  | 4.7                           <--| X ||
|  | Yada yada hi dharmasya        <--| D ||
|  | Chapter 4                     <--| E ||
|  +----------------------------------+ L +|
|  ----------------------------------------|
|  | 9.22                              > | |
|  | Ananyash chintayanto mam            | |
|  ----------------------------------------|
|                                          |
+------------------------------------------+

[DEL] = Delete action revealed on swipe
```

### Empty State

```
+------------------------------------------+
|########## RED APPBAR ####################|
|=  <back      Bookmarks                  =|
+------------------------------------------+
|                                          |
|                                          |
|                                          |
|                                          |
|                 #ICON                    |
|              (bookmark)                  |
|                                          |
|         No bookmarks yet                 |
|                                          |
|    Tap the bookmark icon on any          |
|    sloka to save it here.                |
|                                          |
|                                          |
|                                          |
+------------------------------------------+
```

---

## Screen 9: Language Selection

Choose translation language.

```
+------------------------------------------+
|########## RED APPBAR ####################|
|=                                        =|
|=  <back      Language                   =|
|=                                        =|
+------------------------------------------+
|                                          |
|  ----------------------------------------|
|  | English                         [x] | |
|  ----------------------------------------|
|  | Russian (Русский)               [ ] | |
|  ----------------------------------------|
|  | Hindi (हिंदी)                    [ ] | |
|  ----------------------------------------|
|  | Spanish (Español)               [ ] | |
|  ----------------------------------------|
|  | German (Deutsch)                [ ] | |
|  ----------------------------------------|
|  | French (Français)               [ ] | |
|  ----------------------------------------|
|                                          |
+------------------------------------------+

[x] = Selected (with red checkmark)
[ ] = Not selected
```

---

## Tablet Layouts (sw720dp)

### Tablet: Contents + Chapter (Master-Detail)

```
+--------------------------------------------------------------------------------+
|########################## RED APPBAR #FF5252 ##################################|
|=                                                                              =|
|=        Contents                                    Chapter 2         #bkmrk  =|
|=                                                    Sankhya Yoga              =|
+--------------------------------------------------------------------------------+
|                                   |                                            |
|  CHAPTERS (Master)                |  SLOKAS (Detail)                           |
|                                   |                                            |
|  +-----------------------------+  |  +--------------------------------------+  |
|  | " Quote of the day...       |  |  | 2.1                              > |  |
|  +-----------------------------+  |  | Sanjaya uvaca                      |  |
|                                   |  +--------------------------------------+  |
|  +-----------------------------+  |  | 2.2                           #bk  |  |
|  | Chapter 1                 > |  |  | Kutah tva kashmalam idam           |  |
|  | Arjuna Vishada Yoga         |  |  +--------------------------------------+  |
|  +-----------------------------+  |  | 2.3                              > |  |
|  | Chapter 2               [*] |  |  | Klaibyam ma sma gamah              |  |
|  | Sankhya Yoga                |  |  +--------------------------------------+  |
|  +-----------------------------+  |  | 2.4                              > |  |
|  | Chapter 3                 > |  |  | Arjuna uvaca                       |  |
|  | Karma Yoga                  |  |  +--------------------------------------+  |
|  +-----------------------------+  |  |                                    |  |
|  | Chapter 4                 > |  |  |              ...                   |  |
|  | Jnana Yoga                  |  |  |                                    |  |
|  +-----------------------------+  |  +--------------------------------------+  |
|  |          ...                |  |  | 2.72                          #bk |  |
|  +-----------------------------+  |  | Esha brahmi sthitih                |  |
|  | Chapter 18                > |  |  +--------------------------------------+  |
|  | Moksha Sanyasa Yoga         |  |                                            |
|  +-----------------------------+  |                                            |
|                                   |                                            |
+--------------------------------------------------------------------------------+

[*] = Currently selected chapter (highlighted)
```

### Tablet: Chapter + Sloka Detail

```
+--------------------------------------------------------------------------------+
|########################## RED APPBAR #FF5252 ##################################|
|=                                                                              =|
|=  <back   Chapter 2                                  Sloka 2.47       #bkmrk  =|
|=          Sankhya Yoga                                                        =|
+--------------------------------------------------------------------------------+
|                                   |                                            |
|  SLOKAS (Master)                  |  SLOKA DETAIL (Detail)                     |
|                                   |                                            |
|  +-----------------------------+  |  [< Previous]              [Next >]        |
|  | 2.45                      > |  |                                            |
|  | Traigunya vishaya veda      |  |              2.47                          |
|  +-----------------------------+  |        Karmanye Vadhikaraste               |
|  | 2.46                      > |  |                                            |
|  | Yavan artha udapane         |  |  ----------------------------------------  |
|  +-----------------------------+  |                                            |
|  | 2.47                    [*] |  |  SANSKRIT                                  |
|  | Karmanye vadhikaraste       |  |                                            |
|  +-----------------------------+  |      कर्मण्येवाधिकारस्ते मा फलेषु            |
|  | 2.48                      > |  |      कदाचन। मा कर्मफलहेतुर्भूः              |
|  | Yoga sthah kuru karmani     |  |                                            |
|  +-----------------------------+  |  ----------------------------------------  |
|  | 2.49                      > |  |                                            |
|  | Durena hy avaram karma      |  |  TRANSLATION                               |
|  +-----------------------------+  |                                            |
|  | 2.50                      > |  |  You have a right to perform your          |
|  | Buddhi yukto jahatiha       |  |  prescribed duties, but you are not        |
|  +-----------------------------+  |  entitled to the fruits...                 |
|  |          ...                |  |                                            |
|  +-----------------------------+  |  ----------------------------------------  |
|                                   |                                            |
|                                   |  NOTE                                      |
|                                   |  +--------------------------------------+  |
|                                   |  | Personal note here...               |  |
|                                   |  +--------------------------------------+  |
|                                   |         [    Save Note    ]                |
|                                   |                                            |
+--------------------------------------------------------------------------------+
|############################### AUDIO PLAYER BAR ###############################|
|                                                                                |
|      (*)Sanskrit  ( )Translation         #play  [========>    ]  2:34  #auto   |
|                                                                                |
+--------------------------------------------------------------------------------+
```

### Tablet (Landscape): Chapters + Verse Grid + Sloka Detail

Master-detail with verse chips in the left pane: **mockups and chip legend** are maintained in [`../vdd-verse-grid/02-visual.md`](../vdd-verse-grid/02-visual.md). UVGF semantics: [`../vdd-verse-grid/03-specifications.md`](../vdd-verse-grid/03-specifications.md).

### Tablet (Landscape): Bookmarks + Sloka Detail (Split)

```
+--------------------------------------------------------------------------------+
|########################## RED APPBAR #FF5252 ##################################|
|=  <back   Закладки                               #srch  #cmt  #bk             =|
+--------------------------------------------------------------------------------+
|  BOOKMARKS (Master)                      |  SLOKA DETAIL (Detail)             |
|  4.13  Йога обретения духовного знания   |                4.13                  |
|  4.16  Йога обретения духовного знания   |  Sanskrit / word-by-word...         |
|  4.18  Йога обретения духовного знания   |  [ Ru ] [ En SM ] [ En SP ]...      |
|  4.26  Йога обретения духовного знания   |  Commentary blocks...                |
|  4.30  Йога обретения духовного знания   |                                      |
|  ...                                     |                                      |
+--------------------------------------------------------------------------------+
```

---

## Navigation Flow

### Main Flow Diagram

```
                                    +-------------+
                                    |   SPLASH    |
                                    | (loading)   |
                                    +------+------+
                                           |
                              First launch? |
                         +--------YES-------+-------NO--------+
                         |                                    |
                         v                                    v
                  +-------------+                      +-------------+
                  | ONBOARDING  |                      |  CONTENTS   |
                  | (3 pages)   |------- Done -------->|   (main)    |
                  +-------------+                      +------+------+
                                                              |
                    +------------+------------+---------------+---------------+
                    |            |            |               |               |
                    v            v            v               v               v
             +----------+  +---------+  +-----------+  +----------+   +----------+
             | SETTINGS |  | SEARCH  |  | BOOKMARKS |  | CHAPTER  |   |  QUOTE   |
             +----+-----+  +----+----+  +-----+-----+  +----+-----+   +----------+
                  |             |             |             |
                  v             |             |             v
           +----------+        |             |       +----------+
           | LANGUAGE |        |             |       |  SLOKA   |
           +----------+        +-------------+------>|  DETAIL  |
                                                     +----+-----+
                                                          |
                                               +----------+----------+
                                               |          |          |
                                               v          v          v
                                          [Previous]  [Audio]   [Next]
                                                      Player
```

### Screen Transitions

| From | To | Trigger | Animation |
|------|-----|---------|-----------|
| Splash | Onboarding | First launch complete | Fade |
| Splash | Contents | Data loaded | Fade |
| Onboarding | Contents | Done button | Slide left |
| Contents | Chapter | Tap chapter row | Slide left |
| Contents | Settings | Tap settings icon | Slide left |
| Contents | Search | Tap search icon | Circular reveal |
| Contents | Bookmarks | Tap bookmark icon | Slide up (modal) |
| Chapter | Sloka Detail | Tap sloka row | Slide left |
| Sloka Detail | Sloka Detail | Tap Previous/Next | Slide left/right |
| Settings | Language | Tap language row | Slide left |
| Search | Sloka Detail | Tap result | Slide left |
| Bookmarks | Sloka Detail | Tap bookmark | Slide left |

---

## Component States

### Audio Player States

```
Not Downloaded:        Downloading:           Ready:
+----------------+     +----------------+     +----------------+
| #download      |     | [====>  ] 45%  |     | #play          |
+----------------+     +----------------+     +----------------+

Playing:               Paused:
+----------------+     +----------------+
| #pause [====>] |     | #play  [====>] |
+----------------+     +----------------+
```

### Bookmark Button States

```
Not Bookmarked:        Bookmarked:
    +---+                  +---+
    | # |  (outline)       | # |  (filled red)
    +---+                  +---+
```

### Toggle Switch States

```
OFF:                   ON:
+----------+           +----------+
|     [  ] |           |     [==] |  (red accent)
+----------+           +----------+
```

---

## Notes

- All AppBars use red background (#FF5252) with white text
- Tablet layouts use 40/60 split ratio
- Audio player bar is persistent on Sloka screens
- Search uses white AppBar to contrast with circular reveal
- Quote of the day is optional (shown when available)
- StatusBar color matches AppBar (red for most, white for search)

---

## Approval

- [x] Reviewed by: Anton
- [x] Approved on: 2026-04-30
- [x] Notes: All screens and tablet layouts approved
