# Step 1 — Visual values audit

## CSS / SCSS

| Metric | Count |
|--------|------:|
| `.css` files | **0** |
| `.scss` / `.sass` files | **0** |

**Finding:** This repository is a **SwiftUI** iOS app. There are no stylesheets to scan. All visual values live in Swift (`AppTheme`, view modifiers, and inline `Color` / layout literals).

The audit below summarizes **hardcoded visual values** discovered in `TrackMyHabbit/TrackMyHabbit/**/*.swift` prior to tokenization (March 2026).

---

## Grouped inventory (Swift, pre-token pass)

### Hex colors

| Value | Typical use |
|-------|-------------|
| `#5E5E72` | Card / chip / dropdown shadows (with opacity) |
| `#E53935` | Destructive (delete) |
| `#E1E5EA` | Habit dropdown active row |
| `#EDEFF3` | Card stroke (inactive), matches `bgTertiary` |
| `#E2E8FF` | Day card empty gradient top |
| `#6F8EFF`, `#4D6FEA`, `#5778F1` | CTA & splash logo gradients |
| `#F9FAFA` | Splash background |
| `#8A8A9F` | Logo hairline stroke |

*Additional hex lives in `AppTheme` primitives (`Neutral`, `Brand`, `Colors`) — counted as centralized, not duplicated in views after refactor.*

### RGB / RGBA (non-hex)

| Pattern | Where |
|---------|--------|
| `Color(red: 94/255, green: 94/255, blue: 114/255)` | EmptyState CTA shadow |
| `Color(red: 0.07, green: 0.11, blue: 0.36)` | CTA inner rim |
| `Color(red: 138/255, green: 138/255, blue: 159/255)` | CTA hairline |
| `.black.opacity`, `.white.opacity`, `Color.gray` | Glass bar, day card overlays, placeholders |

### Pixel spacing (inline)

Common literals: `4`, `8`, `12`, `16`, `18`, `20`, `24`, `32`, `36`, `40`, `48`, `56`, `74`, `80`, `160`, `288`, `397`, `402`, `456`, `380`, `1`, `1.5`, `2`, `3`, `6`, `12` (carousel), `20` (edge), `22` (dot grid), `47` (card step), `60` (swipe), `44` (min height).

### Font sizes (system / custom)

`12`, `14`, `16`, `20`, `24`, `40` (system); Geist / SeasonMix via `customFont`.

### Font weights

`.medium`, `.semibold`, `.bold` (system); custom font names in `Typography`.

### Border radii

`8`, `12`, `24`, `28`, `30`, `56`, `999` (full).

### z-index

`150`, `100`, `50 - depth` (carousel stacking).

### Box shadows (SwiftUI `.shadow`)

Various `radius` / `y` / opacity combinations; neutral `#5E5E72` family; black/white for glass and photo labels.

### Motion

Spring `response`/`dampingFraction`/`duration`/`bounce`; ease durations `0.1`, `0.18`, `0.25`, `0.3`, `0.4`, `0.45`, `0.5`, `0.6`, `0.7`, `1.8` delays.

---

## Approximate totals (Swift literals, pre-refactor)

| Category | Approx. count |
|----------|---------------|
| Hex strings in views | ~25 occurrences |
| Raw spacing literals | ~80+ |
| Raw font sizes | ~25 |
| Raw radii | ~35 |
| Shadow calls with literal numbers | ~30 |
| Animation durations / spring params | ~25 |
| z-index | 1 formula, 3 tiers |

*Counts are approximate because some lines combine multiple categories.*

---

## Files with the most hardcoded values (Swift)

| Rank | File | Notes |
|------|------|--------|
| 1 | `CreateHabitSheet.swift` | Shadows, radii, spacing, springs, system fonts |
| 2 | `ContentView.swift` | Dropdown, calendar placeholder, motion |
| 3 | `DayCard.swift` | Gradients, strokes, shadows, typography |
| 4 | `EmptyState.swift` | CTA rims, RGB literals, pattern grid |
| 5 | `HabitCarousel.swift` | Layout math, z-index, springs |
| 6 | `LiquidGlassBar.swift` | Materials, white/black opacities, shadows |
| 7 | `SplashScreenView.swift` | Gradients, hex, animation timings |
| 8 | `FrequencyBottomSheet.swift` | Shadow numbers, durations (partially themed) |
| 9 | `HabitSwitcher.swift` | System font, padding |
| 10 | `Typography.swift` | Title/body numeric sizes |

---

## Canonical token source

- **LLM / web reference:** `tokens.css` (Layer 1 primitives, Layer 2 aliases).
- **Runtime (iOS):** `AppTheme` in `AppTheme.swift` — mirrors Layer 2 names; primitives align with `Neutral` / `Brand` (Layer 1).
