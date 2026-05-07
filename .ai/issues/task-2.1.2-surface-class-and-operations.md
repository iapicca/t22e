# Task 2.1.2: Surface Class with Grid Operations

**Story:** 2D Cell Grid (Surface)
**Estimate:** L

## Description

Implement the `Surface` class: a 2D `List<List<Cell>>` grid with mutation methods for text placement, fills, clears, and borders. Handles wide characters by marking the continuation cell.

## Implementation

```dart
class Surface {
  final int width;
  final int height;
  List<List<Cell>> grid;

  void putText(int x, int y, String text, TextStyle style);
  void putChar(int x, int y, String char, TextStyle style);
  void fillRect(int x, int y, int w, int h, String char, TextStyle style);
  void clearRect(int x, int y, int w, int h);
  void drawBorder(Rect rect, String borderChars, TextStyle style, String? title);
  List<String> toAnsiLines();
  List<String> toPlainLines();
}
```

## Acceptance Criteria

- `putText()`: handles grapheme clusters, skips wide continuation cells, clips at edges
- `putChar()`: marks wide chars by setting next cell's `wideContinuation = true`
- `fillRect()`: fills region without affecting cells outside rect
- `drawBorder()`: uses box-drawing ─ │ ┌ ┐ └ ┘ etc, renders title centered in top border
- All operations clip to surface bounds (no out-of-bounds errors)
- `toAnsiLines()`: produces `List<String>` where each string is a full row with ANSI SGR codes
- `toPlainLines()`: produces raw text rows (for fast diff comparison)
- Surface can be resized (creates new grid, copies overlapping region)
