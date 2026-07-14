import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

import '../../app/audio/audio_controller_scope.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_text.dart';
import '../../data/local/app_database.dart';
import '../reader/sloka_screen.dart';
import '../settings/audio_settings_controller.dart';
import '../shared/widgets/audio_player_bar.dart';

class TabletChapterSlokaScaffold extends StatefulWidget {
  const TabletChapterSlokaScaffold({
    super.key,
    required this.db,
    required this.chapterId,
    required this.chapterTitle,
    required this.chapterName,
    required this.initialSlokaId,
  });

  final AppDatabase db;
  final int chapterId;
  final String chapterTitle;
  final String chapterName;
  final int initialSlokaId;

  @override
  State<TabletChapterSlokaScaffold> createState() =>
      _TabletChapterSlokaScaffoldState();
}

class _TabletChapterSlokaScaffoldState extends State<TabletChapterSlokaScaffold> {
  late int _selectedSlokaId;

  @override
  void initState() {
    super.initState();
    _selectedSlokaId = widget.initialSlokaId;
  }

  @override
  Widget build(BuildContext context) {
    final slokasQuery =
        (widget.db.select(widget.db.slokas)
              ..where((t) => t.chapterId.equals(widget.chapterId)))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chapterTitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.chapterName,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.92),
                        ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<Sloka?>(
                stream: (widget.db.select(widget.db.slokas)
                      ..where((t) => t.id.equals(_selectedSlokaId))
                      ..limit(1))
                    .watchSingleOrNull(),
                builder: (context, snap) {
                  final name = snap.data?.name ?? 'Sloka';
                  return Text(
                    name,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: audioSettingsController,
        builder: (context, _) {
          final audioSettings = audioSettingsController.value;
          return AudioPlayerBarWithController(
            controller: AudioControllerScope.of(context),
            autoPlay: audioSettings.autoPlayNext,
            onToggleAutoPlay: (v) => audioSettingsController.update(
              audioSettings.copyWith(autoPlayNext: v),
            ),
          );
        },
      ),
      body: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: StreamBuilder<List<Sloka>>(
              stream: slokasQuery.watch(),
              builder: (context, snap) {
                final slokas = snap.data ?? const [];
                if (snap.connectionState == ConnectionState.waiting &&
                    slokas.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (slokas.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 48,
                          color: AppColors.gray3,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No slokas yet',
                          style: AppText.body().copyWith(color: AppColors.gray2),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: slokas.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final s = slokas[index];
                    final selected = s.id == _selectedSlokaId;
                    return Container(
                      decoration: BoxDecoration(
                        color: selected ? AppColors.red1.withValues(alpha: 0.06) : null,
                        border: selected
                            ? const Border(left: BorderSide(color: AppColors.red1, width: 3))
                            : null,
                      ),
                      child: ListTile(
                        selected: selected,
                        selectedColor: AppColors.red1,
                        title: Text(s.name),
                        subtitle: Text(
                          s.translation ?? s.slokaText ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => setState(() => _selectedSlokaId = s.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: SlokaScreen(
              db: widget.db,
              slokaId: _selectedSlokaId,
              chapterId: widget.chapterId,
              embedded: true,
            ),
          ),
        ],
      ),
    );
  }
}

