## 1. Replace display name string

- [x] 1.1 In `android/app/src/main/AndroidManifest.xml`, change `android:label="compprice"` on the `<application>` element to `android:label="Сравни цену"`.
- [x] 1.2 In `ios/Runner/Info.plist`, change the value under the `CFBundleDisplayName` key from `Compprice` to `Сравни цену`. Leave `CFBundleName` (`compprice`) untouched.
- [x] 1.3 In `lib/main.dart`, change the `MaterialApp` `title:` argument from `'CompPrice'` to `'Сравни цену'`.
- [x] 1.4 In `lib/main.dart`, change the home screen `AppBar` title `Text('CompPrice')` to `Text('Сравни цену')`.
- [x] 1.5 Confirm no other user-facing label still reads `CompPrice` / `Compprice` (a quick `grep -RIn "CompPrice\|Compprice" lib android/app/src/main ios/Runner` should return no display-label hits — class names, package paths, and the lowercase technical identifier `compprice` in `pubspec.yaml`, `CFBundleName`, and the Kotlin package are explicitly out of scope and may remain).

## 2. Install Android launcher icons

- [x] 2.1 Copy `AppIcons/android/mipmap-mdpi/icon.png` to `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` (overwrite the existing file).
- [x] 2.2 Copy `AppIcons/android/mipmap-hdpi/icon.png` to `android/app/src/main/res/mipmap-hdpi/ic_launcher.png` (overwrite).
- [x] 2.3 Copy `AppIcons/android/mipmap-xhdpi/icon.png` to `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` (overwrite).
- [x] 2.4 Copy `AppIcons/android/mipmap-xxhdpi/icon.png` to `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` (overwrite).
- [x] 2.5 Copy `AppIcons/android/mipmap-xxxhdpi/icon.png` to `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` (overwrite).
- [x] 2.6 Do not modify `AndroidManifest.xml`'s `android:icon` attribute — it already points at `@mipmap/ic_launcher`, which the new files now back.

## 3. Install iOS launcher icons

Copy from `AppIcons/Assets.xcassets/AppIcon.appiconset/` (source, named by pixel size) to `ios/Runner/Assets.xcassets/AppIcon.appiconset/` (destination, named per `Contents.json`). Overwrite each existing destination file. Do not edit `Contents.json`.

- [x] 3.1 `20.png` → `Icon-App-20x20@1x.png`
- [x] 3.2 `40.png` → `Icon-App-20x20@2x.png` AND `Icon-App-40x40@1x.png` (two copies of the same source)
- [x] 3.3 `60.png` → `Icon-App-20x20@3x.png`
- [x] 3.4 `29.png` → `Icon-App-29x29@1x.png`
- [x] 3.5 `58.png` → `Icon-App-29x29@2x.png`
- [x] 3.6 `87.png` → `Icon-App-29x29@3x.png`
- [x] 3.7 `80.png` → `Icon-App-40x40@2x.png`
- [x] 3.8 `120.png` → `Icon-App-40x40@3x.png` AND `Icon-App-60x60@2x.png` (two copies)
- [x] 3.9 `180.png` → `Icon-App-60x60@3x.png`
- [x] 3.10 `76.png` → `Icon-App-76x76@1x.png`
- [x] 3.11 `152.png` → `Icon-App-76x76@2x.png`
- [x] 3.12 `167.png` → `Icon-App-83.5x83.5@2x.png`
- [x] 3.13 `1024.png` → `Icon-App-1024x1024@1x.png`
- [x] 3.14 Verify that every `filename` entry in `ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json` now exists on disk.

## 4. Verification

- [x] 4.1 Run `flutter clean && flutter pub get` so old build artifacts and any cached icon resources are discarded.
- [x] 4.2 Build for Android (`flutter build apk` or `flutter run` on an Android target) on a clean install: confirm the launcher icon and the home-screen label both reflect the new artwork and the name `Сравни цену`. Uninstall any prior copy first to avoid stale icon caches.
- [x] 4.3 Build for iOS (`flutter build ios --no-codesign` or `flutter run` on an iOS Simulator) on a clean install: confirm the home-screen icon and the label `Сравни цену` are correct. Reset the Simulator's home screen if the cached icon persists.
- [x] 4.4 Open the app and confirm the in-app `AppBar` title reads `Сравни цену`.
- [x] 4.5 Run `grep -RIn "CompPrice\|Compprice" lib android/app/src/main ios/Runner` and confirm no remaining user-facing label hits (class/identifier hits in Dart class names like `CompPriceApp`, the Kotlin package path, and `CFBundleName` / `pubspec.yaml` `name:` are acceptable — they are technical identifiers, not display labels).
