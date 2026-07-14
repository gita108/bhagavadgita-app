import 'package:flutter/material.dart';

import '../../data/mock_content.dart';
import '../../data/models.dart';
import '../../data/user_data_store.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_text.dart';
import '../../ui/widgets/audio_player_bar.dart';
import '../../ui/widgets/author_badge.dart';
import '../../ui/widgets/section_label.dart';
import '../settings/reader_settings.dart';

class SlokaScreen extends StatefulWidget {
  const SlokaScreen({super.key, required this.slokaId});
  final int slokaId;

  @override
  State<SlokaScreen> createState() => _SlokaScreenState();
}

class _SlokaScreenState extends State<SlokaScreen> {
  late int _slokaId;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _slokaId = widget.slokaId;
    _noteController.text = UserDataStore.instance.noteFor(_slokaId);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Sloka get _sloka {
    for (final c in MockContent.chapters) {
      for (final s in c.slokas) {
        if (s.id == _slokaId) return s;
      }
    }
    return MockContent.chapters.first.slokas.first;
  }

  void _navigate(int delta) {
    final s = _sloka;
    final chapter = MockContent.chapters[s.chapterId - 1];
    final newPos = s.position + delta;
    if (newPos < 1 || newPos > chapter.slokas.length) return;
    setState(() {
      _slokaId = chapter.slokas[newPos - 1].id;
      _noteController.text = UserDataStore.instance.noteFor(_slokaId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sloka = _sloka;
    final chapter = MockContent.chapters[sloka.chapterId - 1];
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Sloka'),
        actions: [
          ValueListenableBuilder<Set<int>>(
            valueListenable: UserDataStore.instance.bookmarks,
            builder: (_, bms, __) {
              final on = bms.contains(sloka.id);
              return IconButton(
                onPressed: () =>
                    UserDataStore.instance.toggleBookmark(sloka.id),
                icon: Icon(on ? Icons.bookmark : Icons.bookmark_border),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ValueListenableBuilder<ReaderSettings>(
        valueListenable: readerSettings,
        builder: (_, s, __) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            _PrevNext(
              hasPrev: sloka.position > 1,
              hasNext: sloka.position < chapter.slokas.length,
              onPrev: () => _navigate(-1),
              onNext: () => _navigate(1),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(sloka.name,
                  style: AppText.label().copyWith(
                    color: AppColors.red1,
                    fontSize: 14,
                  )),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                sloka.transcription.split('\n').first,
                textAlign: TextAlign.center,
                style: AppText.heading(),
              ),
            ),
            const SizedBox(height: 28),
            if (s.showSanskrit) _SectionBlock(
              label: 'Sanskrit',
              child: Text(
                sloka.sanskrit,
                textAlign: TextAlign.center,
                style: AppText.sanskrit(),
              ),
            ),
            if (s.showTranscription) _SectionBlock(
              label: 'Transcription',
              child: Text(sloka.transcription, style: AppText.bodyItalic()),
            ),
            if (s.showVocabulary && sloka.vocabulary.isNotEmpty) _SectionBlock(
              label: 'Vocabulary',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final v in sloka.vocabulary)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 130,
                            child: Text(v.token,
                                style: AppText.body().copyWith(
                                  fontWeight: FontWeight.w700,
                                )),
                          ),
                          Expanded(
                            child: Text(v.meaning, style: AppText.body()),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (s.showTranslation) _SectionBlock(
              label: 'Translation',
              child: Text(
                sloka.translation,
                style: AppText.body().copyWith(
                  fontSize: 17,
                  height: 1.55,
                ),
              ),
            ),
            if (s.showCommentary && sloka.commentaries.isNotEmpty)
              _SectionBlock(
                label: 'Commentary',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final c in sloka.commentaries) ...[
                      Row(
                        children: [
                          AuthorBadge(initials: c.initials),
                          const SizedBox(width: 10),
                          Text(c.author,
                              style: AppText.body().copyWith(
                                fontWeight: FontWeight.w700,
                              )),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(c.text, style: AppText.body()),
                      const SizedBox(height: 18),
                    ],
                  ],
                ),
              ),
            const SectionLabel('Note', padding: EdgeInsets.only(top: 12, bottom: 8)),
            TextField(
              controller: _noteController,
              maxLines: 4,
              minLines: 3,
              decoration: const InputDecoration(
                hintText: 'Write your personal note here…',
              ),
              onChanged: (v) =>
                  UserDataStore.instance.saveNote(sloka.id, v),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () =>
                  UserDataStore.instance.saveNote(sloka.id, _noteController.text),
              child: const Text('Save Note'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AudioPlayerBar(),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(label, padding: const EdgeInsets.only(top: 0, bottom: 10)),
        child,
        const SizedBox(height: 20),
        const HairlineDivider(),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _PrevNext extends StatelessWidget {
  const _PrevNext({
    required this.hasPrev,
    required this.hasNext,
    required this.onPrev,
    required this.onNext,
  });
  final bool hasPrev;
  final bool hasNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: hasPrev ? onPrev : null,
            icon: const Icon(Icons.chevron_left, size: 18),
            label: const Text('Previous'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: hasNext ? onNext : null,
            icon: const Icon(Icons.chevron_right, size: 18),
            label: const Text('Next'),
          ),
        ),
      ],
    );
  }
}
