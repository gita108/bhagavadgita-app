import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'audio_storage.dart';
import 'audio_track.dart';
import 'audioveda_client.dart';

@immutable
class AudioDownloadState {
  const AudioDownloadState({
    required this.isDownloading,
    required this.track,
    required this.currentLabel,
    required this.progress,
    required this.errorMessage,
  });

  const AudioDownloadState.idle()
      : isDownloading = false,
        track = null,
        currentLabel = null,
        progress = null,
        errorMessage = null;

  final bool isDownloading;
  final AudioTrack? track;
  final String? currentLabel;
  final double? progress; // 0..1, null if unknown
  final String? errorMessage;

  AudioDownloadState copyWith({
    bool? isDownloading,
    AudioTrack? Function()? track,
    String? Function()? currentLabel,
    double? Function()? progress,
    String? Function()? errorMessage,
  }) {
    return AudioDownloadState(
      isDownloading: isDownloading ?? this.isDownloading,
      track: track == null ? this.track : track(),
      currentLabel: currentLabel == null ? this.currentLabel : currentLabel(),
      progress: progress == null ? this.progress : progress(),
      errorMessage: errorMessage == null ? this.errorMessage : errorMessage(),
    );
  }
}

class AudioDownloadController extends ValueNotifier<AudioDownloadState> {
  AudioDownloadController({AudioVedaClient? client})
      : _client = client ?? AudioVedaClient(),
        super(const AudioDownloadState.idle());

  final AudioVedaClient _client;
  Completer<void>? _active;

  bool get isBusy => _active != null;

  Future<void> downloadAllChapters(AudioTrack track) async {
    if (_active != null) return _active!.future;
    final c = Completer<void>();
    _active = c;
    value = value.copyWith(
      isDownloading: true,
      track: () => track,
      currentLabel: () => null,
      progress: () => null,
      errorMessage: () => null,
    );

    try {
      final creds = AudioVedaCredentials(
        username: dotenv.env['AUDIOVEDA_USERNAME'] ?? '',
        password: dotenv.env['AUDIOVEDA_PASSWORD'] ?? '',
      );

      final pageUrl = _pageUrlForTrack(track);
      if (pageUrl == null) {
        throw StateError('AUDIOVEDA_*_URL is not configured.');
      }

      final mp3s = await _client.listMp3Urls(pageUrl, creds: creds);
      if (mp3s.isEmpty) {
        throw StateError('No mp3 links found at $pageUrl');
      }

      for (var i = 0; i < mp3s.length; i++) {
        final url = mp3s[i];
        final chapterId = _inferChapterId(url) ?? (i + 1);
        final outFile = await audioStorage.chapterFile(track, chapterId);
        final label = outFile.path.split(Platform.pathSeparator).last;

        value = value.copyWith(
          currentLabel: () => label,
          progress: () => (i / mp3s.length).clamp(0.0, 1.0),
        );

        await _client.downloadToFile(
          url,
          creds: creds,
          outFile: outFile,
          onProgress: (received, total) {
            if (total <= 0) return;
            final itemProgress = received / total;
            final overall = ((i + itemProgress) / mp3s.length).clamp(0.0, 1.0);
            value = value.copyWith(progress: () => overall);
          },
        );
      }

      value = value.copyWith(
        isDownloading: false,
        currentLabel: () => null,
        progress: () => 1.0,
      );
    } catch (e) {
      value = value.copyWith(
        isDownloading: false,
        currentLabel: () => null,
        errorMessage: () => e.toString(),
      );
      rethrow;
    } finally {
      c.complete();
      _active = null;
    }
  }

  Uri? _pageUrlForTrack(AudioTrack track) {
    final key = switch (track) {
      AudioTrack.translation => 'AUDIOVEDA_RUSSIAN_URL',
      AudioTrack.sanskrit => 'AUDIOVEDA_SANSKRIT_URL',
    };
    final raw = (dotenv.env[key] ?? '').trim();
    if (raw.isEmpty) return null;
    return Uri.tryParse(raw);
  }

  int? _inferChapterId(Uri url) {
    final s = url.toString();
    final m = RegExp(r'chapter_(\d+)_', caseSensitive: false).firstMatch(s);
    if (m != null) return int.tryParse(m.group(1) ?? '');
    final m2 = RegExp(r'chapter[^\d]?(\d+)', caseSensitive: false).firstMatch(s);
    if (m2 != null) return int.tryParse(m2.group(1) ?? '');
    return null;
  }
}

final AudioDownloadController audioDownloadController = AudioDownloadController();

