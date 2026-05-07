# Feature: Terminal Foundation

**Phase:** 1
**Priority:** P0 - Must have
**Depends on:** None

## Description

Build the foundational terminal layer: ANSI escape code constants, raw mode setup, Unicode width tables, and a VT500-compatible input parser. This is the bedrock every TUI depends on.

## Stories

| # | Story | Est. |
|---|-------|------|
| 1.1 | ANSI Escape Code Definitions | M |
| 1.2 | Raw Mode & Terminal I/O | M |
| 1.3 | Unicode Width Tables | L |
| 1.4 | Input Parser (VT500) | XL |

## Acceptance Criteria

- All ANSI sequences are available as pure constants with zero I/O side effects
- Raw mode can be enabled/disabled via both dart:io fallback and FFI to libc
- Unicode character width can be queried in O(1) via 3-stage lookup tables
- Grapheme clusters (emoji ZWJ, CJK wide chars) are handled correctly
- VT500 input parser correctly processes all byte sequences and emits structured events
