# Task 4.2.1: Row Widget

**Story:** Container Widgets
**Estimate:** M

## Description

Implement Row — a horizontal layout widget that distributes children using the split-horizontal algorithm.

## Implementation

```dart
class Row extends Widget {
  final List<Widget> children;
  final int gap;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  Size layout(Constraints constraints) {
    // 1. Determine which children are fixed vs flexible
    // 2. Use splitHorizontal to allocate widths
    // 3. Each child gets a tight width constraint + parent's height
    // 4. Return total width, max child height
  }

  void paint(PaintingContext context) {
    // paint each child at its computed offset
  }
}
```

## Acceptance Criteria

- Children are laid out left-to-right
- Fixed-width children get exact width, flexible children share remaining space
- `gap` adds spacing between children (subtracted before flex distribution)
- `mainAxisAlignment`: start (left), center, end (right), spaceBetween, spaceAround
- `crossAxisAlignment`: start (top), center (middle), end (bottom), stretch
- Overflow: flexible children can shrink to minimum size
- Layout must handle edge cases: empty children, single child, all fixed, all flexible
