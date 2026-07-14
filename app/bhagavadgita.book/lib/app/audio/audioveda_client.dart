import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

class AudioVedaCredentials {
  const AudioVedaCredentials({
    required this.username,
    required this.password,
  });

  final String username;
  final String password;

  bool get isUsable => username.isNotEmpty && password.isNotEmpty;
}

class AudioVedaClient {
  AudioVedaClient({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Options _options(AudioVedaCredentials creds) {
    if (!creds.isUsable) return Options();
    final basic = base64Encode(utf8.encode('${creds.username}:${creds.password}'));
    return Options(headers: {'Authorization': 'Basic $basic'});
  }

  Future<List<Uri>> listMp3Urls(Uri page, {required AudioVedaCredentials creds}) async {
    final res = await _dio.get<Object?>(
      page.toString(),
      options: _options(creds).copyWith(
        responseType: ResponseType.plain,
        followRedirects: true,
      ),
    );

    final body = res.data?.toString() ?? '';
    if (body.isEmpty) return const [];

    // Try JSON first (some endpoints might return structured data).
    final json = _tryParseJson(body);
    if (json != null) {
      final urls = <Uri>{};
      _extractUrlsFromJson(json, urls);
      return urls.where((u) => u.path.toLowerCase().endsWith('.mp3')).toList()
        ..sort((a, b) => a.toString().compareTo(b.toString()));
    }

    // HTML/text: extract href/src URLs ending with .mp3
    final urls = <Uri>{};
    final mp3Regex = RegExp(
      "(?:(?:href|src)=['\\\"])([^'\\\" ]+\\.mp3)(?:['\\\"])",
      caseSensitive: false,
    );
    for (final m in mp3Regex.allMatches(body)) {
      final raw = m.group(1);
      if (raw == null || raw.trim().isEmpty) continue;
      final u = Uri.tryParse(raw.trim());
      if (u == null) continue;
      urls.add(u.hasScheme ? u : page.resolveUri(u));
    }

    final list = urls.toList()
      ..sort((a, b) => a.toString().compareTo(b.toString()));
    return list;
  }

  Future<void> downloadToFile(
    Uri url, {
    required AudioVedaCredentials creds,
    required File outFile,
    void Function(int received, int total)? onProgress,
  }) async {
    await outFile.parent.create(recursive: true);
    final tmp = File('${outFile.path}.part');
    if (await tmp.exists()) {
      await tmp.delete();
    }

    await _dio.download(
      url.toString(),
      tmp.path,
      options: _options(creds).copyWith(followRedirects: true),
      onReceiveProgress: onProgress,
      deleteOnError: true,
    );

    if (await outFile.exists()) {
      await outFile.delete();
    }
    await tmp.rename(outFile.path);
  }

  Object? _tryParseJson(String s) {
    try {
      return jsonDecode(s);
    } catch (_) {
      return null;
    }
  }

  void _extractUrlsFromJson(Object? json, Set<Uri> out) {
    if (json == null) return;
    if (json is String) {
      final u = Uri.tryParse(json);
      if (u != null) out.add(u);
      return;
    }
    if (json is List) {
      for (final v in json) {
        _extractUrlsFromJson(v, out);
      }
      return;
    }
    if (json is Map) {
      for (final v in json.values) {
        _extractUrlsFromJson(v, out);
      }
    }
  }
}

