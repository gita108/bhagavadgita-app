import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import 'content_languages_controller.dart';

class ContentLanguagesScreen extends StatelessWidget {
  const ContentLanguagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsContentLanguagesChooseTitle)),
      body: ValueListenableBuilder<ContentLanguagesSettings>(
        valueListenable: contentLanguagesController,
        builder: (context, settings, _) => ListView(
          children: [
            for (final option in ContentLanguagesController.available)
              CheckboxListTile(
                title: Text(_labelFor(context, option)),
                value: settings.selectedCodes.contains(option.code),
                onChanged: (_) async {
                  final ok = await contentLanguagesController.toggle(option.code);
                  if (!ok && context.mounted) {
                    await showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(l10n.settingsContentLanguagesChooseTitle),
                        content: Text(l10n.settingsContentLanguagesAtLeastOne),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(l10n.confirmOk),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  String _labelFor(BuildContext context, ContentLanguageOption option) {
    final l10n = context.l10n;
    return switch (option.code) {
      'en' => l10n.languageName_en,
      'ru' => l10n.languageName_ru,
      'de' => l10n.languageName_de,
      'spa' => l10n.languageName_spa,
      _ => option.code,
    };
  }
}

