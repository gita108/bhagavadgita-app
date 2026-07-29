import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppOnboardingController extends ValueNotifier<bool> {
  AppOnboardingController() : super(false) {
    _load();
  }

  static const _key = 'onboarding_shown';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    value = prefs.getBool(_key) ?? false;
  }

  Future<void> markShown() async {
    value = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}

final AppOnboardingController appOnboardingController = AppOnboardingController();
