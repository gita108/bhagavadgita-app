import 'package:flutter/foundation.dart';

/// In-memory user-data store. Mirrors `UserDataRepository` from the existing
/// project but without the Drift dependency, so screens can wire up bookmarks
/// and personal notes against a single source of truth during layout work.
class UserDataStore {
  UserDataStore._();
  static final UserDataStore instance = UserDataStore._();

  final ValueNotifier<Set<int>> bookmarks = ValueNotifier(<int>{});
  final ValueNotifier<Map<int, String>> notes = ValueNotifier(<int, String>{});

  bool isBookmarked(int slokaId) => bookmarks.value.contains(slokaId);

  void toggleBookmark(int slokaId) {
    final next = Set<int>.from(bookmarks.value);
    if (!next.add(slokaId)) next.remove(slokaId);
    bookmarks.value = next;
  }

  void removeBookmark(int slokaId) {
    final next = Set<int>.from(bookmarks.value)..remove(slokaId);
    bookmarks.value = next;
  }

  String noteFor(int slokaId) => notes.value[slokaId] ?? '';

  void saveNote(int slokaId, String text) {
    final next = Map<int, String>.from(notes.value);
    if (text.isEmpty) {
      next.remove(slokaId);
    } else {
      next[slokaId] = text;
    }
    notes.value = next;
  }
}
