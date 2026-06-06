# Fix: StreamSink "bound to a stream" Error in AOT Compiled Executables

## Problem

When running the compiled example app (`./example_app`) in a real TTY and pressing 'q' to quit,
the app crashes with:

```
Unhandled exception:
Bad state: StreamSink is bound to a stream
#0      _StreamSinkImpl._controller (dart:io/io_sink.dart:235)
#1      _StreamSinkImpl.add (dart:io/io_sink.dart:155)
#2      _IOSinkImpl.write (dart:io/io_sink.dart:293)
#3      _StdSink._write (dart:io/stdio.dart:431)
#4      _StdSink.write (dart:io/stdio.dart:440)
#5      NativeIo.write (package:terminal/src/native_io.dart:18)
#6      AltScreenManager.exit (package:lifecycle/src/alt_screen_manager.dart:40)
#7      main (file:///Users/francesco/development/t22e/example/bin/example.dart:36)
```

## Root Cause

In Dart 3.12.1, when `stdin.listen()` is called on a real TTY, Dart's stdio implementation
creates an internal **bidirectional stream binding** between stdin and stdout for terminal I/O
handling. This binding persists even after `await subscription.cancel()` in AOT-compiled
executables.

When cleanup code calls `stdout.write()` (via `NativeIo.write()`), it hits the bound stream
sink's `_controller` getter which throws `StateError('StreamSink is bound to a stream')`.

This does NOT happen with `dart run` (JIT mode) — only in AOT-compiled executables.

## Why `_runApp`'s cleanup write succeeds but `altScreen.exit()` fails

The timing is subtle. `_runApp` writes `showCursor()` after `subscription.cancel()`, which
may succeed due to event loop timing. But `altScreen.exit()` runs in the `finally` block of
`main()`, after `_runApp` returns. By this point, the internal binding state may have been
re-established or the stream controller state changed.

## Solution Options

### Option A: File-based write in NativeIo

Replace `stdout.write()` with `File.fromStdout()` which bypasses Dart's stream binding:

```dart
// packages/terminal/lib/src/native_io.dart
@override
void write(String data) {
  File.fromStdout().writeAsStringSync(data, mode: FileMode.append);
}

@override
Future<void> flush() async {}
```

**Pros:**
- Simple, single-location change
- Guaranteed to work — bypasses Dart's stream binding entirely
- No API changes needed across packages

**Cons:**
- Slightly slower (file open/close per write) — negligible for TUI apps
- `File.fromStdout()` requires Dart 3.7+ (already satisfied: SDK ^3.12.0)

### Option B: Add `writeRaw()` method

Add a new method to `SystemIo` interface for bypassing the bound stream, use only in cleanup:

```dart
// packages/terminal/lib/src/system_io.dart
/// Writes data bypassing Dart's stdout stream binding.
void writeRaw(String data);

// packages/terminal/lib/src/native_io.dart
@override
void writeRaw(String data) {
  File.fromStdout().writeAsStringSync(data, mode: FileMode.append);
}

// packages/lifecycle/lib/src/alt_screen_manager.dart
void exit() {
  if (!value) return;
  _io.writeRaw(showCursor());
  if (_mouseEnabled.value) {
    _io.writeRaw(disableMouse());
    _mouseEnabled.value = false;
  }
  _io.writeRaw(exitAltScreen());
  _io.flush();
  value = false;
}
```

**Pros:**
- Targeted fix — only cleanup paths are affected
- Normal rendering keeps fast `stdout.write()`

**Cons:**
- Requires changes across multiple packages (terminal, lifecycle)
- More complex API surface
- Must update all cleanup paths (AltScreenManager, TerminalGuard, etc.)

### Option C: try-catch in cleanup

Wrap cleanup writes in try-catch since `guard.restore()` guarantees terminal restoration:

```dart
// packages/lifecycle/lib/src/alt_screen_manager.dart
void exit() {
  if (!value) return;
  try {
    _io.write(showCursor());
    if (_mouseEnabled.value) {
      _io.write(disableMouse());
      _mouseEnabled.value = false;
    }
    _io.write(exitAltScreen());
    _io.flush();
  } catch (_) {
    // Terminal will be restored by guard.restore()
  }
  value = false;
}
```

**Pros:**
- Minimal code change
- No API changes
- No performance impact

**Cons:**
- Hides the error rather than fixing it
- ANSI escape sequences may not be sent (terminal may not restore cursor/alt screen)
- Relies on `guard.restore()` as fallback

## Recommendation

**Option A** is the best balance of simplicity and correctness. The performance impact is
negligible for a TUI app (writes are already buffered at the OS level), and it completely
eliminates the binding issue at its source.

## Files Modified (per option)

### Option A
1. `packages/terminal/lib/src/native_io.dart` — change `write()` and `flush()`

### Option B
1. `packages/terminal/lib/src/system_io.dart` — add `writeRaw()` to interface
2. `packages/terminal/lib/src/native_io.dart` — implement `writeRaw()`
3. `packages/lifecycle/lib/src/alt_screen_manager.dart` — use `writeRaw()` in `exit()`
4. `packages/lifecycle/lib/src/terminal_guard.dart` — use `writeRaw()` in `restore()`

### Option C
1. `packages/lifecycle/lib/src/alt_screen_manager.dart` — wrap `exit()` in try-catch
2. `packages/lifecycle/lib/src/terminal_guard.dart` — wrap `restore()` in try-catch
