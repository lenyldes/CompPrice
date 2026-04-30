## Context

Greenfield project — no existing code beyond an empty repository. The product is a single-screen utility that compares unit prices of products entered as `(price, quantity)` pairs. Target users are shoppers in Russia, so prices are in rubles and decimal input must accept a comma separator. The proposal mandates a Flutter app for Android + iOS with **no third-party dependencies** beyond the Flutter SDK, and a strong preference to keep code in a single `lib/main.dart` unless splitting demonstrably improves clarity.

The feature surface is intentionally tiny (add, list, highlight cheapest, delete), so the technical risk is in choosing the right defaults — locale handling, validation, and rebuild scope — rather than in architecture.

## Goals / Non-Goals

**Goals:**
- Cross-platform mobile build (Android + iOS) from one Dart codebase.
- Zero non-Flutter dependencies in `pubspec.yaml`.
- Minimal, readable code: one screen, one state holder, one model class.
- Correct unit-price math and lowest-price highlighting independent of insertion order.
- Material 3 + `ThemeMode.system` so light/dark follows OS.
- Accept decimal input with both `.` and `,` separators (ru-RU friendly).

**Non-Goals:**
- Persistence (state is lost on app restart).
- Sorting, editing, sharing, currency switching, multi-currency math.
- Web/desktop targets, custom theming beyond Material 3 defaults.
- Automated test coverage beyond the default smoke test scaffolded by `flutter create`.
- Localization framework / `intl` package — single hardcoded ru-RU UI string set is acceptable.

## Decisions

### 1. Flutter over React Native / native
**Choice:** Flutter (stable channel), Dart 3.x, Material 3.
**Why:** Single codebase for Android + iOS with one toolchain; ships its own rendering pipeline so Material 3 looks identical on both platforms; no JS bridge to debug. The proposal already names Flutter, so this is a confirmation rather than an open choice.
**Alternatives considered:**
- *React Native* — would force a JS dependency tree and a second package manager; conflicts with the "no third-party deps" constraint.
- *Native (Kotlin + Swift)* — doubles implementation effort for a one-screen utility.

### 2. State management: plain `setState` in a single `StatefulWidget`
**Choice:** Hold the product list in a `State` object; mutate via `setState`.
**Why:** The entire app is one screen with ≤ tens of items. Provider/Riverpod/Bloc would each be an external dependency and add ceremony that exceeds the problem's complexity. `setState` rebuilds are scoped to the screen widget, which is acceptable at this scale.
**Alternatives considered:**
- *`ValueNotifier` + `ValueListenableBuilder`* — slightly finer rebuild control but no real win for a list of this size; rejected for simplicity.
- *Provider/Riverpod/Bloc* — violate the "no third-party deps" rule.

### 3. File layout: single `lib/main.dart`
**Choice:** Keep `Product` model, the screen widget, and `main()` in one file. Split only if the file exceeds roughly 250–300 lines or a piece becomes obviously reusable.
**Why:** The proposal explicitly asks for minimal code. Premature file splitting hurts readability when there is one screen, one model, and one state holder.
**Alternatives considered:**
- *`lib/main.dart` + `lib/product.dart` + `lib/compare_screen.dart`* — defensible, but adds navigation cost without a corresponding clarity gain at this size.

### 4. Data model: immutable `Product` with `id`, `name`, `price`, `quantity`
**Choice:**
```dart
class Product {
  final String id;        // unique key for ListView (e.g. monotonic counter as string)
  final String name;      // "Product 1", "Product 2", …
  final double price;     // rubles
  final double quantity;  // arbitrary unit, > 0
  double get unitPrice => price / quantity;
}
```
Auto-name uses a monotonic counter that **never decrements on delete** — i.e., deleting "Product 2" then adding a new one yields "Product 4", not "Product 2 again". This avoids name collisions and keeps the user's mental model stable.
**Why an `id` separate from `name`:** `ListView` keys must be stable across reorders; using the display name as a key is fragile if naming rules ever change.

### 5. Lowest-price highlight: computed per build, not stored
**Choice:** During `build`, compute `minUnitPrice = products.map((p) => p.unitPrice).reduce(min)` once and pass it to each row; the row highlights itself if `p.unitPrice == minUnitPrice`.
**Why:** Recomputing on every build is O(n) and trivial at this scale; storing a "best" flag on items would require maintenance on every add/delete and risks going stale. Empty list short-circuits (no highlight).
**Tie-breaking:** If multiple items share the minimum unit price (within float equality), highlight **all** of them. This is the simplest rule and matches user intuition ("these are equally the best deal").

