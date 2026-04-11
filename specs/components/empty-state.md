# EmptyState

## Metadata

| Field | Value |
|-------|--------|
| **Name** | EmptyState |
| **Category** | Onboarding / marketing |
| **Status** | Active |

## Overview

Hero illustration, serif headline, and gradient CTA pill when the user has no habits.

**Use when:** `habits.isEmpty` on the home tab.

**Do not use when:** at least one habit exists — use `HabitSwitcher` + carousel instead.

## Anatomy

- Background: `emptyStateBackground` + dotted pattern canvas.
- **EmptyStateCTA:** Gradient fill, inset rims, outer shadow, spring press animation.
- **EmptyStateCTAButtonStyle:** Bridges `Button` label to `EmptyStateCTA`.

## Tokens used

`AppTheme.Colors` (`emptyStateBackground`, `patternDot`, `textPrimary`/`Secondary`, `textInverse` on CTA label, CTA gradient), `AppTheme.Spacing`, `AppTheme.Radius.pill`, `AppTheme.Elevation.ctaOuter`, `AppTheme.Motion.springCTA`, `ctaInsetNavy`, `ctaHairline`, `customFont`. Asset: `EmptyStateHero` in `Assets.xcassets`.

**Appearance:** Hero uses bundled `EmptyStateHero` (3D box + habit icons illustration) in all appearances; dotted `patternDot` behind it.

## Props / API

- `onCreateHabit: () -> Void`

## States

- **Rest:** full gradient CTA with fixed outer shadow.
- **Pressed:** navy rim Y offset changes; spring animation.

## Code example

`EmptyState { ... }` in `ContentView` when no habits.

## Cross-references

- [content-view.md](./content-view.md)
