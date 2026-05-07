# Task 2.1.1: Cell Class Definition

**Story:** 2D Cell Grid (Surface)
**Estimate:** S

## Description

Define the `Cell` class representing a single terminal cell position. Holds the grapheme cluster string, its style, and whether this cell is the second half of a wide character.

## Implementation

```dart
class Cell {
  String char;              // grapheme cluster (may be multi-byte)
  TextStyle style;          // active SGR attributes
  bool wideContinuation;    // true if second half of wide char
}
```

## Acceptance Criteria

- Default cell: char=' ', style=TextStyle.empty, wideContinuation=false
- Immutable-by-convention (fields can be final if desired)
- `==` and `hashCode` for diff comparison
- `clone()` or copy-constructor for frame snapshotting
