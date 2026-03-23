# HabitPickerModal

## Metadata

| Field | Value |
|-------|--------|
| **Name** | HabitPickerModal |
| **Category** | Picker |
| **Status** | Active |

## Overview

Horizontal scroll of habit chips (used where a compact habit selector is needed).

**Use when:** selecting among habits in a secondary flow.

**Do not use when:** the main habit dropdown from `ContentView` is sufficient.

## Anatomy

- Horizontal stack of buttons with rounded chips.

## Tokens used

`AppTheme.Spacing`, `AppTheme.Radius.sm`, `AppTheme.Typography.Size`, `customFont`.

## Props / API

Defined in `HabitPickerModal.swift` (habits list + selection callback).

## States

- **Default / selected:** typography and fill differ by selection.

## Code example

See `HabitPickerModal.swift` previews.

## Cross-references

- [content-view.md](./content-view.md)
