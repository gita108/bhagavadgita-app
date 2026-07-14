# Plan: sdd-bhagavadgita.book-audioplayer

## 1. Phase: Manifest Infrastructure
- **Task 1.1**: Define `AudioManifest` and `AudioManifestEntry` data models in `audio_manifest.dart`.
- **Task 1.2**: Create base `assets/data/audio_manifest.json` with existing Chapter 1 entries.
- **Task 1.3**: Implement `AudioManifestLoader` to read/parse the asset manifest.

## 2. Phase: Repository Refactoring
- **Task 2.1**: Implement `AudioRepository` to act as a data provider (wraps `AudioVedaClient` and `AudioStorage`).
- **Task 2.2**: Integrate manifest-aware logic into `AudioRepository` to resolve URLs and check file existence.

## 3. Phase: Player Engine
- **Task 3.1**: Create `AudioPlayerService` for stateful playback control.
- **Task 3.2**: Implement `PlaybackState` notifier (replacing basic flags).
- **Task 3.3**: Configure `just_audio` (or current) for background audio sessions and interrupt handling.

## 4. Phase: Integration
- **Task 4.1**: Refactor `AudioDownloadController` to query `AudioManifest` for specific chapters instead of regex-based discovery.
- **Task 4.2**: Add checksum verification logic in `AudioRepository`/`AudioStorage` for downloaded files.

## 5. Phase: UI Integration
- **Task 5.1**: Connect `AudioPlayerService` to UI (Mini-player/Full-player).
- **Task 5.2**: Update UI state based on `PlaybackState`.

---

## Task Estimation (Story Points)
- Manifest: 3
- Repository: 5
- Player Engine: 8
- Integration: 5
- UI: 5
- **Total: 26**
