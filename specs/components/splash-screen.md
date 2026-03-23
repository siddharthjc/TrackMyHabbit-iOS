# SplashScreenView

## Metadata

| Field | Value |
|-------|--------|
| **Name** | SplashScreenView / SplashLogoView |
| **Category** | Launch |
| **Status** | Active |

## Overview

Animated logo (vector shape + gradient + inner treatments) and tagline on splash background; transitions to main app.

**Use when:** cold launch before main content.

**Do not use when:** app has already completed splash (`onFinished`).

## Anatomy

- **SplashLogoShape:** Path data for mark.
- **SplashLogoView:** Gradient fill, inner shadow overlay, hairline stroke.
- **SplashScreenView:** Background, animation sequence, tagline.

## Tokens used

`AppTheme.Colors` (CTA gradient, stroke, background), `AppTheme.Motion.splash*`, `customFont`.

## Props / API

- `onFinished: () -> Void`

## States

- **Entrance:** scale, opacity, rotation springs.
- **Tagline:** opacity + move transition.
- **Dismiss:** scale + fade out.

## Code example

`SplashScreenView(onFinished: { })` from app entry.

## Cross-references

- [content-view.md](./content-view.md)
