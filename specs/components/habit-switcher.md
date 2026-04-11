# HabitSwitcher

## Metadata

| Field | Value |
|-------|--------|
| **Name** | HabitSwitcher |
| **Category** | Navigation / header |
| **Status** | Active |

## Overview

Tappable habit title row with optional chevron when multiple habits exist.

**Use when:** user has at least one habit and you need to open the habit dropdown.

**Do not use when:** only one habit and you want to hide affordance — opacity is reduced when `habitCount < 2`.

## Anatomy

- `Button` with title + `chevron.down` if `habitCount >= 2`.

## Tokens used

`AppTheme.Colors.textPrimary`, `AppTheme.Typography.Size.titleNav`, `AppTheme.Typography.Size.iconSmall`, `AppTheme.Spacing.sm`, `AppTheme.Spacing.md`, `AppTheme.Layout.minTouchTarget`.

## Props / API

- `habitName`, `habitCount`, `onSwitchPress`

## States

- **Single habit:** chevron hidden, reduced opacity.
- **Multi habit:** full opacity, chevron visible.

## Code example

`HabitSwitcher(habitName:habitCount:onSwitchPress:)` in `ContentView`.

## Cross-references

- [content-view.md](./content-view.md)
