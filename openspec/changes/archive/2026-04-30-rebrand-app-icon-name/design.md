## Context

The app currently displays the placeholder string "CompPrice" / "compprice" / "Compprice" wherever a user-visible app name appears, and ships the default Flutter launcher icon. Final-art icon assets have already been delivered to the repository under `AppIcons/`:

- `AppIcons/android/mipmap-{m,h,xh,xxh,xxxh}dpi/icon.png` — five Android density buckets, single PNG each.
- `AppIcons/Assets.xcassets/AppIcon.appiconset/<pixelsize>.png` — 36 raw PNGs named by pixel size (16, 20, 29, 32, 40, 48, 50, 55, 57, 58, 60, 64, 66, 72, 76, 80, 87, 88, 100, 102, 108, 114, 120, 128, 144, 152, 167, 172, 180, 196, 216, 234, 256, 258, 512, 1024).
- `AppIcons/appstore.png`, `AppIcons/playstore.png` — store-listing artwork (not bundled into the app build).

The existing destinations are:

- Android: `android/app/src/main/res/mipmap-*dpi/ic_launcher.png`, referenced from `AndroidManifest.xml` as `android:icon="@mipmap/ic_launcher"`.
- iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/` with a `Contents.json` that names slots like `Icon-App-20x20@2x.png`, `Icon-App-60x60@3x.png`, etc.

This is a pure asset/string swap. No code logic, no dependencies, no build configuration changes.

## Goals / Non-Goals

**Goals:**
- The launcher icon shown by Android and iOS at install time is the new artwork from `AppIcons/`.
- The app's display label on the home screen, app switcher, settings list, and in-app `AppBar` reads `Сравни цену`.
- Achieve the swap without modifying `AndroidManifest.xml`'s `android:icon` attribute or the iOS `Contents.json` icon manifest — i.e., drop the new bytes into the filenames the platforms already expect.

**Non-Goals:**
- Renaming the Dart package (`pubspec.yaml: name: compprice`), the Kotlin application package (`com.compprice.compprice`), the iOS `CFBundleName`, or the Android `applicationId`. These are technical identifiers, not display names; renaming them would break builds and shift store identity, and no requirement asks for it.
- Localizing the app name per-locale. `Сравни цену` is the single global display name.
- Adaptive icons / monochrome themed icons / Android 13+ themed-icon manifest. Out of scope; only the legacy bitmap launcher icon is being replaced.
- Splash screens, store listing pages, marketing assets beyond the launcher icon.

## Decisions

### Decision 1 — Map icon files to existing destination filenames rather than rewiring manifests

**Choice:** Copy the new PNGs into the exact filenames the platforms already reference (`ic_launcher.png` per density on Android; the named `Icon-App-<size>@<scale>.png` slots on iOS).

**Rationale:** Minimizes diff and risk. Touching `AndroidManifest.xml`'s icon attribute or rewriting `Contents.json` adds surface area for typos and reviewer load with no benefit — the bytes are what matter.

**Alternative considered:** Update `AndroidManifest.xml` to `android:icon="@mipmap/icon"` and copy the source files verbatim. Rejected — extra config change for zero gain.

### Decision 2 — iOS pixel-size → named-slot mapping

The provided iOS assets are named by pixel dimension; the destination `Contents.json` expects per-idiom named files. Map by pixel size:

| Source PNG (pixels) | Destination filename                |
|---------------------|--------------------------------------|
| `20.png`            | `Icon-App-20x20@1x.png`              |
| `40.png`            | `Icon-App-20x20@2x.png`, `Icon-App-40x40@1x.png` |
| `60.png`            | `Icon-App-20x20@3x.png`              |
| `29.png`            | `Icon-App-29x29@1x.png`              |
| `58.png`            | `Icon-App-29x29@2x.png`              |
| `87.png`            | `Icon-App-29x29@3x.png`              |
| `80.png`            | `Icon-App-40x40@2x.png`              |
| `120.png`           | `Icon-App-40x40@3x.png`, `Icon-App-60x60@2x.png` |
| `180.png`           | `Icon-App-60x60@3x.png`              |
| `76.png`            | `Icon-App-76x76@1x.png`              |
| `152.png`           | `Icon-App-76x76@2x.png`              |
| `167.png`           | `Icon-App-83.5x83.5@2x.png`          |
| `1024.png`          | `Icon-App-1024x1024@1x.png`          |

All 13 required sizes exist in `AppIcons/Assets.xcassets/AppIcon.appiconset/`. The other PNGs in that folder (16, 32, 48, 50, 55, 57, 64, 66, 72, 88, 100, 102, 108, 114, 128, 144, 172, 196, 216, 234, 256, 258, 512) are not consumed by Apple's standard iOS app icon set and will be ignored.

**Rationale:** `Contents.json` is the source of truth for which files Xcode bundles; matching its existing names avoids editing it.

### Decision 3 — Cyrillic display name with no Info.plist encoding declaration

**Choice:** Write the literal `Сравни цену` UTF-8 string as the value of `CFBundleDisplayName` in `Info.plist`, the `android:label` in `AndroidManifest.xml`, and the Dart string literals in `lib/main.dart`.

**Rationale:** All three files are already UTF-8; iOS and Android both render Cyrillic display names without any extra `CFBundleDevelopmentRegion`, `<supports-rtl>`, or font configuration. No `strings.xml` localization is needed since the name is a single global value.

**Alternative considered:** Move the Android label into `res/values/strings.xml` and reference it via `@string/app_name`. Rejected as scope creep — current manifest uses an inline label, and the proposal does not call for restructuring resources.

## Risks / Trade-offs

- **Risk:** Stale per-device icon caches on iOS Simulator / Android emulator can make it look like the icon didn't change. **Mitigation:** Verification step does a clean uninstall + reinstall (or `flutter clean`) before checking the home screen.
- **Risk:** Hard-coding `Сравни цену` everywhere makes future locale-specific names a larger change. **Mitigation:** Acceptable — the project has no localization framework today, and adding one is out of scope.
- **Risk:** The non-user-facing `compprice` identifiers (Dart package, Kotlin package, `CFBundleName`) staying behind makes the codebase visually inconsistent with the new brand. **Mitigation:** Documented as a non-goal; renaming them is a separate, larger change that touches every Dart import and the Android signing/store identity.
- **Trade-off:** Skipping `Contents.json` regeneration means the iOS icon set will not include the extra sizes shipped in `AppIcons/` (e.g. 16, 32, 1024 marketing). Acceptable: the App Store marketing icon is a separate upload; the in-app icon set only needs the 13 sizes mapped above.
