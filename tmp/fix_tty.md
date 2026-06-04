# Fix: TTY Detection for Non-Interactive Environments

## Problem

`NativeIo.columns` and `NativeIo.rows` call `stdout.terminalColumns` and `stdout.terminalLines` which throw `StdoutException` when stdout is not a TTY (e.g., piped to a subprocess, CI, or redirected to a file). This prevents the example app from running in integration tests.

## Root Cause

`packages/terminal/lib/src/native_io.dart:23-26` directly accesses `stdout.terminalColumns`/`stdout.terminalLines` without checking `stdout.hasTerminal`.

## Proposed Fix

### Option A: Safe getters in `NativeIo` (Recommended)

Modify `NativeIo` to check `stdout.hasTerminal` before accessing dimensions:

```dart
@override
int get columns => stdout.hasTerminal ? stdout.terminalColumns : Defaults.defaultTerminalWidth;

@override
int get rows => stdout.hasTerminal ? stdout.terminalLines : Defaults.defaultTerminalHeight;
```

**Pros:**
- Minimal change, single location
- Uses existing `Defaults` constants already used throughout the codebase
- No API surface change — consumers don't need to adapt

**Cons:**
- `NativeIo` needs to import `protocol` for `Defaults` (currently no dependency on it)

## Recommendation

**Option A** is the best balance of simplicity and correctness.

## Files to Modify

1. `packages/terminal/pubspec.yaml` — add `protocol` as dependency (if not already)
2. `packages/terminal/lib/src/native_io.dart` — add import for `protocol`, update `columns`/`rows` getters
