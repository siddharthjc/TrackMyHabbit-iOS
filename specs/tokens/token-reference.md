# Token reference (master map)

**Sources of truth**

- **CSS:** `/tokens.css` — Layer 1 (`--ds-*`) and Layer 2 (`--*`). Dark appearance overrides Layer 2 in `@media (prefers-color-scheme: dark)`.
- **Swift:** `TrackMyHabbit/TrackMyHabbit/Theme/AppTheme.swift` — mirrors Layer 2 for runtime via `UIColor` dynamic providers (`semantic` helpers) so one semantic name resolves per trait collection.

---

## Colors (Layer 2)

| CSS variable | Light (typical) | Dark (typical) | When to use |
|--------------|-----------------|----------------|-------------|
| `--color-text` | `#16191d` | `#fafafa` | Primary labels, titles |
| `--color-text-secondary` | `#5b6271` | `#6e6e6e` | Subtitles, hints |
| `--color-text-disabled` | `#8c95a6` | `#636366` | Disabled, placeholders |
| `--color-text-inverse` | `#ffffff` | `#171717` | CSS: contrasting fill text; Swift `textInverse` for photo/CTA uses always light (`AppTheme.Colors.textInverse`) |
| `--color-bg-primary` | `#ffffff` | `#171717` | Sheets, main canvas |
| `--color-bg-secondary` | `#f6f7f9` | `#1c1c1e` | Grouped backgrounds, elevated sheets |
| `--color-bg-tertiary` | `#edeff3` | `#2c2c2e` | Chips, tertiary fills |
| `--color-bg-splash` / `--color-bg-empty` | `#f9fafa` | `#171717` | Splash, empty canvas |
| `--color-bg-empty-card-tint` | `#f0f3ff` | `#1c1c1e` | Marketing empty hero tint |
| `--color-border-subtle` | `#e9e9ef` | `#212121` | Dividers |
| `--color-border-card` | ties tertiary / `#edeff3` | `#212121` | Inactive card stroke |
| `--color-border-brand` | brand 200 | `#4a3f8a` | Brand outlines |
| `--color-link` | `#007aff` | `#0091ff` | System link accent |
| `--color-tab-bar-accent` | `#007aff` | `#0091ff` | Tab bar tint (`AppTheme.Colors.tabBarAccent`) |
| `--color-brand-primary` | `#6253d5` | `#8f84ee` | Primary brand |
| `--color-brand-primary-light` | `#f3f1ff` | `#2e2654` | Light brand wash |
| `--color-cta-start/mid/end` | blue gradient | (same) | Primary CTA, splash logo |
| `--color-destructive` | `#e53935` | `#ff453a` | Delete |
| `--color-surface-selected` | `#e1e5ea` | `#3a3a3c` | List row selected |
| `--color-gradient-daycard-start` | `#e2e8ff` | `#171717` | Empty day card gradient top |
| `--color-gradient-daycard-end` | `#ffffff` | `#212121` | Empty day card gradient bottom |
| `--color-day-card-fill` | `#ffffff` | `#1a1a1a` | Day card base (`AppTheme.Colors.dayCardFill`) |
| `--color-chip-background` | `#ffffff` | `#2c2c2e` | Suggestion chips (`AppTheme.Colors.chipBackground`) |
| `--color-shadow-neutral` | `#5e5e72` | `#000000` | Shadow tint (Swift resolves alpha per elevation) |
| `--color-stroke-logo` | `#8a8a9f` | `#8e8e93` | Logo hairline |

---

## Spacing

| CSS variable | Value |
|--------------|------:|
| `--space-1` … `--space-8` | 4, 8, 12, 16, 20, 24, 32, 40 |
| `--space-9` | 80 |
| `--space-10` | 1 (hairline) |
| `--space-11` | 1.5 (glass inset) |
| `--space-12` | 18 |
| `--space-13` | 36 |
| `--space-14` | 48 |
| `--space-15` | 74 |
| `--space-16` | 380 |

Swift: see `AppTheme.Spacing` (includes semantic names like `sectionTop`, `dropdownOffsetTop`).

---

## Typography

| CSS variable | Meaning |
|--------------|---------|
| `--font-sans` | Geist stack |
| `--font-serif-display` | Season Mix display |
| `--font-size-xs` … `--font-size-display` | 12 → 40 |
| `--font-weight-*` | 400–700 |
| `--line-height-*` | Title/body helpers |

Swift: `AppTheme.Typography.Size`, `CustomFont`, `TypographyStyle`.

---

## Radius

| CSS variable | px |
|--------------|---:|
| `--radius-sm` | 8 |
| `--radius-md` | 12 |
| `--radius-lg` | 20 |
| `--radius-xl` | 24 |
| `--radius-2xl` | 30 |
| `--radius-pill` | 56 |
| `--radius-glass` | 28 |
| `--radius-full` | 999 |

---

## Elevation (shadow params)

See `tokens.css` for `--shadow-*` blur, Y, opacity. Swift: `AppTheme.Elevation.*` + `.appShadow(_:)`. Sheet/chip/dropdown shadows use a neutral tint in light and black with matched opacity in dark.

---

## z-index

| CSS variable | Value |
|--------------|------:|
| `--z-carousel-back` | 150 |
| `--z-carousel-active` | 100 |
| `--z-carousel-stack-base` | 50 |

Swift: `AppTheme.Layer.*`.

---

## Motion

| CSS variable | Role |
|--------------|------|
| `--duration-instant` … `--duration-splash` | Easing durations |
| `--duration-spring-*` | Spring presets (paired response/damping or bounce) |

Swift: `AppTheme.Motion`.