### 6. Decimal input: accept `.` and `,`; reject everything else
**Choice:** Use `TextInputType.numberWithOptions(decimal: true)` plus a `FilteringTextInputFormatter` that allows digits and a single `.` or `,`. On submit, replace `,` with `.` before parsing with `double.tryParse`.
**Why:** Russian keyboards default to `,` as the decimal separator; rejecting it would be hostile UX. Avoiding the `intl` package keeps the dep list at zero.
**Validation rules:**
- `price` must parse to a finite `double` ≥ 0.
- `quantity` must parse to a finite `double` > 0 (zero quantity would divide by zero).
- Empty or invalid input → "Add" button is disabled (preferred) **or** a brief inline error on tap.

### 7. Display rounding
**Choice:** Round unit price to 2 decimals **for display only** using `unitPrice.toStringAsFixed(2)`. Keep the underlying `double` for comparison.
**Why:** Comparing rounded strings would create false ties (e.g., 10.005 vs 10.006 both render as "10.01" but are not equal). Comparing raw doubles preserves correctness; rounding only affects what the user sees.

### 8. Highlight styling
**Choice:** Wrap the cheapest row(s) in a `Container` with a Material 3 tonal background — `colorScheme.tertiaryContainer` (or `secondaryContainer`) — and prepend a subtle leading icon (e.g., `Icons.star` or a "★ best" badge). Avoid hardcoding `Colors.lightGreen` so dark mode stays legible.
**Why:** Material 3 color roles already produce a green-ish accent in the default light scheme and an appropriately desaturated tone in dark mode. Hardcoded `lightGreen` would clash with dark theme.

### 9. Delete UX
**Choice:** Trailing `IconButton(Icons.delete_outline)` per row that removes the item from the list via `setState`. No confirmation dialog (trivially recoverable by re-entering values).
**Alternatives considered:** Swipe-to-dismiss (`Dismissible`) — more idiomatic but adds undo-snackbar expectations; deferred as out-of-scope polish.

## Risks / Trade-offs

- **Floating-point precision in unit-price comparison** → For tie-detection we compare `double`s with `==`, which can miss true ties that differ by ULPs. Mitigation: acceptable for v1 since inputs come from human typing at 2-decimal granularity; revisit only if users report a "best" item not being highlighted when they expect a tie.
- **No persistence** → State is lost on app kill or rotation-induced rebuilds of the root. Mitigation: `State` object survives rotation as long as the widget tree does; explicit persistence is out of scope per the proposal.
- **Single-file growth** → If features creep in, `main.dart` becomes hard to navigate. Mitigation: the 250–300-line rule in Decision 3 triggers a split before the file becomes painful.
- **Locale-only ru-RU strings** → Hardcoding "Цена", "Количество", etc., locks the app to one language. Mitigation: explicitly accepted; the proposal scopes out localization.
- **iOS build without code signing** → `flutter build ios --no-codesign` proves compilation but cannot install on a device. Mitigation: acceptable for a CI smoke check; real device install is a separate operational concern.

## Migration Plan

Greenfield — nothing to migrate. Bootstrap order:
1. `flutter create .` in repo root with `--platforms=android,ios --org <org> --project-name compprice`.
2. Replace generated `lib/main.dart` with the comparator implementation.
3. Confirm `pubspec.yaml` has only Flutter SDK dependencies (no additions).
4. Verify `flutter build apk` and `flutter build ios --no-codesign` both succeed.

Rollback: delete the generated platform folders and `lib/`; the repo returns to its pre-change state.

## Open Questions

- **Quantity unit label**: Should the quantity field show a "kg" suffix, stay unit-agnostic, or let the user pick? Current assumption: unit-agnostic ("Quantity"), since the proposal does not specify and adding a picker grows scope.
- **Empty-state copy**: What to show when the list is empty — a hint ("Add a product to compare"), or just blank space? Defaulting to a short hint unless told otherwise.
- **Best-deal indicator style**: Background tint only, badge only, or both? Defaulting to "background tint + leading star icon" per Decision 8 unless the user prefers something subtler.
