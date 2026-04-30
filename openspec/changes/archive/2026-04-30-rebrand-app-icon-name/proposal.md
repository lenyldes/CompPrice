## Why

The app currently ships with placeholder Flutter branding ("CompPrice"/"compprice" labels and the default Flutter launcher icon). Before distribution we need a recognizable Russian-language identity ("Сравни цену") and the prepared launcher icon assets in place across Android and iOS.

## What Changes

- Replace the user-facing app display name with `Сравни цену` everywhere it currently reads "CompPrice" / "Compprice" / "compprice" as a display label:
  - Android `AndroidManifest.xml` `android:label`
  - iOS `Info.plist` `CFBundleDisplayName`
  - Flutter `MaterialApp.title` and the home `AppBar` title in `lib/main.dart`
- Install the launcher icon assets from `AppIcons/` into the platform-native locations:
  - `AppIcons/android/mipmap-*` → `android/app/src/main/res/mipmap-*`
  - `AppIcons/Assets.xcassets/AppIcon.appiconset` → `ios/Runner/Assets.xcassets/AppIcon.appiconset`
- Leave non-user-facing identifiers unchanged: the Dart package name in `pubspec.yaml` (`compprice`), the Kotlin application package (`com.compprice.compprice`), and the iOS `CFBundleName` — these are technical identifiers, not display names, and changing them is out of scope and would break the build / store identity.

## Capabilities

### New Capabilities
- `app-branding`: User-visible product identity — launcher icon assets and the displayed app name across Android, iOS, and the in-app chrome.

### Modified Capabilities
<!-- None: app-shell describes Flutter setup, theming, and single-screen layout; it does not constrain the displayed app name or launcher icon, so no requirement changes there. -->

## Impact

- Code: `android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`, `lib/main.dart`.
- Assets: new files under `android/app/src/main/res/mipmap-*` and `ios/Runner/Assets.xcassets/AppIcon.appiconset/` (overwriting the Flutter-default launcher icons).
- No dependency, API, or build-system changes.
- Source for icon assets is `AppIcons/` at the repository root (already on disk).
