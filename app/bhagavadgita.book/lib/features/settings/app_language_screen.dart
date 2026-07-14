import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import 'app_language_controller.dart';

class AppLanguageScreen extends StatelessWidget {
  const AppLanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsAppLanguageChooseTitle)),
      body: ValueListenableBuilder<AppLanguageSettings>(
        valueListenable: appLanguageController,
        builder: (context, settings, _) {
          final selected = settings.effectiveLocale?.languageCode;
          return RadioGroup<String?>(
            groupValue: selected,
            onChanged: (v) {
              if (v == null) {
                appLanguageController.setSystem();
              } else {
                appLanguageController.setExplicit(v);
              }
            },
            child: ListView(
              children: [
                RadioListTile<String?>(
                  title: Text(l10n.settingsAppLanguageSystemDefault),
                  value: null,
                ),
                for (final locale in AppLanguageController.supported)
                  RadioListTile<String?>(
                    title: Text(_labelFor(context, locale.languageCode)),
                    value: locale.languageCode,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _labelFor(BuildContext context, String code) {
    final l10n = context.l10n;
    return switch (code) {
      'en' => l10n.languageName_en,
      'ru' => l10n.languageName_ru,
      'de' => l10n.languageName_de,
      'spa' => l10n.languageName_spa,
      _ => code,
    };
  }
}

