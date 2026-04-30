## 1. Update _ProductTile highlight rendering

- [x] 1.1 In `lib/main.dart`, replace the `isBest ? colorScheme.tertiaryContainer : null` background with a brightness-aware light green: `Color(0xFFC8E6C9)` for `Brightness.light` and `Color(0xFF2E7D32)` for `Brightness.dark`, computed from `Theme.of(context).brightness`.
- [x] 1.2 Remove the `leading: isBest ? Icon(Icons.star, ...) : null` block from the `ListTile` so highlighted rows have no leading icon.
- [x] 1.3 Drop the `isBest ? colorScheme.onTertiaryContainer : null` foreground overrides on the title `Text`, subtitle `Text`, and trailing `IconButton` so default theme foreground colors are used.

## 2. Verify behavior

- [x] 2.1 Run `flutter analyze` and fix any warnings introduced by the edits.
- [x] 2.2 Manually verify in the running app (light and dark theme) that: the cheapest row has a light green background, no star/asterisk is shown, text remains readable, ties highlight all winners, and the highlight updates after add and delete.
