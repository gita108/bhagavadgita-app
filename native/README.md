# Native (non-Flutter) apps

This folder contains the original, pre-Flutter native implementations of the Bhagavad Gita book app, copied
verbatim from `legacy/` so they can be built standalone from within this repo — independent of the Dart/Flutter
project that lives at the root of `apps/bhagavadgita-app`.

They share no code, assets, or database with the Flutter app's `lib/` directory, and they are not part of
Flutter's build: `flutter build`/`flutter analyze`/`flutter pub get` never look inside this folder.

## `android/`

Verbatim copy of `legacy/bhagavadgita-mobile-java-v2012` (Java, Gradle). Self-contained — build it directly:

```sh
cd native/android
./gradlew assembleDebug
```

## `ios/`

Verbatim copy of `legacy/bhagavadgita-mobile-swift-v2012` (Swift, Xcode). Open and build directly:

```sh
open native/ios/Gita.xcodeproj
```

## Relationship to the Flutter app

- Both `android/` and `ios/` here already ship under application id / bundle id `com.ethnoapp.bgita`, matching
  the Flutter app's `android/app/build.gradle.kts` (`applicationId`) and `ios/Runner.xcodeproj`
  (`PRODUCT_BUNDLE_IDENTIFIER`) — both build variants can plausibly ship as updates to the same store listings.
- macOS has no native counterpart here — the legacy Swift project is iOS-only. macOS continues to build from
  Dart/Flutter, same as web/linux/windows.
- CI/CD wiring to build and ship either variant (Flutter-embedded vs. this native code) is tracked separately and
  is not set up yet.
