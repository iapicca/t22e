# Task 2.4.1: Frame Comparison (Line-Level Diff)

**Story:** Diff Engine & Output
**Estimate:** M

## Description

Implement frame comparison that detects which rows changed between the previous frame and the current frame. Compares both plain text (fast content check) and styled text (attribute change detection).

## Implementation

```dart
class Frame {
  final List<String> plainLines;
  final List<String> styledLines;
}

class DiffResult {
  final List<int> changedRows; // row indices that differ
}

DiffResult diff(Frame previous, Frame current) {
  // for each row up to max(prev.height, curr.height):
  //   if prev.plain[r] != curr.plain[r] => changed
  //   or prev.styled[r] != curr.styled[r] => changed
}
```

## Acceptance Criteria

- Compares plain text first (fast-path for identical rows)
- Falls back to styled comparison if plain differs
- Detects: content changes, style changes, row additions, row removals
- Handles frames of different heights (resize)
- Returns list of changed row indices for the renderer to process
- Unit tests: content change, style-only change, resize, no change
