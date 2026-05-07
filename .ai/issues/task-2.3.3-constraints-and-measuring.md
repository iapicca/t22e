# Task 2.3.3: Constraints and Measuring

**Story:** Layout Algorithm
**Estimate:** S

## Description

Define constraint types for the layout system and implement a widget measuring pass. Constraints specify min/max width and height that a widget can occupy.

## Implementation

```dart
class Constraints {
  final int minWidth, maxWidth;
  final int minHeight, maxHeight;

  bool get isTight => minWidth == maxWidth && minHeight == maxHeight;
  bool get isUnbounded => maxWidth == 0x7FFFFFFF || maxHeight == 0x7FFFFFFF;
}

class Size {
  final int width, height;
}
```

## Acceptance Criteria

- Loose constraints: large range from min to max
- Tight constraints: min == max (exact size)
- Unbounded: max is sentinel value (large int)
- `constrain(Size)` returns Size clamped to bounds
- Unit tests: tight, loose, unbounded, clamping behavior
