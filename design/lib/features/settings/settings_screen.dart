import 'package:flutter/material.dart';

import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_text.dart';
import '../../ui/widgets/section_label.dart';
import 'reader_settings.dart';
import 'language_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray5,
      appBar: AppBar(title: const Text('Settings')),
      body: ValueListenableBuilder<ReaderSettings>(
        valueListenable: readerSettings,
        builder: (_, s, __) => ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const SectionLabel('Display'),
            _ToggleTile(
              label: 'Show Sanskrit',
              value: s.showSanskrit,
              onChanged: (v) => readerSettings.update(s.copyWith(showSanskrit: v)),
            ),
            _ToggleTile(
              label: 'Show Transcription',
              value: s.showTranscription,
              onChanged: (v) => readerSettings.update(s.copyWith(showTranscription: v)),
            ),
            _ToggleTile(
              label: 'Show Translation',
              value: s.showTranslation,
              onChanged: (v) => readerSettings.update(s.copyWith(showTranslation: v)),
            ),
            _ToggleTile(
              label: 'Show Vocabulary',
              value: s.showVocabulary,
              onChanged: (v) => readerSettings.update(s.copyWith(showVocabulary: v)),
            ),
            _ToggleTile(
              label: 'Show Commentary',
              value: s.showCommentary,
              onChanged: (v) => readerSettings.update(s.copyWith(showCommentary: v)),
            ),

            const SectionLabel('Audio'),
            _AudioDownloadTile(
              label: 'Sanskrit Audio',
              size: '150 MB',
              value: s.downloadSanskritAudio,
              progress: s.downloadSanskritAudio ? 0.67 : null,
              onChanged: (v) =>
                  readerSettings.update(s.copyWith(downloadSanskritAudio: v)),
            ),
            _AudioDownloadTile(
              label: 'Translation Audio',
              size: '200 MB',
              value: s.downloadTranslationAudio,
              progress: null,
              onChanged: (v) =>
                  readerSettings.update(s.copyWith(downloadTranslationAudio: v)),
            ),
            _ToggleTile(
              label: 'Auto-play Next',
              value: s.autoPlayNext,
              onChanged: (v) => readerSettings.update(s.copyWith(autoPlayNext: v)),
            ),

            const SectionLabel('Language'),
            _NavTile(
              label: 'Translation Language',
              trailing: 'English',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LanguageScreen()),
              ),
            ),

            const SectionLabel('Books & Commentaries'),
            const _BadgeTile(
              initials: 'SP',
              label: 'Srila Prabhupada',
              enabled: true,
            ),
            const _BadgeTile(
              initials: 'BG',
              label: 'Bhaktivedanta',
              enabled: true,
            ),
            const _BadgeTile(
              initials: 'VS',
              label: 'Visvanatha',
              enabled: false,
            ),

            const SectionLabel('Notifications'),
            _ToggleTile(
              label: 'Quote of the Day',
              value: s.quoteOfTheDayEnabled,
              onChanged: (v) =>
                  readerSettings.update(s.copyWith(quoteOfTheDayEnabled: v)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.gray4)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
      child: child,
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    return _Tile(
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppText.body())),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.label, required this.trailing, required this.onTap});
  final String label;
  final String trailing;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: _Tile(
        child: Row(
          children: [
            Expanded(child: Text(label, style: AppText.body())),
            Text(trailing, style: AppText.caption()),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: AppColors.gray3, size: 20),
          ],
        ),
      ),
    );
  }
}

class _AudioDownloadTile extends StatelessWidget {
  const _AudioDownloadTile({
    required this.label,
    required this.size,
    required this.value,
    required this.progress,
    required this.onChanged,
  });
  final String label;
  final String size;
  final bool value;
  final double? progress;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _Tile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppText.body()),
                    Text(size, style: AppText.caption()),
                  ],
                ),
              ),
              Switch(value: value, onChanged: onChanged),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text('${(progress! * 100).round()}%',
                    style: AppText.caption().copyWith(color: AppColors.red1)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({
    required this.initials,
    required this.label,
    required this.enabled,
  });
  final String initials;
  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return _Tile(
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white,
              border: Border.all(color: AppColors.red1, width: 1.5),
            ),
            child: Text(initials,
                style: AppText.label().copyWith(
                  color: AppColors.red1,
                  fontSize: 11,
                )),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: AppText.body())),
          Switch(value: enabled, onChanged: (_) {}),
        ],
      ),
    );
  }
}
