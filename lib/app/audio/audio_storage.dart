import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'audio_track.dart';

class AudioStorage {
  const AudioStorage();

  Future<Directory> _audioRoot() async {
    final dir = await getApplicationDocumentsDirectory();
    return Directory(p.join(dir.path, 'audio'));
  }

  Future<Directory> trackDir(AudioTrack track) async {
    final root = await _audioRoot();
    final name = switch (track) {
      AudioTrack.sanskrit => 'sanskrit',
      AudioTrack.translation => 'ru',
    };
    final dir = Directory(p.join(root.path, name));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  String chapterFileName(AudioTrack track, int chapterId) {
    final suffix = switch (track) {
      AudioTrack.sanskrit => 'sanskrit',
      AudioTrack.translation => 'ru',
    };
    return 'chapter_${chapterId}_$suffix.mp3';
  }

  Future<File> chapterFile(AudioTrack track, int chapterId) async {
    final dir = await trackDir(track);
    return File(p.join(dir.path, chapterFileName(track, chapterId)));
  }

  Future<Uri?> chapterLocalUriIfExists(AudioTrack track, int chapterId) async {
    final file = await chapterFile(track, chapterId);
    if (await file.exists()) return file.uri;
    return null;
  }
}

const AudioStorage audioStorage = AudioStorage();

