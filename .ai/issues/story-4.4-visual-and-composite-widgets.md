# Story 4.4: Visual & Composite Widgets (Progress, Spinner, Table, Dialog)

**Feature:** Widget Library
**Estimate:** L
**Depends on:** Basic Widgets (4.1), Container Widgets (4.2)

## Description

Implement visual feedback widgets (Progress bar, Spinner) and composite widgets (Table, Dialog overlay). These provide higher-level UI patterns common in terminal applications.

## Tasks

| # | Task | Est. |
|---|------|------|
| 4.4.1 | Progress bar widget | S |
| 4.4.2 | Spinner widget | S |
| 4.4.3 | Table widget | M |
| 4.4.4 | Dialog/overlay widget | M |

## Acceptance Criteria

- Progress: determinate (percentage) and indeterminate (animated bar) modes, custom fill char and colors
- Spinner: configurable frames (default braille spinner), animated via TickMsg, configurable speed
- Table: column headers, rows with auto-sizing, sorting indicator triangle, alternating row colors, horizontal scrolling, cell text alignment
- Dialog: modal overlay with backdrop dimming, title bar, content area, button bar, Escape to dismiss, focus management
- All widgets are TEA models with their own state management
