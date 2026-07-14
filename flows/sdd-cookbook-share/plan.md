# Plan: Add "Share" Button Functionality

## Task Breakdown

### 1. Project Configuration
- [ ] Add `share_plus` to `app/bhagavadgita.book/pubspec.yaml`.
- [ ] Run `flutter pub get` in `app/bhagavadgita.book/`.

### 2. Service Implementation
- [ ] Create `lib/features/shared/services/share_service.dart`.
- [ ] Implement `ShareService` class following the specification.

### 3. UI Component
- [ ] Create `lib/ui/widgets/share_button.dart` (reusable widget).

### 4. Integration
- [ ] Integrate `ShareButton` into `ReaderScreen` (Verse/Chapter context).
- [ ] Integrate `ShareButton` into `ChapterListScreen` (if applicable).
- [ ] Integrate `ShareButton` into Search result views (if applicable).

### 5. Testing
- [ ] Add basic unit test for URL generation logic.
- [ ] Verify UI integration via manual testing.

## Estimation
- Complexity: Low/Medium
- Total Time: ~4-6 hours

## Dependencies
- `share_plus` package.
