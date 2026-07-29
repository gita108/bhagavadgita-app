import 'package:flutter/material.dart';

import '../../../app/audio/audio_controller.dart';
import '../../../app/audio/audio_state.dart';
import '../../../ui/theme/app_colors.dart';
import '../../../ui/theme/app_text.dart';
import '../../../app/audio/audio_track.dart';

class AudioPlayerBarWithController extends StatelessWidget {
  const AudioPlayerBarWithController({
    super.key,
    required this.controller,
    required this.autoPlay,
    required this.onToggleAutoPlay,
  });

  final AudioController controller;
  final bool autoPlay;
  final ValueChanged<bool> onToggleAutoPlay;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final AudioState s = controller.state;
        return AudioPlayerBar(
          track: s.track,
          autoPlay: autoPlay,
          isPlaying: s.isPlaying,
          positionLabel: formatDuration(s.position),
          durationLabel: formatDuration(s.duration),
          progress: s.progress,
          onPlayPause: () => controller.togglePlayPause(),
          onSelectTrack: (t) => controller.setTrack(t),
          onToggleAutoPlay: onToggleAutoPlay,
          onSeek: controller.seekToFraction,
          enabled: s.activeSource.isPlayable,
          title: s.activeSource.label ?? 'Sanskrit',
        );
      },
    );
  }
}

class AudioPlayerBar extends StatelessWidget {
  const AudioPlayerBar({
    super.key,
    this.track = AudioTrack.sanskrit,
    this.isPlaying = false,
    this.positionLabel = '0:00',
    this.durationLabel = '0:00',
    this.progress = 0,
    this.onPlayPause,
    this.onSelectTrack,
    this.onToggleAutoPlay,
    this.autoPlay = false,
    this.onSeek,
    this.enabled = true,
    required this.title,
  });

  final AudioTrack track;
  final bool isPlaying;
  final String positionLabel;
  final String durationLabel;
  final double progress; // 0..1
  final String title;

  final VoidCallback? onPlayPause;
  final ValueChanged<AudioTrack>? onSelectTrack;
  final ValueChanged<bool>? onToggleAutoPlay;
  final bool autoPlay;
  final ValueChanged<double>? onSeek;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Material(
        elevation: 8,
        color: AppColors.white,
        child: Opacity(
          opacity: enabled ? 1 : 0.55,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SeekBar(
                enabled: enabled,
                progress: progress,
                onSeek: onSeek,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.gray4)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: enabled ? onPlayPause : null,
                      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                      color: AppColors.red1,
                      iconSize: 32,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppText.label().copyWith(color: AppColors.gray1),
                          ),
                          Text(
                            '$positionLabel / $durationLabel',
                            style: AppText.caption().copyWith(
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _TrackToggle(
                      track: track,
                      onSelectTrack: onSelectTrack,
                      enabled: enabled,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: (!enabled || onToggleAutoPlay == null)
                          ? null
                          : () => onToggleAutoPlay!(!autoPlay),
                      icon: Icon(
                        autoPlay ? Icons.repeat_one : Icons.repeat,
                        size: 20,
                      ),
                      color: autoPlay ? AppColors.red1 : AppColors.gray2,
                      tooltip: 'Auto-play Next',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeekBar extends StatelessWidget {
  const _SeekBar({
    required this.enabled,
    required this.progress,
    required this.onSeek,
  });

  final bool enabled;
  final double progress;
  final ValueChanged<double>? onSeek;

  @override
  Widget build(BuildContext context) {
    final p = progress.clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (!enabled || onSeek == null)
              ? null
              : (d) {
                  final x = d.localPosition.dx.clamp(0.0, constraints.maxWidth);
                  onSeek!(constraints.maxWidth <= 0 ? 0 : (x / constraints.maxWidth));
                },
          onHorizontalDragUpdate: (!enabled || onSeek == null)
              ? null
              : (d) {
                  final x = d.localPosition.dx.clamp(0.0, constraints.maxWidth);
                  onSeek!(constraints.maxWidth <= 0 ? 0 : (x / constraints.maxWidth));
                },
          child: LinearProgressIndicator(
            value: p,
            minHeight: 4,
            backgroundColor: AppColors.gray4,
            valueColor: const AlwaysStoppedAnimation(AppColors.red1),
          ),
        );
      },
    );
  }
}

class _TrackToggle extends StatelessWidget {
  const _TrackToggle({
    required this.track,
    required this.onSelectTrack,
    required this.enabled,
  });

  final AudioTrack track;
  final ValueChanged<AudioTrack>? onSelectTrack;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray5,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TrackToggleButton(
            label: 'S',
            selected: track == AudioTrack.sanskrit,
            onPressed: (!enabled || onSelectTrack == null)
                ? null
                : () => onSelectTrack!(AudioTrack.sanskrit),
          ),
          _TrackToggleButton(
            label: 'T',
            selected: track == AudioTrack.translation,
            onPressed: (!enabled || onSelectTrack == null)
                ? null
                : () => onSelectTrack!(AudioTrack.translation),
          ),
        ],
      ),
    );
  }
}

class _TrackToggleButton extends StatelessWidget {
  const _TrackToggleButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.red1 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: AppText.label().copyWith(
            color: selected ? AppColors.white : AppColors.gray2,
          ),
        ),
      ),
    );
  }
}
