import 'package:flutter/material.dart';

import '../../../ui/theme/app_colors.dart';
import '../../../ui/theme/app_text.dart';
import '../../../app/audio/audio_controller.dart';
import '../../../app/audio/audio_state.dart';

class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({
    super.key,
    required this.controller,
    required this.slokaName,
  });

  final AudioController controller;
  final String slokaName;

  double _progress(AudioState state) {
    if (state.duration.inMilliseconds == 0) return 0;
    return state.position.inMilliseconds / state.duration.inMilliseconds;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.gray4)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        top: false,
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final state = controller.state;
            final progress = _progress(state);
            return Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(slokaName, style: AppText.caption().copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.gray4,
                        color: AppColors.red1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: Icon(
                    state.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: AppColors.red1,
                  ),
                  onPressed: () {
                    if (state.isPlaying) {
                      controller.pause();
                    } else {
                      controller.play();
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
