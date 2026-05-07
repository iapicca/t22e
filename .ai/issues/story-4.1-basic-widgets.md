# Story 4.1: Basic Widgets (Text, Box, Spacer)

**Feature:** Widget Library
**Estimate:** M
**Depends on:** Surface (2.1), TextStyle (2.2)

## Description

Implement the fundamental building-block widgets: Text for rendering styled strings, Box for bordered/padded containers with titles, and Spacer for flexible empty space.

## Tasks

| # | Task | Est. |
|---|------|------|
| 4.1.1 | Text widget | S |
| 4.1.2 | Box widget (border + padding) | M |
| 4.1.3 | Spacer widget | S |

## Acceptance Criteria

- Text widget paints styled text with alignment and word wrap
- Box widget draws border with box-drawing chars, renders title in top border
- Box supports: rounded, single, double, thick border styles
- Spacer fills available space (flexible empty area)
- All widgets implement `Size layout(Constraints)` and `void paint(PaintingContext)`
- Unit tests: layout sizes, paint output, word wrap behavior
