# Task 4.2.2: Column Widget

**Story:** Container Widgets
**Estimate:** M

## Description

Implement Column — a vertical layout widget that distributes children using the split-vertical algorithm.

## Implementation

```dart
class Column extends Widget {
  final List<Widget> children;
  final int gap;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  Size layout(Constraints constraints) {
    // Same as Row but vertical
    // Use splitVertical to allocate heights
  }

  void paint(PaintingContext context) {
    // paint each child at its computed vertical offset
  }
}
```

## Acceptance Criteria

- Children are laid out top-to-bottom
- Same fixed/flexible behavior as Row, applied to heights
- `mainAxisAlignment`: start (top), center, end (bottom), spaceBetween, spaceAround
- `crossAxisAlignment`: start (left), center, end (right), stretch
- Layout handles all edge cases
- Shares core layout algorithm with Row (parameterize or reuse)
