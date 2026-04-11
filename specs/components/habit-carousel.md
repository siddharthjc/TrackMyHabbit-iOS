# HabitCarousel

## Metadata

| Field | Value |
|-------|--------|
| **Name** | HabitCarousel |
| **Category** | Data visualization |
| **Status** | Active |

## Overview

Stacked `DayCard` views for recent days with swipe navigation and scale depth.

**Use when:** displaying photo entries for the active habit on Home.

**Do not use when:** a simple list is enough — this is a bespoke carousel.

## Anatomy

- `ZStack` of `DayCard` for visible indices; horizontal offset for centering.
- Drag gesture updates `dragOffset`; end state animates index with spring.

## Tokens used

`AppTheme.Spacing`, `AppTheme.Motion.carouselSettleSpring`, `AppTheme.Motion.carouselResetSpring`, `AppTheme.Layer`, fixed layout constants on `AppTheme.Layout` (card width/height, scale step, etc.).

## Props / API

- `habit: Habit`

## States

- **Dragging:** cards scale/offset with progress.
- **Settled:** `currentIndex` updated; z-order from `AppTheme.Layer`.

## Code example

`HabitCarousel(habit: habit)` inside `ContentView` home.

## Cross-references

- [day-card.md](./day-card.md)
