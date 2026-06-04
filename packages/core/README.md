# core

Core terminal data structures.

## Purpose

Foundational data model layer — the cell grid, styling system, geometry types,
and layout system that widgets paint onto and the renderer reads from.

## Exports

- **Geometry**: `Point`, `Rect`, `Insets` with containment, intersection,
  union, inset, and inflate operations
- **Color**: `Color` with all 16 ANSI constants, `AnsiColor`, `IndexedColor`,
  conversion utilities, `ColorProfile` enum
- **Cell**: `{char, style, wideContinuation, hyperlink}` with style merging
- **TextStyle**: color resolution, attribute flags, inheritance, hyperlink
- **Surface**: grid-based terminal canvas with `putChar()`, `putText()`,
  `fillRect()`, `clearRect()`, `drawBorder()`, `toAnsiLines()`, `resize()`
- **Layout**: `Constraints`, `Size`, `LayoutItem`, `splitHorizontal()`,
  `splitVertical()` — flexbox-like space distribution

## Usage

Create a `Surface` with terminal dimensions, paint cells using `putText()` or
`drawBorder()`, then pass to renderer for ANSI output. Use layout functions to
calculate widget sizes before painting.
