import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import 'audio_state.dart';
import 'audio_track.dart';

typedef AudioCompletedCallback = void Function();

class AudioController extends ChangeNotifier {
  AudioController({AudioPlayer? player}) : _player = player ?? AudioPlayer() {
    _subs.add(_player.playerStateStream.listen(_onPlayerState));
    _subs.add(_player.durationStream.listen(_onDuration));
    _subs.add(_player.positionStream.listen(_onPosition));
  }

  final AudioPlayer _player;
  final List<StreamSubscription<Object?>> _subs = [];

  AudioState _state = const AudioState.idle();
  AudioState get state => _state;

  AudioCompletedCallback? onCompleted;
  bool _playWhenSourceBound = false;

  Future<void> disposeAsync() async {
    for (final s in _subs) {
      await s.cancel();
    }
    _subs.clear();
    await _player.dispose();
  }

  @override
  void dispose() {
    // Intentionally not disposing the player here to allow explicit async dispose
    // from the app root. This avoids swallowing dispose errors.
    super.dispose();
  }

  Future<void> setSources({
    required AudioSourceRef sanskrit,
    required AudioSourceRef translation,
  }) async {
    final next = _state.copyWith(
      sourceSanskrit: sanskrit,
      sourceTranslation: translation,
      position: Duration.zero,
      duration: Duration.zero,
      isPlaying: false,
      errorMessage: () => null,
    );
    _setState(next);

    // Preload active track best-effort.
    await _setActiveTrackSource(preloadOnly: true);

    if (_playWhenSourceBound) {
      _playWhenSourceBound = false;
      await play();
    }
  }

  void requestPlayOnNextSourceBind() {
    _playWhenSourceBound = true;
  }

  Future<void> setTrack(AudioTrack track) async {
    if (_state.track == track) return;
    final wasPlaying = _state.isPlaying;
    _setState(_state.copyWith(track: track, errorMessage: () => null));
    await _setActiveTrackSource(preloadOnly: !wasPlaying);
    if (wasPlaying) {
      await play();
    }
  }

  Future<void> play() async {
    final active = _state.activeSource;
    if (!active.isPlayable) return;

    try {
      // Ensure the correct source is loaded before playing.
      await _setActiveTrackSource(preloadOnly: true);
      await _player.play();
      _setState(_state.copyWith(isPlaying: true, errorMessage: () => null));
    } catch (e) {
      _setState(_state.copyWith(isPlaying: false, errorMessage: () => e.toString()));
    }
  }

  Future<void> pause() async {
    await _player.pause();
    _setState(_state.copyWith(isPlaying: false));
  }

  Future<void> togglePlayPause() async {
    if (_state.isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> seekToFraction(double progress) async {
    final d = _state.duration.inMilliseconds;
    if (d <= 0) return;
    final ms = (progress.clamp(0.0, 1.0) * d).round();
    await _player.seek(Duration(milliseconds: ms));
  }

  Future<void> _setActiveTrackSource({required bool preloadOnly}) async {
    final source = _state.activeSource;
    if (!source.isPlayable) {
      await _player.stop();
      return;
    }

    final audioSource = switch (source.type) {
      AudioSourceType.networkUrl => AudioSource.uri(source.uri!),
      AudioSourceType.localFile => AudioSource.uri(source.uri!),
      AudioSourceType.asset => AudioSource.asset(source.assetPath!),
      AudioSourceType.none => null,
    };
    if (audioSource == null) return;

    try {
      await _player.setAudioSource(audioSource, preload: preloadOnly);
    } catch (e) {
      _setState(_state.copyWith(errorMessage: () => e.toString()));
    }
  }

  void _onPlayerState(PlayerState ps) {
    final isPlaying = ps.playing;

    // Detect completed track (similar intent to legacy iOS AudioManager didCompletedTrack).
    if (ps.processingState == ProcessingState.completed) {
      _setState(
        _state.copyWith(
          isPlaying: false,
          position: _state.duration,
        ),
      );
      onCompleted?.call();
      return;
    }

    if (_state.isPlaying != isPlaying) {
      _setState(_state.copyWith(isPlaying: isPlaying));
    }
  }

  void _onDuration(Duration? d) {
    final next = d ?? Duration.zero;
    if (_state.duration != next) {
      _setState(_state.copyWith(duration: next));
    }
  }

  void _onPosition(Duration p) {
    if (_state.position != p) {
      _setState(_state.copyWith(position: p));
    }
  }

  void _setState(AudioState next) {
    _state = next;
    notifyListeners();
  }
}

String formatDuration(Duration d) {
  final totalSeconds = d.inSeconds;
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

