# Task 1.3.2: Character Width Querying

**Story:** Unicode Width Tables
**Estimate:** S

## Description

Implement the public API for querying character width and properties using the 3-stage lookup tables.

## Implementation

```dart
int charWidth(int codepoint) { ... }  // 0, 1, or 2
bool isEmoji(int codepoint) { ... }
bool isPrintable(int codepoint) { ... }
bool isWide(int codepoint) { ... }    // width == 2
bool isAmbiguousWidth(int codepoint) { ... }
```

## Acceptance Criteria

- All query functions complete in O(1) time
- Width returns 0 for zero-width chars (combining marks, ZWJ, ZWNJ, etc.)
- Width returns 2 for CJK ideographs, fullwidth forms, emoji
- Width returns 1 for everything else
- Ambiguous-width flag is exposed for terminal-specific resolution
- Unit tests cover edge cases: combining sequences, soft hyphens, zero-width space, fullwidth letters
