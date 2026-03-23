# FrequencyBottomSheet (family)

## Metadata

| Field | Value |
|-------|--------|
| **Name** | FrequencyBottomSheet, DayOfWeekBottomSheet, DayOfMonthBottomSheet, MonthPickerBottomSheet |
| **Category** | Bottom sheet |
| **Status** | Active |

## Overview

Rounded sheets presented from `CreateHabitSheet` for picking frequency options and sub-options (weekday, day of month, month).

**Use when:** user edits frequency inline and a picker is needed.

**Do not use when:** inline text is enough (simple modes).

## Anatomy

- Shared chrome: rounded rect, `AppTheme.Elevation.sheet`, horizontal insets, dismiss on backdrop.

## Tokens used

`AppTheme.Radius.xl`, `AppTheme.Elevation.sheet`, `AppTheme.Motion.sheetEaseIn`, `AppTheme.Motion.sheetEaseOut`, `AppTheme.Spacing`.

## Props / API

Bindings: `isPresented`, selected value structs per sheet type.

## States

- **Presenting / dismissing:** ease animations.
- **Selection:** list row highlight (SwiftUI defaults + theme colors).

## Code example

Embedded `if showFrequencySheet` blocks in `CreateHabitSheet`.

## Cross-references

- [create-habit-sheet.md](./create-habit-sheet.md)
