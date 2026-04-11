# CreateHabitSheet

## Metadata

| Field | Value |
|-------|--------|
| **Name** | CreateHabitSheet |
| **Category** | Form / modal sheet |
| **Status** | Active |

## Overview

Full-screen style sheet to create or edit a habit: name, inline frequency copy with tappable segments, suggestion chips, and entry to nested frequency bottom sheets.

**Use when:** creating a habit from the empty state or Add tab, or editing from the Habits tab.

**Do not use when:** only changing frequency without full form — still may present `FrequencyBottomSheet` from here.

## Anatomy

- **Header:** Close (X), optional Delete (trash), Confirm (checkmark) in circular elevated buttons.
- **Body:** Title “I want to”, text field, inline frequency line, divider, suggestions list.
- **Overlays:** `FrequencyBottomSheet`, `DayOfWeekBottomSheet`, `DayOfMonthBottomSheet`, `MonthPickerBottomSheet`.

## Tokens used

`AppTheme.Colors` (`bgPrimary`, `chipBackground`, `borderSubtle`, `textPrimary`/`Disabled`, `primary`), `AppTheme.Spacing`, `AppTheme.Radius`, `AppTheme.Elevation.floatingCircularButton`, `AppTheme.Elevation.suggestionChip`, `AppTheme.Motion`, `customFont`.

**Appearance:** Sheet canvas and chips follow semantic backgrounds; divider uses `borderSubtle`.

## Props / API

- `editingHabit: Habit?` — `nil` create, non-nil edit.

## States

- **Default:** editing name, frequency line idle.
- **Pressed / scale:** frequency row micro-scale (`Motion.frequencySpring`).
- **Disabled confirm:** when name empty; checkmark uses `textDisabled`.
- **Delete confirmation:** system alert.
- **Persistence error:** alert.

## Code example

`CreateHabitSheet()` with `.modelContainer(for: Habit.self, inMemory: true)` in previews.

## Cross-references

- [frequency-bottom-sheet.md](./frequency-bottom-sheet.md)
- [day-card.md](./day-card.md) (data model)
