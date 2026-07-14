# Requirements: Add "Share" Button Functionality

## User Story
As a user of the Bhagavad Gita application, I want to be able to share the current view (verse, chapter, or custom search result) via a button available on all screens. This button should generate a link to the web version of the application, populated with the necessary URL arguments to restore the same view.

## Acceptance Criteria
1. A "Share" button is visible and accessible on all primary screens (Verse View, Chapter View, Search/Study View).
2. Tapping the "Share" button invokes the system's native share dialog.
3. The shared link points to the production web version (e.g., `https://bhagavadgita.book/...`).
4. The generated URL contains sufficient parameters to allow a user clicking the link to land exactly on the shared content (e.g., `?chapter=X&verse=Y`).
5. The UI remains clean and consistent with existing app aesthetics.

## Constraints & Considerations
- Need to determine the base URL for the web version.
- Must handle parameter serialization for different view types.
- Ensure cross-platform compatibility (iOS/Android/Web).
