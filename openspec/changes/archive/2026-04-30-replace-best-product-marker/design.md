## Context

`_ProductTile` in `lib/main.dart` highlights the cheapest row by:
1. Setting the container background to `colorScheme.tertiaryContainer`.
2. Rendering a `leading: Icon(Icons.star, ...)`.
3. Switching title/subtitle/trailing icon colors to `onTertiaryContainer`.

With the app's `deepPurple` seed, `tertiaryContainer` resolves to a pinkish/red-leaning tone in light mode, which signals "warning" rather than "best deal." The change shifts the highlight to an explicit light green and drops the star.

## Goals / Non-Goals

**Goals:**
- Highlighted row reads as positive/affirmative (light green) in both light and dark themes.
- Identification of the best product is conveyed by background color alone.
- Foreground content remains accessible (sufficient contrast) on the new background.

**Non-Goals:**
- No change to how "best" is computed (still lowest `unitPrice` among products).
- No change to multi-winner tie behavior.
- No theming overhaul — we are not refactoring the app's color seed or introducing a custom `ColorScheme` extension for general use.

## Decisions

**Decision 1: Use a fixed light green color rather than a semantic theme role.**

The default Material `ColorScheme` does not include a "success/positive" semantic role, and remapping `tertiary` would cascade to other UI. Picking concrete shades is simpler and predictable.

- Light theme background: `Color(0xFFC8E6C9)` (Material `green.shade100`-equivalent).
- Dark theme background: `Color(0xFF2E7D32)` (Material `green.shade800`-equivalent), which keeps WCAG-acceptable contrast against on-surface text.

Selection happens via `Theme.of(context).brightness`. Foreground colors are restored to defaults (no override) in light mode; in dark mode, the title/subtitle/trailing keep the default `onSurface` colors since `green.shade800` is dark enough to read white-ish text against.

Alternatives considered: introducing a `ThemeExtension` for "success" colors. Rejected as over-engineering for a single use site.

**Decision 2: Remove the leading icon entirely.**

The proposal states the row is identified by color alone. We delete the `leading` branch instead of replacing the star with a different icon. This also avoids the `ListTile` reserving leading space, so all rows align consistently.

**Decision 3: Drop the foreground color overrides.**

With a light green background in light mode, the default `onSurface` text color is readable; with a dark green background in dark mode, default light text is readable. So we remove the `isBest ? ... : null` foreground overrides on title, subtitle, and trailing icon, simplifying the widget.

## Risks / Trade-offs

- [Hardcoded colors may not match a future themed redesign] → Acceptable; if a design system is later introduced, the two constants are trivial to swap for theme-extension lookups.
- [Color-only signal may be missed by users with red/green color vision deficiency] → Mitigated because the contrast is light-green vs. neutral surface (not red vs. green), so deuteranopia/protanopia users still perceive a brightness/saturation difference. No additional textual marker per the user's explicit request.
- [Tie cases highlight multiple rows] → Existing behavior preserved; visually, multiple green rows still read as "these are the best."
