import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../l10n/gen/app_localizations.dart';
import 'dart:async';

import '../data/local/app_database.dart';
import 'audio/audio_controller.dart';
import 'audio/audio_controller_scope.dart';
import '../ui/theme/app_theme.dart';
import '../features/splash/splash_screen.dart';
import '../features/settings/app_language_controller.dart';

class GitaBookApp extends StatefulWidget {
  const GitaBookApp({super.key});

  @override
  State<GitaBookApp> createState() => _GitaBookAppState();
}

class _GitaBookAppState extends State<GitaBookApp> {
  late final AppDatabase _db;
  late final AudioController _audio;

  @override
  void initState() {
    super.initState();
    _db = AppDatabase();
    _audio = AudioController();
  }

  @override
  void dispose() {
    unawaited(_audio.disposeAsync());
    _db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AudioControllerScope(
      controller: _audio,
      child: ValueListenableBuilder<AppLanguageSettings>(
        valueListenable: appLanguageController,
        builder: (context, settings, _) => MaterialApp(
          title: 'Bhagavad Gita',
          theme: buildAppTheme(),
          locale: settings.effectiveLocale,
          supportedLocales: AppLanguageController.supported,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: SplashScreen(db: _db),
        ),
      ),
    );
  }
}

