import 'package:flutter/material.dart';

import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_text.dart';

enum AudioTrack { sanskrit, translation }

enum AudioPlayState { ready, playing, paused, downloading }

class AudioPlayerBar extends StatefulWidget {
  const AudioPlayerBar({
    super.key,
    this.duration = const Duration(minutes: 3, seconds: 42),
  });

  final Duration duration;

  @override
  State<AudioPlayerBar> createState() => _AudioPlayerBarState();
}

class _AudioPlayerBarState extends State<AudioPlayerBar> {
  AudioTrack _track = AudioTrack.sanskrit;
  AudioPlayState _state = AudioPlayState.ready;
  bool _autoPlay = false;
  double _progress = 0.32;

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString();
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final position = widget.duration * _progress;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.gray4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black20,
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _TrackChip(
                    label: 'Sanskrit',
                    selected: _track == AudioTrack.sanskrit,
                    onTap: () => setState(() => _track = AudioTrack.sanskrit),
                  ),
                  const SizedBox(width: 8),
                  _TrackChip(
                    label: 'Translation',
                    selected: _track == AudioTrack.translation,
                    onTap: () =>
                        setState(() => _track = AudioTrack.translation),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _autoPlay = !_autoPlay),
                    child: Row(
                      children: [
                        Icon(
                          _autoPlay
                              ? Icons.repeat_on_rounded
                              : Icons.repeat_rounded,
                          size: 18,
                          color: _autoPlay
                              ? AppColors.red1
                              : AppColors.gray2,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Auto-play',
                          style: AppText.caption().copyWith(
                            color: _autoPlay
                                ? AppColors.red1
                                : AppColors.gray2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _PlayButton(
                    state: _state,
                    onTap: () {
                      setState(() {
                        _state = _state == AudioPlayState.playing
                            ? AudioPlayState.paused
                            : AudioPlayState.playing;
                      });
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 3,
                            activeTrackColor: AppColors.red1,
                            inactiveTrackColor: AppColors.gray4,
                            thumbColor: AppColors.red1,
                            overlayColor:
                                AppColors.red1.withValues(alpha: 0.15),
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 14,
                            ),
                          ),
                          child: Slider(
                            value: _progress,
                            onChanged: (v) => setState(() => _progress = v),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_format(position),
                                  style: AppText.caption()),
                              Text(_format(widget.duration),
                                  style: AppText.caption()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrackChip extends StatelessWidget {
  const _TrackChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.red1 : AppColors.gray5,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: selected ? AppColors.red1 : AppColors.gray3,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 14,
              color: selected ? AppColors.white : AppColors.gray2,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppText.caption().copyWith(
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.white : AppColors.gray1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.state, required this.onTap});

  final AudioPlayState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.red1,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x33FF5252),
              blurRadius: 14,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          state == AudioPlayState.playing ? Icons.pause : Icons.play_arrow,
          color: AppColors.white,
          size: 26,
        ),
      ),
    );
  }
}
