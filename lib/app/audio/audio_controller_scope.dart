import 'package:flutter/widgets.dart';

import 'audio_controller.dart';

class AudioControllerScope extends InheritedNotifier<AudioController> {
  const AudioControllerScope({
    super.key,
    required AudioController controller,
    required super.child,
  }) : super(notifier: controller);

  static AudioController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AudioControllerScope>();
    assert(scope != null, 'AudioControllerScope not found in widget tree.');
    return scope!.notifier!;
  }
}

