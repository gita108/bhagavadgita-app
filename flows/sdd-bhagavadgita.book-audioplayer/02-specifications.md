# Specifications: vdd-bhagavadgita.book-audioplayer

## 1. Audio Manifest Architecture
To eliminate reliance on regex parsing of file names and arbitrary API ordering, we will implement an `AudioManifest` service.

### 1.1 Manifest Schema (`assets/data/audio_manifest.json`)
The manifest will be versioned and include hashes for integrity checking.
```json
{
  "version": "1.0.0",
  "last_updated": "2026-04-30T00:00:00Z",
  "entries": [
    {
      "chapter": 1,
      "language": "ru",
      "url": "asset://assets/audio/ru/chapter_1_ru.mp3",
      "checksum": "sha256:..."
    },
    {
      "chapter": 2,
      "language": "sanskrit",
      "url": "https://audioveda.com/...",
      "checksum": "sha256:..."
    }
  ]
}
```

### 1.2 Data Flow
1. **Bootstrap**: App loads default `audio_manifest.json` from assets.
2. **Synchronization**: On startup (or manual trigger), `AudioVedaClient` fetches the latest remote manifest (if available) to detect new/updated audio versions.
3. **Persistence**: `AudioStorage` maintains the active manifest in local cache.

## 2. Refined Domain Model
We will extend `audio_track.dart` to be more robust.

```dart
enum AudioTrackLanguage { sanskrit, russian }

class AudioTrackMetadata {
  final int chapter;
  final int? shloka; // Optional: null if chapter-level track
  final AudioTrackLanguage language;
  final String remoteUrl;
  final String localPath;
}
```

## 3. UI/State Interface
- **State Machine**: Replace simple boolean flags with a formal `PlaybackState` (idle, buffering, playing, paused, error, download_required).
- **Service Layer**: Decouple `AudioController` from raw `Dio` calls. Use a Repository pattern: `AudioRepository` handles data fetching, `AudioPlayerService` handles playback (via `just_audio` or `audioplayers` package).

## 4. Integration with Existing Controllers
- `AudioDownloadController`: Refactored to consume the `AudioManifest` to queue downloads instead of iterating over raw URL lists.
- `AudiovedaClient`: Extended to support fetching manifest metadata headers.

---

## Technical Decisions
- **Manifest-first**: No audio interaction without a resolved manifest entry.
- **Integrity**: Every downloaded file must be verified against the manifest checksum.
- **Separation**: Decouple network discovery (client) from file management (storage) and state orchestration (controller).
