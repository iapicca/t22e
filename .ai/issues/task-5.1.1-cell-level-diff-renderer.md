# Task 5.1.1: Cell-Level Diff Renderer

**Story:** Cell-Level Renderer
**Estimate:** L

## Description

Implement the cell-level renderer. Compares each cell individually between previous and current frames. If a cell's style or character changed, emit only the necessary ANSI to update that cell.

## Implementation

```dart
class CellRenderer {
  String render(List<List<Cell>> previous, List<List<Cell>> current) {
    // For each cell:
    //   if char changed: move cursor to (r,c), write char
    //   if style changed: emit SGR changes, write char
    //   if both changed: emit SGR + char
    // Handle wide chars: only update at start cell
  }
}
```

## Acceptance Criteria

- Only changed cells are emitted (optimal minimal output)
- Cursor positioning uses absolute addressing (CSI r;cH)
- SGR codes are emitted only when style changes (no redundant resets)
- Wide characters: updates only at the start cell, skips continuation cell
- Significantly less output than line-level for sparse updates
- Handles resize (cells outside previous frame are always emitted)
- Performance target: diff 80×24 grid (1920 cells) in < 0.5ms
- Unit tests: single cell change, style-only change, wide char, resize, full frame
