# Task 4.1.3: Spacer Widget

**Story:** Basic Widgets
**Estimate:** S

## Description

Implement Spacer — a flexible empty widget that takes available space in a Row/Column layout. Useful for pushing siblings apart.

## Implementation

```dart
class Spacer extends Widget {
  final int flex;

  Size layout(Constraints constraints) {
    // takes max available space within constraints
    return Size(constraints.maxWidth, constraints.maxHeight);
  }

  void paint(PaintingContext context) {
    // paints nothing (transparent/empty)
  }
}
```

## Acceptance Criteria

- Layout: takes the maximum allowed space within constraints
- Paint: no-op (doesn't modify surface)
- Flex factor works with Row/Column's layout algorithm
- Multiple spacers distribute space proportionally by flex
