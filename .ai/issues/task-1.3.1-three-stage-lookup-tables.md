# Task 1.3.1: 3-Stage Lookup Tables

**Story:** Unicode Width Tables
**Estimate:** L

## Description

Generate and implement the 3-stage lookup table structure for O(1) Unicode character property queries. Stage1 indexes into Stage2, Stage2 indexes into Stage3, Stage3 holds property bytes (width, emoji, printable, private flags).

## Implementation

```
Stage1[high_byte] → offset into Stage2
Stage2[offset + low_byte] → index into Stage3
Stage3[index] → property byte
```

## Acceptance Criteria

- Lookup is O(1) — at most 3 array accesses and 2 additions
- Property byte encodes: 2 bits for width (0/1/2/3=ambiguous), 1 bit emoji, 1 bit printable, 1 bit private
- Table data is auto-generated from Unicode Character Database (script in `tool/`)
- Table sizes are minimized (typical Dart implementation: Stage1 ≈ 0.8KB, Stage2 ≈ 18KB, Stage3 ≈ 8KB)
- Generator script is included in `tool/generate_unicode_tables.dart`
- Tables are shipped as const Uint8List or similar
