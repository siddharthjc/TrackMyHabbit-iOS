# Token reference (master map)

**Sources of truth**

- **CSS:** `/tokens.css` — Layer 1 (`--ds-*`) and Layer 2 (`--*`).
- **Swift:** `TrackMyHabbit/TrackMyHabbit/Theme/AppTheme.swift` — mirrors Layer 2 for runtime.

---

## Colors (Layer 2)

| CSS variable | Typical value | When to use |
|--------------|---------------|-------------|
| `--color-text` | `#16191d` | Primary labels, titles |
| `--color-text-secondary` | `#5b6271` | Subtitles, hints |
| `--color-text-disabled` | `#8c95a6` | Disabled, placeholders |
| `--color-text-inverse` | `#ffffff` | On photos / dark fills |
| `--color-bg-primary` | `#F9FAFA` | Sheets, cards on white |
| `--color-bg-secondary` | `#f5f5f8` | Grouped backgrounds |
| `--color-bg-tertiary` | `#edeff3` | Chips, tertiary fills |
| `--color-bg-splash` / `--color-bg-empty` | `#f9fafa` | Splash, empty canvas |
| `--color-bg-empty-card-tint` | `#f0f3ff` | Marketing empty hero tint |
| `--color-border-subtle` | `#e9e9ef` | Dividers |
| `--color-border-card` | `#edeff3` | Inactive card stroke |
| `--color-border-brand` | brand 200 | Brand outlines |
| `--color-link` | `#007aff` | System link accent |
| `--color-brand-primary` | `#6253d5` | Primary brand |
| `--color-brand-primary-light` | `#f3f1ff` | Light brand wash |
| `--color-cta-start/mid/end` | blue gradient | Primary CTA, splash logo |
| `--color-destructive` | `#e53935` | Delete |
| `--color-surface-selected` | `#e1e5ea` | List row selected |
| `--color-gradient-daycard-start` | `#e2e8ff` | Empty day card top |
| `--color-shadow-neutral` | `#5e5e72` | Neutral shadows |
| `--color-stroke-logo` | `#8a8a9f` | Logo hairline |

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

See `tokens.css` for `--shadow-*` blur, Y, opacity. Swift: `AppTheme.Elevation.*` + `.appShadow(_:)`.

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
