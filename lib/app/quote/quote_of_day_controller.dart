import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/remote/dto/quote_dto.dart';
import '../../data/remote/legacy_api_client.dart';

/// Fetches and caches the "Quote of the Day", refetched at most once per
/// calendar day. Mirrors the `ValueNotifier` + `shared_preferences` pattern
/// used by the other app-lifetime controllers (e.g. `AppOnboardingController`).
///
/// Replaces the previous pseudo-random local-verse substitute on Contents —
/// this calls the legacy API's `getQuote()`, which existed but was unused.
class QuoteOfDayController extends ValueNotifier<QuoteDto?> {
  QuoteOfDayController({LegacyApiClient? apiClient})
    : _api = apiClient ?? LegacyApiClient(),
      super(null) {
    _loadCached();
  }

  static const _keyText = 'quote.text';
  static const _keyAuthor = 'quote.author';
  static const _keyFetchedDateIso = 'quote.fetchedDateIso';

  final LegacyApiClient _api;

  Future<void> _loadCached() async {
    final prefs = await SharedPreferences.getInstance();
    final text = prefs.getString(_keyText);
    final author = prefs.getString(_keyAuthor);
    if (text != null && author != null) {
      value = QuoteDto(text: text, author: author);
    }
  }

  bool _isStale(String? fetchedDateIso) {
    final fetched = fetchedDateIso == null
        ? null
        : DateTime.tryParse(fetchedDateIso);
    if (fetched == null) return true;
    final now = DateTime.now();
    return fetched.year != now.year ||
        fetched.month != now.month ||
        fetched.day != now.day;
  }

  /// Fetches a fresh quote only if the cached one is missing or from a
  /// previous calendar day; otherwise a no-op. Call once from Splash's
  /// bootstrap-success path.
  Future<void> refreshIfStale() async {
    final prefs = await SharedPreferences.getInstance();
    if (!_isStale(prefs.getString(_keyFetchedDateIso))) return;
    await _fetchAndCache(prefs);
  }

  /// Unconditional refetch, for a retry affordance if one is ever added.
  Future<void> forceRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    await _fetchAndCache(prefs);
  }

  Future<void> _fetchAndCache(SharedPreferences prefs) async {
    try {
      final quote = await _api.getQuote();
      final text = quote?.text;
      final author = quote?.author;
      if (text == null || author == null) {
        // Nothing usable came back — leave any existing cached value as-is,
        // matching legacy's "optional section, only shown if present" rule.
        return;
      }
      value = QuoteDto(text: text, author: author);
      await prefs.setString(_keyText, text);
      await prefs.setString(_keyAuthor, author);
      await prefs.setString(
        _keyFetchedDateIso,
        DateTime.now().toIso8601String(),
      );
    } catch (_) {
      // Network/parse failure: silently keep whatever's cached (or null).
      // No error state per legacy's optional-section behavior.
    }
  }
}

final QuoteOfDayController quoteOfDayController = QuoteOfDayController();
