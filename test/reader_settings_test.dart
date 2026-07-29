import 'package:bhagavadgita_book/features/settings/reader_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('reader settings controller loads and persists values', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'reader_settings.showSanskrit': false,
      'reader_settings.showTranslation': false,
    });

    final controller = ReaderSettingsController();
    await Future<void>.delayed(const Duration(milliseconds: 1));

    expect(controller.value.showSanskrit, isFalse);
    expect(controller.value.showTranslation, isFalse);
    expect(controller.value.showComment, isTrue);

    await controller.update(controller.value.copyWith(showComment: false));
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('reader_settings.showComment'), isFalse);
  });
}
