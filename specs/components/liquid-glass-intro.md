# LiquidGlassIntroView

## Metadata

| Field | Value |
|-------|--------|
| **Name** | LiquidGlassIntroView |
| **Category** | Launch |
| **Status** | Active |

## Overview

First-run-only liquid-glass swipe screen after the splash: refractive Metal shader (`tmhLiquidGlass`), swipe-up (or tap) to move the bubble. On release, if `dragProgress >= liquidIntroSnapThreshold` the bubble snaps to centre, holds for `durationIntroSettlePause`, then runs a four-phase transition (Apple-Intelligence iridescent burst → circular reveal mask → destination opacity 0→1 → done) that hands off to a caller-supplied `Destination` view. If the release falls below the threshold, the bubble springs back to the bottom and stays interactive. The intro view is generic over `Destination: View` and never names the destination type directly; today the call site passes `ContentView()` and `revealBackground: AppTheme.Colors.emptyStateBackground`.

**Use when:** cold launch after splash, user has not completed intro (`LiquidGlassIntroLaunch` / UserDefaults).

**Do not use when:** intro already completed, UI tests without `-skipLiquidIntro`.

## Anatomy

- **LiquidGlassIntroShaders.metal:** Stitchable `tmhLiquidGlass` for `layerEffect`.
- **LiquidGlassIntroView<Destination>:** Timeline-driven shader, drag/tap gestures, haptics, welcome copy, transition state machine (`idle → snapping → exploding → revealing → fadingIn → done`), reduce-motion crossfade fallback, `shouldSkipForTesting` short-circuit, `markCompleted()` call before `onComplete`. On valid release (`dragProgress >= liquidIntroSnapThreshold`) or tap-up the ball snaps to centre with `springIntroSnap` and gestures lock; after `durationIntroSettlePause` the burst kicks off.
- **AppleIntelligenceBurstView:** Pure-SwiftUI iridescent burst (angular gradient + radial falloff, `TimelineView`-driven rotation) emitted from the ball's final centre during `exploding`/`revealing`.
- **LiquidGlassIntroLaunch:** Persistence key, skip launch argument for UITests.

## Tokens

`AppTheme.Colors.emptyStateBackground`, `textPrimary`, `textSecondary`, `appleIntelligenceBurstStops`; `AppTheme.Layout.liquidIntro*` (incl. `liquidIntroSnapThreshold`); `AppTheme.Motion` liquid intro / `springLiquidIntro*` / `springIntroSnap` / `durationIntroSettlePause` / `durationIntroBurst` / `durationIntroReveal` / `durationIntroDestinationFade`; `AppTheme.Spacing.liquidIntroSwipeHintBottom`; `AppTheme.Typography.Size.liquidIntroTitle`; `customFont`.

## Cross-references

- [splash-screen.md](./splash-screen.md)
- [content-view.md](./content-view.md)
