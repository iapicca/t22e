# parser

Terminal input parser with VT500 state machine.

## Purpose

Transforms raw byte streams from stdin into structured events. The input side
of terminal communication.

## Exports

- **Vt500Engine** — 12-state byte-level state machine
- **TerminalParser** — composes engine with semantic parsers
- **SequenceData** — sealed hierarchy: `CharData`, `CsiSequenceData`,
  `EscSequenceData`, `OscSequenceData`, `DcsSequenceData`
- **Events** — `KeyEvent`, `MouseEvent`, `PasteEvent`, `CursorPositionEvent`,
  `ColorQueryEvent`, `WindowResizeEvent`, `FocusEvent`, and more
- **KeyCode** enum — all logical keys including F1-F24
- **Parser functions** — `parseCsi()`, `parseEsc()`, `parseOsc()`, `parseDcs()`
- **Riverpod providers** — parser instances for dependency injection

## Usage

Feed raw bytes into `Vt500Engine` to produce `SequenceData`, then pass through
`TerminalParser` to get typed `Event` objects. Use Riverpod providers for
managed instances.
