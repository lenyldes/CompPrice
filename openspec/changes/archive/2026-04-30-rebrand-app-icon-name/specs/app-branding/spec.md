## ADDED Requirements

### Requirement: Display name is "Сравни цену" on all user-visible surfaces

The system SHALL present the literal Cyrillic string `Сравни цену` as the application's display name on every user-visible surface, including the device home screen / app drawer label, the in-app top app bar, and the OS app switcher / settings entry.

The system SHALL set this name in:

- `android/app/src/main/AndroidManifest.xml` via the `android:label` attribute on the `<application>` element.
- `ios/Runner/Info.plist` via the `CFBundleDisplayName` key.
- `lib/main.dart` via both the `MaterialApp.title` argument and the home screen's `AppBar` title text.

The system SHALL NOT continue to use the placeholder strings `CompPrice`, `Compprice`, or `compprice` anywhere a user-visible app name is rendered. (The lowercase identifier `compprice` MAY remain as a non-display value: the Dart package name in `pubspec.yaml`, the iOS `CFBundleName`, and the Kotlin/Android application package — these are technical identifiers, not display labels, and are out of scope.)

#### Scenario: Display name on Android home screen

- **WHEN** the app is freshly installed on an Android device or emulator and the user views the launcher / app drawer
- **THEN** the label under the app icon reads `Сравни цену`

#### Scenario: Display name on iOS home screen

- **WHEN** the app is freshly installed on an iOS device or simulator and the user views the home screen
- **THEN** the label under the app icon reads `Сравни цену`

#### Scenario: Display name in the in-app AppBar

- **WHEN** the user opens the app and the home screen renders
- **THEN** the top `AppBar` displays the title `Сравни цену`

#### Scenario: No leftover placeholder strings in user-facing config

- **WHEN** a reviewer searches `android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist` (the `CFBundleDisplayName` value), and `lib/main.dart`
- **THEN** none of those locations contain the substrings `CompPrice`, `Compprice`, or `compprice` as a user-visible label value

### Requirement: Launcher icon uses the supplied `AppIcons/` artwork

The system SHALL ship the launcher icon artwork stored under the repository's `AppIcons/` directory, replacing the Flutter-default launcher icon on both platforms.

For Android, the system SHALL place a PNG sourced from `AppIcons/android/mipmap-<density>/icon.png` into `android/app/src/main/res/mipmap-<density>/ic_launcher.png` for each of the densities `mdpi`, `hdpi`, `xhdpi`, `xxhdpi`, `xxxhdpi`.

For iOS, the system SHALL populate `ios/Runner/Assets.xcassets/AppIcon.appiconset/` with PNGs sourced from `AppIcons/Assets.xcassets/AppIcon.appiconset/<pixelsize>.png` such that every filename listed in the existing `Contents.json` is backed by artwork at the correct pixel dimensions.

#### Scenario: Android launcher icon visible after install

- **WHEN** the app is freshly installed on an Android device or emulator
- **THEN** the icon shown in the launcher and app drawer is the artwork from `AppIcons/android/mipmap-*/icon.png` (not the Flutter-default blue "F" icon)

#### Scenario: iOS launcher icon visible after install

- **WHEN** the app is freshly installed on an iOS device or simulator
- **THEN** the icon shown on the home screen is the artwork from `AppIcons/Assets.xcassets/AppIcon.appiconset/` (not the Flutter-default icon)

#### Scenario: All Contents.json slots are populated

- **WHEN** a reviewer inspects `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- **THEN** every `filename` entry referenced by `Contents.json` exists on disk and has the pixel dimensions implied by its size×scale slot

#### Scenario: All Android density buckets are populated

- **WHEN** a reviewer inspects `android/app/src/main/res/`
- **THEN** each of `mipmap-mdpi`, `mipmap-hdpi`, `mipmap-xhdpi`, `mipmap-xxhdpi`, and `mipmap-xxxhdpi` contains an `ic_launcher.png` matching the corresponding source PNG in `AppIcons/android/mipmap-<density>/icon.png`
