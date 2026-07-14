# Specifications: bhagavadgita.book CI/CD (GitHub Actions build)

> Version: 1.0  
> Status: DRAFT  
> Last Updated: 2026-04-29  
> Requirements: `flows/sdd-bhagavadgita.book-cicd/01-requirements.md`

## Overview

Добавляем GitHub Actions workflow, который:

- На **Ubuntu** собирает Android **release APK** (с релизной подписью при наличии secrets).
- На **macOS** собирает iOS **release IPA** (codesigning обязателен).
- Загружает артефакты в artifacts run’а.
- Использует кеширование Flutter/Dart и CocoaPods.

## Affected Systems

| System | Impact | Notes |
|--------|--------|------|
| `.github/workflows/` | Create | CI workflows |
| `app/bhagavadgita.book/android/app/build.gradle.kts` | Modify | Release signing via env/secrets (fallback to debug for local/dev) |
| `app/bhagavadgita.book/ios/` | Create | ExportOptions template for `flutter build ipa` |
| `CLAUDE.md` | Modify | Add active SDD flow row |

## Architecture

### Workflow structure

- `build-android` job (ubuntu-latest)
  - checkout
  - setup Java + Flutter
  - `flutter pub get`
  - `flutter analyze` (and tests if present)
  - keystore materialization (optional, from base64 secrets)
  - `flutter build apk --release`
  - upload artifacts

- `build-ios` job (macos-latest)
  - checkout
  - setup Flutter
  - `flutter pub get`
  - install CocoaPods
  - import signing cert to keychain (from base64 `.p12`)
  - install provisioning profile (from base64 `.mobileprovision`)
  - generate `ExportOptions.plist` (from template + env vars)
  - `flutter build ipa --release --export-options-plist=...`
  - upload artifacts

## Interfaces

### GitHub Secrets (required/optional)

#### Android (optional for signed release)

- `ANDROID_KEYSTORE_BASE64`: base64 of `.jks`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

If missing, workflow can still build, but signing will fallback (or fail fast depending on job configuration).

#### iOS (required for `.ipa`)

- `IOS_CERT_P12_BASE64`: base64 of signing certificate `.p12`
- `IOS_CERT_PASSWORD`: password for `.p12`
- `IOS_PROVISIONING_PROFILE_BASE64`: base64 of `.mobileprovision`
- `IOS_TEAM_ID`: Apple Developer Team ID (e.g. `ABCDE12345`)

Optional (can be inferred, but safer explicit):
- `IOS_EXPORT_METHOD`: `app-store` | `ad-hoc` (default `app-store`)
- `IOS_BUNDLE_ID`: if needed to select profile (not always required by export options, but useful as metadata)

### GitHub Workflow Inputs

For `workflow_dispatch`:
- `ios_export_method` (default `app-store`)
- `flutter_channel` (default `stable`)

## Behavior Specifications

### Happy Path

1. Tag push `vX.Y.Z` triggers workflow.
2. Android job builds release APK and uploads artifact.
3. iOS job builds signed IPA and uploads artifact.
4. Artifacts are downloadable from the workflow run.

### Edge Cases

| Case | Trigger | Expected Behavior |
|------|---------|-------------------|
| Missing Android signing secrets | secrets not configured | Build still succeeds using default signing (or produces unsigned artifact); clear warning in logs |
| Missing iOS signing secrets | secrets not configured | iOS job fails with explicit message before attempting build |
| CocoaPods issues | pod repo/lock mismatch | workflow runs `pod install` in `ios/` and relies on `Podfile.lock`; fails with log output |

### Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| Flutter setup fails | incompatible channel/version | fail job with setup output |
| `flutter build ipa` fails | codesigning mismatch | fail with xcodebuild logs; instructions point to secrets |

## Dependencies

- GitHub-hosted runners (ubuntu, macos)
- Flutter toolchain via setup action

## Testing Strategy

- `flutter analyze` on both jobs
- `flutter test` (if tests exist and pass) before build to catch regressions early

## Migration / Rollout

- Initial rollout: enable workflow on manual dispatch + tags only (avoid PR noise).
- Later: optionally add PR workflow building unsigned artifacts for fast feedback.

## Open Design Questions

- [ ] Fail Android build if no signing secrets, or allow debug-signed release APK?
- [ ] Add `.aab` build for Play Store release path?

---

## Approval

- [ ] Reviewed by: [name]
- [ ] Approved on: [date]
- [ ] Notes: [any conditions or clarifications]
