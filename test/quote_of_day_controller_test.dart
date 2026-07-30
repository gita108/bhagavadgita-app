import 'package:bhagavadgita_book/app/quote/quote_of_day_controller.dart';
import 'package:bhagavadgita_book/data/remote/dto/quote_dto.dart';
import 'package:bhagavadgita_book/data/remote/legacy_api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeApiClient extends LegacyApiClient {
  _FakeApiClient(this._respond);

  final Future<QuoteDto?> Function() _respond;
  int callCount = 0;

  @override
  Future<QuoteDto?> getQuote() async {
    callCount++;
    return _respond();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'refreshIfStale fetches once and serves cache on later same-day calls',
    () async {
      SharedPreferences.setMockInitialValues(const {});
      final api = _FakeApiClient(
        () async => const QuoteDto(text: 'Hello', author: 'Krishna'),
      );
      final controller = QuoteOfDayController(apiClient: api);

      await controller.refreshIfStale();
      expect(controller.value?.text, 'Hello');
      expect(controller.value?.author, 'Krishna');
      expect(api.callCount, 1);

      await controller.refreshIfStale();
      expect(api.callCount, 1, reason: 'should serve cache, not refetch');
    },
  );

  test('forceRefresh always refetches regardless of cache freshness', () async {
    SharedPreferences.setMockInitialValues(const {});
    final api = _FakeApiClient(
      () async => const QuoteDto(text: 'Hello', author: 'Krishna'),
    );
    final controller = QuoteOfDayController(apiClient: api);

    await controller.refreshIfStale();
    await controller.forceRefresh();
    expect(api.callCount, 2);
  });

  test('fetch failure leaves value null without throwing', () async {
    SharedPreferences.setMockInitialValues(const {});
    final api = _FakeApiClient(() async => throw Exception('network down'));
    final controller = QuoteOfDayController(apiClient: api);

    await controller.refreshIfStale();
    expect(controller.value, isNull);
  });

  test('a response missing text/author is not cached', () async {
    SharedPreferences.setMockInitialValues(const {});
    final api = _FakeApiClient(
      () async => const QuoteDto(text: null, author: null),
    );
    final controller = QuoteOfDayController(apiClient: api);

    await controller.refreshIfStale();
    expect(controller.value, isNull);
  });
}
