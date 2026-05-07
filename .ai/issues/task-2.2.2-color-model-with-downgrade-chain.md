# Task 2.2.2: Color Model with Downgrade Chain

**Story:** TextStyle & Color Resolution
**Estimate:** M

## Description

Implement the Color class with kind discrimination (noColor, ansi, indexed, rgb) and a downgrade chain: TrueColor → 256-color palette → ANSI 16 → no color. Conversion uses proper algorithms (6×6×6 cube for rgb→indexed, redmean distance for nearest color).

## Implementation

```dart
enum ColorKind { noColor, ansi, indexed, rgb }

class Color {
  final ColorKind kind;
  final int value; // interpretation depends on kind

  Color convert(ColorKind target); // never upgrades, only downgrades
  String sequence({bool background}); // produce \x1b[38;...m or \x1b[48;...m
}

enum ColorProfile { noColor, ansi16, indexed256, trueColor }
```

## Acceptance Criteria

- `convert()` from rgb → indexed: use 6×6×6 cube + grayscale ramp
- `convert()` from indexed → ansi: use palette mapping
- `convert()` never upgrades (ansi → rgb is a no-op)
- `sequence()` produces correct ANSI for each kind
- ColorProfile is used to configure terminal capability
- Unit tests: each conversion path, color equality, sequence output
