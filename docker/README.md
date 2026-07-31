# CI/CD: three workflows, two Android build images

This app builds and (optionally) publishes in **two variants** per platform:

- **Flutter-embedded** (`android/`, `ios/`) — the Dart/Flutter UI, today's app
- **Native** (`native/android/`, `native/ios/`) — the original pre-Flutter Java/Swift apps, copied
  verbatim (see `flows/sdd-bhagavadgita-app-ios-android/`)

Both ship under the same identity (`com.ethnoapp.bgita`), so only one is ever the actual published
build for a given release — **native is the default** (widest device support, back to older
Android/iOS versions than the Flutter minimum reaches). Flutter is a manual failover, selectable via
`workflow_dispatch` on `release.yml`.

## The three workflows

| Workflow | Trigger | Purpose |
|---|---|---|
| `build.yml` (Native Build) | every push/PR | Fast, **unsigned** verification: `build-android-flutter`, `build-ios-flutter`, `build-ios-native`. No signing secrets needed, no Docker. |
| `docker-build.yml` (Docker Build) | push to `main`, nightly (03:00 UTC), on Release publish | Reproducible, containerized builds: `docker-build-android-flutter`, `docker-build-android-native`. |
| `release.yml` (Release) | version tag push (`v*`), or manual `workflow_dispatch` | Real signing + real `fastlane` store submission, all 4 variant×platform jobs, plus the Windows portable build. |

`build-android-native` is **only** built in `docker-build.yml` — its toolchain (old JDK 8 + Gradle
4.4 + a JCenter mirror) is too slow/fragile to duplicate in the fast push/PR layer. It's the one job
in this whole setup that's expected to stay red until the known gap below is addressed.

## Why not Docker for every platform?

- **iOS** (both variants): no Linux-container iOS toolchain exists at all — must run on a real
  `macos-latest` GitHub-hosted runner.
- **Windows**: same — `flutter build windows` needs an actual Windows host.
- **Flutter-embedded Android / native Android**: these *are* Dockerized (Linux containers can cross-compile
  Android APKs fine) — see `android-flutter-build.Dockerfile` / `android-native-build.Dockerfile`.

## Building locally

```sh
tool/docker-build.sh flutter   # flutter pub get && flutter build apk --release
tool/docker-build.sh native    # gradle --init-script docker/android-native-jcenter-init.gradle -p native/android assembleLiveDebug
```

Pass a trailing command to override the default (e.g. `tool/docker-build.sh native bash` for an
interactive shell inside the image).

**Apple Silicon note**: both images are built/run with `--platform linux/amd64` to match real CI
runners. Under Docker Desktop this works via the VM/Rosetta emulation path — enable *Settings →
General → "Use Rosetta for x86_64/amd64 emulation"* for reasonable performance; without it, or under
plain QEMU, builds are dramatically slower and some Dart/Gradle native-code paths can be flaky (a
release build was observed to crash with a Dart VM assertion failure under emulation on this
machine — not reproduced with a debug build; expected to build fine on real amd64 `ubuntu-latest`
hardware in CI, but this is unconfirmed pending an actual CI run).

## Known gap: `build-android-native` doesn't fully build

`native/android` depends on `com.viewpagerindicator:library:2.4.1`, originally hosted on a
*personal* Bintray repo (`dl.bintray.com/populov/maven`) that was deleted outright when Bintray shut
down in 2021 — unlike the *central* JCenter index, which is still served (frozen, read-only) from
`jcenter.bintray.com` and covers every other old dependency this project needs. A no-source-edit fix
via Gradle dependency substitution was attempted and doesn't work: the app declares this dependency
with the old `@aar` "artifact-only" notation, which bypasses the module dependency graph that
substitution rules operate on. Full details and what a real fix would require are in
`docker/android-native-jcenter-init.gradle`'s header comment.

## Secrets

| Secret | Used by | Optional? |
|---|---|---|
| `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD` | `release-android-flutter`, `release-android-native` | Yes — unsigned build if absent |
| `ANDROID_GOOGLE_SERVICES_JSON_BASE64` | `release-android-native` | Yes — uses the committed `native/android/app/google-services.json` if absent |
| `PLAY_STORE_JSON_KEY` | `fastlane supply` (Play Store upload) | Only needed to actually publish |
| `IOS_CERT_P12_BASE64`, `IOS_CERT_PASSWORD`, `IOS_PROVISIONING_PROFILE_BASE64`, `IOS_TEAM_ID` | `release-ios-flutter`, `release-ios-native` | Yes — unsigned build if absent |

None of these are currently set on this repo. Every signing/publish step degrades gracefully
(unsigned build, no store call) rather than failing the job when its secrets are missing.
