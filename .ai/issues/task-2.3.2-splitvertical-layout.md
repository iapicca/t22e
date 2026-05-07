# Task 2.3.2: SplitVertical Layout

**Story:** Layout Algorithm
**Estimate:** M

## Description

Same algorithm as SplitHorizontal but for vertical space allocation. Given total height and items, allocate heights to fixed and flexible items.

## Implementation

```dart
List<int> splitVertical(int total, List<LayoutItem> items, int gap) {
  // identical algorithm to splitHorizontal, different axis
}
```

## Acceptance Criteria

- Same acceptance criteria as SplitHorizontal, applied vertically
- Reuses the same core algorithm (parameterize by axis or share function)
- Unit tests for vertical combinations
