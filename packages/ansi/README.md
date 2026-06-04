# ansi

ANSI escape sequence builders for terminal interaction.

## Purpose

Converts high-level operations into raw ANSI escape sequence strings. The
output side of terminal communication.

## Exports

- **SGR builders**: `bold()`, `dim()`, `italic()`, `underline()`, `blink()`,
  `reverse()`, `strikethrough()`, `overLine()`, `resetAll()`
- **Color builders**: `setForegroundRgb()`, `setBackgroundRgb()`,
  `setForeground256()`, `setBackground256()`, `foregroundAnsi()`,
  `backgroundAnsi()`, `resetColor()`
- **Cursor builders**: `moveTo()`, `moveUp/Down/Right/Left()`, `hideCursor()`,
  `showCursor()`, `saveCursor()`, `restoreCursor()`, `setStyle()`
- **Erase builders**: `eraseDisplay()`, `eraseLine()`, `eraseScreen()`,
  `eraseSavedLines()`
- **Terminal modes**: `enterAltScreen()`, `exitAltScreen()`, `enableMouse()`,
  `startSync()`, `endSync()`, `enableBracketedPaste()`, `setTitle()`,
  `hyperlink()`, Kitty keyboard controls, color/cursor queries

## Usage

Call builder functions to produce escape sequence strings. Pass results to
terminal output or combine into larger sequences.
