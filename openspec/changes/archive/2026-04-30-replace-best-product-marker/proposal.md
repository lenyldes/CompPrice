## Why

The current visual treatment for the best (lowest unit-price) product is unintuitive: it uses a leading star icon and a `tertiaryContainer` background that, against the deepPurple seed, reads as reddish — a color users associate with errors or warnings rather than "this is the winner." We want the highlight to feel positive at a glance.

## What Changes

- Replace the highlighted row's background with a light green color appropriate for both light and dark themes.
- Remove the leading star (`Icons.star`) icon used as the "best" marker — the row is identified by color alone.
- Adjust foreground (text and trailing icon) colors so they remain readable on the new green background.

## Capabilities

### New Capabilities
<!-- none -->

### Modified Capabilities
- `unit-price-compare`: tightens the "Highlight the lowest unit price" requirement to specify HOW the highlight is rendered — via a light green row background only, with no leading icon or textual marker.

## Impact

- Affected code: `lib/main.dart` — the `_ProductTile` widget (background color, leading icon, foreground colors for title/subtitle/trailing).
- No data, API, or persistence changes.
- No new dependencies.
