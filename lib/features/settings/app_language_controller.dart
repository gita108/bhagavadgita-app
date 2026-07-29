import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguageMode { system, explicit }

class AppLanguageSettings {
  const AppLanguageSettings.system() : mode = AppLanguageMode.system, code = null;

  const AppLanguageSettings.explicit(this.code) : mode = AppLanguageMode.explicit;

  final AppLanguageMode mode;
  final String? code;

  Locale? get effectiveLocale {
    if (mode == AppLanguageMode.system) return null;
    final c = code;
    if (c == null || c.isEmpty) return null;
    return Locale(c);
  }
}

class AppLanguageController extends ValueNotifier<AppLanguageSettings> {
  AppLanguageController() : super(const AppLanguageSettings.system()) {
    _load();
  }

  static const _keyMode = 'app_language.mode';
  static const _keyCode = 'app_language.code';

  static const supported = <Locale>[Locale('en'), Locale('ru')];

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final modeStr = prefs.getString(_keyMode);
    final code = prefs.getString(_keyCode);

    final mode =
        modeStr == 'explicit' ? AppLanguageMode.explicit : AppLanguageMode.system;

    final next =
        mode == AppLanguageMode.explicit ? AppLanguageSettings.explicit(code) : const AppLanguageSettings.system();

    final effective = next.effectiveLocale;
    if (effective != null && !supported.any((l) => l.languageCode == effective.languageCode)) {
      value = const AppLanguageSettings.system();
      await prefs.setString(_keyMode, 'system');
      await prefs.remove(_keyCode);
      return;
    }

    value = next;
  }

  Future<void> setSystem() async {
    value = const AppLanguageSettings.system();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMode, 'system');
    await prefs.remove(_keyCode);
  }

  Future<void> setExplicit(String code) async {
    value = AppLanguageSettings.explicit(code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMode, 'explicit');
    await prefs.setString(_keyCode, code);
  }
}

final AppLanguageController appLanguageController = AppLanguageController();

