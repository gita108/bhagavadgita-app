import 'package:flutter/material.dart';

import '../../data/mock_content.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_text.dart';
import 'reader_settings.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray5,
      appBar: AppBar(title: const Text('Language')),
      body: ValueListenableBuilder<ReaderSettings>(
        valueListenable: readerSettings,
        builder: (_, s, __) => ListView.builder(
          itemCount: MockContent.languages.length,
          itemBuilder: (context, i) {
            final lang = MockContent.languages[i];
            final selected = lang.code == s.languageCode;
            return InkWell(
              onTap: () {
                readerSettings.update(s.copyWith(languageCode: lang.code));
                Navigator.of(context).pop();
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  border: Border(
                    bottom: BorderSide(color: AppColors.gray4),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(lang.name, style: AppText.body()),
                          if (lang.native != lang.name)
                            Text(lang.native, style: AppText.caption()),
                        ],
                      ),
                    ),
                    Icon(
                      selected ? Icons.check : null,
                      color: AppColors.red1,
                      size: 22,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
