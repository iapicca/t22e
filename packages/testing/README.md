# testing

Widget testing utilities with virtual terminal.

## Purpose

Headless testing environment for widgets. Simulates a real terminal by
interpreting ANSI output and provides assertion helpers.

## Exports

- **VirtualTerminal** — in-memory terminal grid interpreting ANSI sequences.
  Methods: `write()`, `cellAt()`, `plainText()`, `resize()`
- **WidgetTester** — drives widgets with simulated input. Methods:
  `pumpWidget()`, `pumpWidgetWithModel()`, `sendKeyEvent()`,
  `sendMouseEvent()`, `expectCell()`, `expectPlainText()`
- **TestFailure** — exception for test assertions
- **Riverpod providers** — managed test instances

## Usage

Create a `WidgetTester`, pump a widget or model, send simulated events, then
assert on rendered output with `expectCell()` or `expectPlainText()`.
