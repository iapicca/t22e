# Story 5.3: Testing & Quality

**Feature:** Polish & Advanced
**Estimate:** M
**Depends on:** Surface (2.1), all widgets

## Description

Build testing infrastructure: a virtual terminal that captures output for deterministic testing, widget test utilities, and performance benchmarks.

## Tasks

| # | Task | Est. |
|---|------|------|
| 5.3.1 | Virtual terminal for tests | M |
| 5.3.2 | Widget test utilities | M |

## Acceptance Criteria

- Virtual terminal: an in-memory terminal emulator that processes ANSI sequences and maintains a cell grid
- Virtual terminal: supports SGR, cursor movement, erase, scrollback
- Widget tests: render a widget into the virtual terminal and inspect cell states
- Widget tests: simulate key events and verify state changes
- Screenshot testing: compare virtual terminal output to expected output
- CI integration: all tests run without a real terminal
- Performance benchmarks: automated timing of renderer, parser, layout operations
- Regression detection: benchmark thresholds that fail if performance degrades
