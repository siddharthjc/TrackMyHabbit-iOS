# ContentView

## Metadata

| Field | Value |
|-------|--------|
| **Name** | ContentView |
| **Category** | App shell |
| **Status** | Active |

## Overview

Root view hosting the system `TabView`, habit switcher, carousel, and global overlays (habit picker dropdown, create/edit sheets).

**Use when:** defining the main post-splash experience.

**Do not use when:** you only need a single feature screen in isolation — prefer previews or a dedicated container.

## Anatomy

- **Tab bar:** Home, Calendar (placeholder), Habits (opens edit sheet), Add (opens create sheet).
- **Home stack:** `EmptyState` or `HabitSwitcher` + `HabitCarousel`.
- **HabitDropdownOverlay:** Full-screen dim + floating card list (implemented in same file as private struct).

## Tokens used

`AppTheme.Colors`, `AppTheme.Spacing`, `AppTheme.Radius`, `AppTheme.Motion`, `AppTheme.Elevation`, `customFont`.

## Props / API

SwiftUI `struct ContentView: View` — no parameters; reads SwiftData `Habit` via `@Query`.

## States

- **Empty habits:** `EmptyState` CTA.
- **Has habits:** switcher + carousel; dropdown when `showHabitDropdown`.
- **Tabs:** Custom binding prevents switching on Habits/Add; triggers sheets instead.

## Code example

See `ContentView.swift` — `homeScreen`, `tabSelection`, `HabitDropdownOverlay`.

## Cross-references

- [empty-state.md](./empty-state.md)
- [habit-carousel.md](./habit-carousel.md)
- [create-habit-sheet.md](./create-habit-sheet.md)
