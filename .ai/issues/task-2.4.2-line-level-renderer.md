# Task 2.4.2: Line-Level Renderer

**Story:** Diff Engine & Output
**Estimate:** M

## Description

Implement the line-level renderer that takes diff results and the current frame's styled lines, then produces ANSI escape sequences to update only the changed rows.

## Implementation

```dart
class LineRenderer {
  String render(DiffResult diff, Frame currentFrame) {
    final buf = StringBuffer();
    for (final row in diff.changedRows) {
      buf.write('\x1b[${row + 1};0H');  // move to row start
      buf.write(currentFrame.styledLines[row]);
    }
    return buf.toString();
  }
}
```

## Acceptance Criteria

- Only changed rows are emitted (no full-screen clears)
- Cursor is positioned to start of each changed row before writing
- Styled lines already contain all necessary SGR codes (from Surface.toAnsiLines)
- Rows beyond previous frame height are written at correct position
- Output is a single string suitable for writing to stdout
- Unit tests: single change, multiple changes, full frame, empty frame
