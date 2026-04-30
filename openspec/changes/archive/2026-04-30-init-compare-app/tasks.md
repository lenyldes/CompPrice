## 1. Project bootstrap

- [x] 1.1 Run `flutter create . --platforms=android,ios --org com.compprice --project-name compprice` in repo root to scaffold Android + iOS targets
- [x] 1.2 Verify `pubspec.yaml` `dependencies` contains only `flutter` and `cupertino_icons` and `dev_dependencies` contains only what `flutter create` scaffolds (no additions)
- [x] 1.3 Confirm a clean `flutter pub get` succeeds with no warnings about missing platforms

## 2. Data model and state

- [x] 2.1 In `lib/main.dart`, define an immutable `Product` class with `id` (String), `name` (String), `price` (double), `quantity` (double), and a `unitPrice` getter returning `price / quantity`
- [x] 2.2 Define a `StatefulWidget` for the single screen that holds `List<Product> _products` and a monotonic `int _nextId` counter (starts at 1, never decremented)
- [x] 2.3 Implement `_addProduct(double price, double quantity)` that appends a new `Product` named `Product $_nextId`, increments `_nextId`, and calls `setState`
- [x] 2.4 Implement `_deleteProduct(String id)` that removes the matching product via `setState` without renaming or renumbering remaining products

## 3. Input handling and validation

- [x] 3.1 Add two `TextEditingController`s and `TextField`s for "Цена" (price) and "Количество" (quantity), both with `TextInputType.numberWithOptions(decimal: true)`
- [x] 3.2 Apply a `FilteringTextInputFormatter` to each field that allows only digits and a single `.` or `,` (reject any other character at the keystroke level)
- [x] 3.3 Implement a `_parseDecimal(String)` helper that replaces `,` with `.` and returns `double.tryParse`'s result (nullable)
- [x] 3.4 Derive a reactive `bool _canAdd` from the two controllers' text such that it is `true` only when price parses to a finite double `>= 0` AND quantity parses to a finite double `> 0`
- [x] 3.5 Wire the "Add" button's `onPressed` to `null` when `_canAdd` is `false` (disabled state); when enabled, call `_addProduct` and clear both input fields

## 4. List rendering and lowest-price highlight

- [x] 4.1 In `build`, compute `minUnitPrice` as the minimum of `_products.map((p) => p.unitPrice)`; treat empty list as "no minimum" so no row is highlighted
- [x] 4.2 Render `_products` with a `ListView.builder` using each `Product.id` as the row key, preserving insertion order (no sorting)
- [x] 4.3 For each row, show the auto-generated name, the entered price and quantity, and the unit price formatted with `toStringAsFixed(2)`
- [x] 4.4 Highlight rows where `p.unitPrice == minUnitPrice` by wrapping the row in a `Container` with a Material 3 tonal background from `Theme.of(context).colorScheme.tertiaryContainer` (or `secondaryContainer`) and a leading "best" indicator icon (e.g., `Icons.star`); do not hardcode raw colors
- [x] 4.5 If multiple products share the minimum unit price, highlight all of them; if the list is empty, show a brief empty-state hint
- [x] 4.6 Add a trailing `IconButton(Icons.delete_outline)` per row that calls `_deleteProduct(p.id)` with no confirmation dialog

## 5. App shell and theming

- [x] 5.1 In `main()`, run a `MaterialApp` with `theme: ThemeData(colorScheme: ColorScheme.fromSeed(...), useMaterial3: true)`, a corresponding dark `ColorScheme`, and `themeMode: ThemeMode.system`
- [x] 5.2 Place the comparison screen as the `home:` of the `MaterialApp` so there are no additional routes, tabs, or navigation
- [x] 5.3 Manually verify that toggling the OS light/dark setting flips the app's color scheme and that the highlight tone remains legible in both modes

## 6. Build verification

- [x] 6.1 Run `flutter analyze` and fix any reported issues
- [x] 6.2 Run `flutter build apk` and confirm a successful Android build artifact
- [x] 6.3 On macOS, run `flutter build ios --no-codesign` and confirm a successful iOS build
- [x] 6.4 Run `flutter test` to confirm the default smoke test (or an updated version of it) still passes
