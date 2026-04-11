# LiquidGlassBar

## Metadata

| Field | Value |
|-------|--------|
| **Name** | LiquidGlassBar |
| **Category** | Chrome / navigation |
| **Status** | Active |

## Overview

Frosted pill-shaped bar with layered materials, gradients, and dual shadows.

**Use when:** top overlay UI (e.g. future nav chrome) needs glass styling.

**Do not use when:** a plain toolbar suffices — this is visually heavy.

## Anatomy

- `ultraThinMaterial` + white gradient fills + stroke + inner gradient mask.
- Dual `appShadow` tokens for dark lift and light top edge.

## Tokens used

`AppTheme.Radius.glass`, `AppTheme.Elevation.glassDark`, `AppTheme.Elevation.glassLight`, `AppTheme.Glass.*` (white opacities, stroke, inset padding), `AppTheme.Spacing`, `AppTheme.Layout` (default height).

## Props / API

- `height`, `cornerRadius`, `@ViewBuilder content`

## States

- Static appearance (no pressed state in component).

## Code example

`LiquidGlassBar { ... }` in preview within `LiquidGlassBar.swift`.

## Cross-references

- None required for current app shell (optional chrome).
