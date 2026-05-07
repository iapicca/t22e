# Task 4.1.1: Text Widget

**Story:** Basic Widgets
**Estimate:** S

## Description

Implement the Text widget — renders a styled string into a surface. Supports text alignment, word wrapping, and max-width clipping.

## Implementation

```dart
class Text extends Widget {
  final String text;
  final TextStyle style;
  final TextAlign align;
  final bool wordWrap;

  Size layout(Constraints constraints) {
    // measure: text width (longest line), text height (line count)
    // respect wordWrap: break at word boundaries if width exceeds constraints
  }

  void paint(PaintingContext context) {
    // render text into surface with alignment and wrapping
  }
}
```

## Acceptance Criteria

- Paints text into allocated rect with correct style
- Alignment: left, center, right
- Word wrap respects grapheme cluster boundaries and CJK widths
- Overflow: clips text at right edge of allocated area
- `layout()` returns correct intrinsic size given constraints
- Unit tests: layout measurement, paint output, wrapping behavior
