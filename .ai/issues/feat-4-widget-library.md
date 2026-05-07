# Feature: Widget Library

**Phase:** 4
**Priority:** P1 - Important
**Depends on:** Feature 2 (Surface, TextStyle, Layout), Feature 3 (TEA)

## Description

Build the built-in widget library: basic widgets (Text, Box, Spacer), container widgets (Row, Column), interactive widgets (Scrollable, TextInput, List), and visual/composite widgets (Progress, Spinner, Table, Dialog).

## Stories

| # | Story | Est. |
|---|-------|------|
| 4.1 | Basic Widgets (Text, Box, Spacer) | M |
| 4.2 | Container Widgets (Row, Column) | M |
| 4.3 | Interactive Widgets (Scrollable, TextInput, List) | XL |
| 4.4 | Visual & Composite Widgets (Progress, Spinner, Table, Dialog) | L |

## Acceptance Criteria

- Each widget follows the Widget abstract class (layout + paint)
- Widgets compose naturally (widgets contain widgets)
- Text widget supports alignment, word wrap, styling
- Box widget supports borders, padding, titles
- Row/Column use layout algorithm for space distribution
- Scrollable supports vertical/horizontal scrolling with viewport
- TextInput supports cursor, selection, editing, password mode
- List supports keyboard navigation, selection, item highlighting
- Progress supports determinate and indeterminate modes
- Spinner has configurable frame sets
- Table supports column headers, sorting indicator, cell styling
- Dialog renders overlay with backdrop, title, content, buttons
