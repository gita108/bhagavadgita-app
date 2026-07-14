# Specifications: Add "Share" Button Functionality

## Proposed Approach
1. **Dependency:** Add `share_plus` to `pubspec.yaml` to handle cross-platform sharing.
2. **Architecture:**
   - Implement a `ShareService` to generate the correct URL based on context (Chapter, Verse, Search).
   - Inject `ShareService` into relevant UI components.
3. **UI Integration:**
   - Create a reusable `ShareButton` widget.
   - Integrate `ShareButton` into existing app bar actions or floating action menus across:
     - `ReaderScreen`
     - `ChapterListScreen`
     - Search results view.
4. **URL Schema:**
   - Production URL base: `https://bhagavadgita.book/`
   - Parameters:
     - `chapter`: [1-18]
     - `verse`: [1-N]
     - `query`: [search_string] (optional)
   - Example: `https://bhagavadgita.book/?chapter=2&verse=47`

## Data Model Updates
- N/A

## Interface Definitions
```dart
abstract class ShareService {
  Future<void> shareVerse({required int chapter, required int verse});
  Future<void> shareChapter({required int chapter});
  Future<void> shareCustom(String path, Map<String, String> queryParameters);
}
```

## Edge Cases
- No network: `share_plus` handles sharing of text/URL which doesn't require network immediately (OS level).
- Deep linking: Needs verification that the web version supports parsing these URL arguments.
