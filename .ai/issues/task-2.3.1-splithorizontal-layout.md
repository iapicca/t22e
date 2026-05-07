# Task 2.3.1: SplitHorizontal Layout

**Story:** Layout Algorithm
**Estimate:** M

## Description

Implement the horizontal space-splitting algorithm. Given a total width and a list of items (each either fixed or flexible), allocate widths: fixed items get their exact width, remaining space is divided among flexible items.

## Implementation

```dart
class LayoutItem {
  final int? fixedWidth; // null means flexible
  final int flex;        // flex factor (default 1)
}

List<int> splitHorizontal(int total, List<LayoutItem> items, int gap) {
  // sum fixed widths + gaps
  // remaining = total - sum fixed - gaps
  // distribute remaining among flexible items by flex factor
}
```

## Acceptance Criteria

- Fixed items get exact width; remaining space split among flexible items
- Flex factors work proportionally (flex:2 gets twice the space of flex:1)
- Gaps between items are subtracted before flexible distribution
- Edge cases: all fixed, all flexible, single item, total too small (flex items get minimum 1)
- Returns list of allocated widths in same order as input items
- Unit tests with various combinations
