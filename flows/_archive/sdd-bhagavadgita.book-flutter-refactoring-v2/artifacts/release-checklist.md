# Release Checklist v2

## Build and QA

- [x] `flutter test` passes in `app/bhagavadgita.book`
- [x] Smoke run on macOS completed
- [x] Smoke run on Android device/emulator
- [ ] Smoke run on iOS simulator/device (blocked: iOS 26.4 platform not installed in Xcode)
- [ ] Manual regression: splash/bootstrap offline and online
- [ ] Manual regression: chapter -> sloka -> bookmark -> note -> restart
- [ ] Manual regression: search and settings persistence

## Android (Google Play)

- [x] Increment `version` / `buildNumber`
- [x] Build release artifact (`aab`)
- [ ] Verify signing config
- [ ] Upload to Play Console internal track
- [ ] Verify pre-launch report
- [ ] Promote to production

## iOS (App Store Connect)

- [ ] Increment `version` / `buildNumber`
- [ ] Archive and validate in Xcode
- [ ] Upload to App Store Connect
- [ ] Assign build to TestFlight/Internal
- [ ] Complete App Review metadata
- [ ] Submit for review / release

## Publish Controls

- [ ] Product owner explicitly confirms release publishing
- [ ] Credentials/tokens available in current environment
