import 'audio_track.dart';

enum AudioSourceType { none, networkUrl, localFile, asset }

class AudioSourceRef {
  const AudioSourceRef.none()
      : type = AudioSourceType.none,
        uri = null,
        assetPath = null,
        label = null;

  const AudioSourceRef.network(this.uri, {this.label})
      : type = AudioSourceType.networkUrl,
        assetPath = null;

  const AudioSourceRef.file(this.uri, {this.label})
      : type = AudioSourceType.localFile,
        assetPath = null;

  const AudioSourceRef.asset(this.assetPath, {this.label})
      : type = AudioSourceType.asset,
        uri = null;

  final AudioSourceType type;
  final Uri? uri;
  final String? assetPath;
  final String? label;

  bool get isPlayable =>
      type != AudioSourceType.none && (uri != null || assetPath != null);
}

class AudioState {
  const AudioState({
    required this.track,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.sourceSanskrit,
    required this.sourceTranslation,
    required this.errorMessage,
  });

  const AudioState.idle()
      : track = AudioTrack.sanskrit,
        isPlaying = false,
        position = Duration.zero,
        duration = Duration.zero,
        sourceSanskrit = const AudioSourceRef.none(),
        sourceTranslation = const AudioSourceRef.none(),
        errorMessage = null;

  final AudioTrack track;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final AudioSourceRef sourceSanskrit;
  final AudioSourceRef sourceTranslation;
  final String? errorMessage;

  double get progress {
    final d = duration.inMilliseconds;
    if (d <= 0) return 0;
    return (position.inMilliseconds / d).clamp(0.0, 1.0);
  }

  AudioSourceRef get activeSource =>
      track == AudioTrack.sanskrit ? sourceSanskrit : sourceTranslation;

  AudioState copyWith({
    AudioTrack? track,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    AudioSourceRef? sourceSanskrit,
    AudioSourceRef? sourceTranslation,
    String? Function()? errorMessage,
  }) {
    return AudioState(
      track: track ?? this.track,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      sourceSanskrit: sourceSanskrit ?? this.sourceSanskrit,
      sourceTranslation: sourceTranslation ?? this.sourceTranslation,
      errorMessage: errorMessage == null ? this.errorMessage : errorMessage(),
    );
  }
}

