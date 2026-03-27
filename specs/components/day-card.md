# DayCard

## Metadata

| Field | Value |
|-------|--------|
| **Name** | DayCard |
| **Category** | Card |
| **Status** | Active |

## Overview

Photo card or empty gradient card for a single day, with date labels and optional photo picker.

**Use when:** showing one day inside `HabitCarousel`.

**Do not use when:** you need a compact list row — different pattern.

## Anatomy

- **Photo:** Async image, bottom gradient scrim, white text with shadow.
- **Empty:** Brand-tint gradient, “Add photo” row, stroke.

## Tokens used

`AppTheme.Colors` (`dayCardFill`, `gradientDayCardStart`/`End`, `borderSubtle`, `textPrimary`/`Secondary`, `textInverse` on photo scrim), `AppTheme.Spacing`, `AppTheme.Radius.xl`, `AppTheme.Elevation.dayCard` / `dayCardDark`, `AppTheme.Elevation.photoLabelText`, `customFont`.

**Appearance:** Dark mode uses `dayCardDark` shadow and `#212121` border via `borderSubtle`; light mode keeps white hairline on active empty card via `textInverse`.

## Props / API

- `dateStr`, `entry`, `isActive`, `cardWidth`, `cardHeight`, `tapAction`, `onImagePicked`

## States

- **Active vs inactive:** shadow depth, border, text colors.
- **Empty vs photo:** layout branches.

## Code example

Constructed from `HabitCarousel.cardLayer`.

## Cross-references

- [habit-carousel.md](./habit-carousel.md)
