# Task 2.2.1: TextStyle Definition

**Story:** TextStyle & Color Resolution
**Estimate:** M

## Description

Define the TextStyle class holding all visual and layout properties for a terminal cell or region.

## Implementation

```dart
class TextStyle {
  // Colors (tiered)
  Color? foreground;
  Color? background;

  // Text attributes
  bool bold, dim, italic, underline, blink, reverse, strikethrough, overline;

  // Layout
  EdgeInsets padding, margin;
  Border? border;
  int? width, height;
  TextAlign align;
  bool wordWrap;
}
```

## Acceptance Criteria

- All text attributes default to false (no modification)
- Colors default to null (inherit/no change)
- Layout fields default to neutral values (zero padding, no border, etc.)
- `TextStyle.empty` singleton for default style
- `merge(TextStyle other)` produces combined style (specific fields override)
- `==` and `hashCode` for diff comparison
- Unit tests: merge, empty, equality, attribute combinations
