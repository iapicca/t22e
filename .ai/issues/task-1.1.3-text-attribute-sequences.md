# Task 1.1.3: Text Attribute Sequences

**Story:** ANSI Escape Code Definitions
**Estimate:** S

## Description

Implement functions producing ANSI SGR sequences for text attributes: bold, dim, italic, underline, blink, reverse, strikethrough, overline, and combined attribute sets.

## Implementation

```dart
// ansi/codes.dart (alongside constants)
String bold(bool on) => on ? '\x1b[1m' : '\x1b[22m';
String dim(bool on) => on ? '\x1b[2m' : '\x1b[22m';
String italic(bool on) => on ? '\x1b[3m' : '\x1b[23m';
// ... etc
```

## Acceptance Criteria

- Each text attribute has an on/off function pair
- Bold/dim share the same reset (22), italic/underline/etc have distinct resets
- All functions are pure
- Unit tests verify exact output
