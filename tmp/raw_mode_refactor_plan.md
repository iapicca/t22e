# Plan: Raw Mode Only — Full Simplification (v4)

## Vision

Eliminate non-TTY branching and dead code paths, but **keep the I/O abstraction** (`SystemIo`, `TerminalIo`). Simplify lifecycle by removing `AltScreenManager`. Keep `TerminalGuard` as a callback-based lifecycle manager. Keep `SignalHandler`. Keep `capability` package.

---

## Phase 1: Terminal Package — Simplify (Keep SystemIo + TerminalIo)

### 1.1 Rename `FfiRawModeBackend` → `RawMode`

**File: `packages/terminal/lib/src/raw_mode.dart`** (new, replaces `ffi_raw_backend.dart`)

- Remove `io` parameter and `SystemIo` dependency
- Use `Platform.operatingSystem` directly for platform detection
- Remove Windows check entirely
- Keep `enable()` / `disable()` logic as-is (tcgetattr/tcsetattr via FFI)

### 1.2 Rewrite `NativeIo` — Remove `hasTerminal` guards

**File: `packages/terminal/lib/src/native_io.dart`**

Remove all `if (stdout.hasTerminal)` guards. Properties become direct:

```dart
@override
void write(String data) => stdout.write(data);

@override
Future<void> flush() => stdout.flush();

@override
bool get hasTerminal => stdout.hasTerminal;

@override
int get columns => stdout.terminalColumns;

@override
int get rows => stdout.terminalLines;

@override
bool get echoMode => stdin.echoMode;

@override
set echoMode(bool value) => stdin.echoMode = value;

@override
bool get lineMode => stdin.lineMode;

@override
set lineMode(bool value) => stdin.lineMode = value;

@override
String get operatingSystem => Platform.operatingSystem;
```

`hasTerminal` stays in the interface — used for the startup fail-fast check in the example app. No guards inside the implementation.

### 1.3 Keep `SystemIo` interface unchanged

**File: `packages/terminal/lib/src/system_io.dart`** — no changes. The interface is still the contract for `NativeIo`, `TerminalIo`, and testing.

### 1.4 Keep `TerminalIo` unchanged

**File: `packages/terminal/lib/src/terminal_io.dart`** — no changes. Still wraps `SystemIo` and exposes `write`/`flush`/`inputStream`.

### 1.5 Delete these files

| File | Reason |
|------|--------|
| `lib/src/runner.dart` | Only one backend now |
| `lib/src/io_raw_backend.dart` | FFI-only, no fallback |
| `lib/src/raw_mode_backend.dart` | Interface — only one impl |
| `lib/src/platform_service.dart` | Use `Platform` directly |
| `lib/src/mac_impl.dart` | Use `Platform` directly |
| `lib/src/linux_impl.dart` | Use `Platform` directly |

### 1.6 Keep these files (unchanged)

| File | Reason |
|------|--------|
| `lib/src/system_io.dart` | Interface — keep it |
| `lib/src/native_io.dart` | Concrete impl — simplified |
| `lib/src/terminal_io.dart` | Facade — keep it |
| `lib/src/raw_mode_state.dart` (+ `.freezed.dart`) | Captured termios state |
| `lib/src/termios_bindings.dart` | FFI bindings |
| `lib/src/symbols_ffi.dart` | FFI symbol names |
| `lib/src/pointer_extensions.dart` | FFI utilities |

### 1.7 Rewrite `lib/terminal.dart` (barrel)

```dart
export 'src/system_io.dart' show SystemIo;
export 'src/native_io.dart' show NativeIo;
export 'src/raw_mode.dart' show RawMode;
export 'src/raw_mode_state.dart' show RawModeState;
export 'src/terminal_io.dart' show TerminalIo, TerminalIoInterface;
export 'src/termios_bindings.dart' show TermiosBindings, GetAttr, SetAttr;
export 'src/symbols_ffi.dart' show SymbolsFFI;
export 'src/providers.dart';
```

### 1.8 Rewrite `lib/src/providers.dart`

```dart
@riverpod
SystemIo systemIo(Ref ref) => const NativeIo();

@riverpod
TerminalIo terminalIo(Ref ref) {
  return TerminalIo(io: ref.watch(systemIoProvider));
}

@riverpod
RawMode rawMode(Ref ref) {
  final mode = RawMode();
  ref.onDispose(mode.disable);
  return mode;
}
```

Remove: `termiosBindingsProvider`, `ioRawBackendProvider`, `ffiRawBackendProvider`, `terminalRunnerProvider`.

### 1.9 Update `pubspec.yaml`

- Remove `notifier` dependency
- Keep: `freezed_annotation`, `meta`, `protocol`, `riverpod`, `riverpod_annotation`, `ffi`

### 1.10 Delete test files

| File | Reason |
|------|--------|
| `test/runner_test.dart` | Tests for deleted classes |
| `test/providers_test.dart` | Rewrite for new simplified providers |
| `test/terminal_test.dart` | Re-exports deleted tests |

---

## Phase 2: Lifecycle Package — Simplify (Keep TerminalGuard + SignalHandler)

### 2.1 Delete `AltScreenManager`

**File: `lib/src/alt_screen_manager.dart`** — delete. ANSI writes go inline in the example app.

### 2.2 Rewrite `TerminalGuard` — Callback-based, no terminal dependencies

**File: `lib/src/terminal_guard.dart`**

```dart
import 'package:notifier/notifier.dart' show InitMixin, ValueNotifier, VoidCallback;

/// Manages terminal lifecycle state — ensures cleanup runs exactly once.
///
/// Why TerminalGuard is needed:
/// When a TUI app runs in raw mode with alternate screen enabled, the terminal
/// is in a non-standard state: line buffering is disabled, echo is off, and the
/// terminal is in the alternate screen buffer. If the process exits without
/// restoring the terminal, the user's shell will be left in a broken state —
/// commands won't echo, the prompt will be garbled, and the user may need to
/// run `reset` to recover.
///
/// TerminalGuard ensures restoration runs exactly once, whether the app exits
/// normally, throws an exception, or is interrupted by a signal.
class TerminalGuard extends ValueNotifier<bool> with InitMixin {
  final VoidCallback onRestore;

  TerminalGuard({required this.onRestore}) : super(false);

  bool get isRestored => value;

  void arm() {
    checkInit();
    value = false;
  }

  void restore() {
    if (value) return;
    value = true;
    onRestore();
  }

  void disarm() {
    value = true;
  }

  void runGuarded<T>(T Function() body) {
    checkInit();
    try {
      body();
    } finally {
      restore();
    }
  }

  @override
  void dispose({String? message}) {
    restore();
    super.dispose(message: message);
  }
}
```

Key points:
- No `TerminalRunner` dependency
- No `AltScreenManager` dependency
- No `SystemIo` / `TerminalIo` dependency
- Pure state machine + callback
- All existing API preserved: `arm()`, `restore()`, `disarm()`, `runGuarded()`

### 2.3 Rewrite `SignalHandler` — Accept `onCleanup` callback

**File: `lib/src/signal_handler.dart`**

Change from:
```dart
SignalHandler({required TerminalGuard _guard, ...})
```

To:
```dart
SignalHandler({
  required VoidCallback onInterrupt,
  required VoidCallback onCleanup,  // called on SIGTERM, SIGTSTP
  required Stream<io.ProcessSignal> sigint,
  required Stream<io.ProcessSignal> sigterm,
  required Stream<io.ProcessSignal> sigtstp,
  required Stream<io.ProcessSignal> sigcont,
})
```

**Why SignalHandler is needed:**
> When a TUI app runs in raw mode with alternate screen enabled, the terminal is in a non-standard state: line buffering is disabled, echo is off, and the terminal is in the alternate screen buffer. If the process is killed (SIGTERM), suspended (SIGTSTP), or interrupted (SIGINT) without restoring the terminal, the user's shell will be left in a broken state — commands won't echo, the prompt will be garbled, and the user may need to run `reset` to recover. SignalHandler ensures terminal restoration on any signal-triggered exit path.

### 2.4 Rewrite `lib/src/providers.dart`

Remove `altScreenManagerProvider`. Keep `terminalGuardProvider` (simplified, accepts `onRestore` callback) and `signalHandlerProvider` (updated signature with `onCleanup`). Keep signal stream providers.

### 2.5 Update `lib/lifecycle.dart` (barrel)

Remove `AltScreenManager` export. Keep `TerminalGuard`, `SignalHandler`, `ProcessSignal`, `ProcessResult`, signal providers.

### 2.6 Update `pubspec.yaml`

- Remove `terminal` dependency
- Remove `ansi` dependency
- Keep: `protocol`, `freezed_annotation`, `meta`, `notifier`, `riverpod`, `riverpod_annotation`

### 2.7 Delete/rewrite test files

| File | Action |
|------|--------|
| `test/terminal_guard_test.dart` | Rewrite for callback-based TerminalGuard |
| `test/signal_handler_test.dart` | Rewrite for updated SignalHandler |

---

## Phase 3: Capability Package — Keep, Remove TerminalIo Dependency

### 3.1 Rewrite probe functions

Replace `TerminalIoInterface` parameter with `IOSink out` + `Stream<List<int>> inputStream`:

| File | Change |
|------|--------|
| `lib/src/color_probe.dart` | `probeColor(IOSink out, Stream<List<int>> in, ...)` |
| `lib/src/sync_probe.dart` | `probeSync(IOSink out, Stream<List<int>> in, ...)` |
| `lib/src/keyboard_probe.dart` | `probeKeyboard(IOSink out, Stream<List<int>> in, ...)` |
| `lib/src/da1_probe.dart` | `probeDa1(IOSink out, Stream<List<int>> in, ...)` |

### 3.2 Rewrite `terminal_probe_extension.dart`

Replace extension on `TerminalIoInterface` with standalone function:
```dart
Future<R> probeTerminal<T, R>({
  required String query,
  required IOSink out,
  required Stream<List<int>> inputStream,
  required TerminalParser parser,
  required Duration timeout,
  required R Function(T event) onEvent,
  required R Function() onTimeout,
  bool Function(T event)? where,
})
```

### 3.3 Rewrite probe providers

Replace `terminalIoProvider` references with `stdout`/`stdin` directly.

### 3.4 Update `pubspec.yaml`

- Remove `terminal` dependency

---

## Phase 4: Example App — Rewrite

### 4.1 Update `pubspec.yaml`

Keep all current dependencies. No removals needed (lifecycle stays for `TerminalGuard` + `SignalHandler`).

### 4.2 Rewrite `bin/example.dart`

Uses:
- `terminalIoProvider` for I/O (write, flush, inputStream, columns, rows)
- `rawModeProvider` for raw mode
- `terminalGuardProvider` for lifecycle (cleanup callback passed in)
- `signalHandlerProvider` for signal handling
- No `hasTty` branching — always raw mode

Key structural changes:
- `stdin` accessed via `terminalIo.inputStream` (through interface)
- `stdout` accessed via `terminalIo.write()` / `terminalIo.flush()` (through interface)
- `terminalIo.io.columns` / `terminalIo.io.rows` for dimensions
- `rawMode.disable()` called **before** ANSI writes (structural fix for StreamSink bug)
- `TerminalGuard` wraps cleanup: `onRestore: () { rawMode.disable(); terminalIo.write(showCursor()); terminalIo.write(exitAltScreen()); terminalIo.flush(); }`

---

## Phase 5: Remove Testing Package

Delete `packages/testing/` entirely.

---

## Phase 6: README Updates

### 6.1 Root `README.md`

**Add Requirements section** (before Quick Start):
```markdown
## Requirements

- **Real terminal (TTY) required** — the app does not support piped or redirected I/O
- **macOS or Linux** — Windows is not supported
- Dart SDK `^3.12.0`
```

**Update package table** — remove `testing` row, update `terminal` and `lifecycle` descriptions.

### 6.2 `packages/terminal/README.md` — Rewrite

```markdown
# terminal

Terminal raw mode management via FFI.

## Purpose

Disables line buffering and echo so the TUI receives individual keystrokes.
Uses libc `tcgetattr`/`tcsetattr` on macOS and Linux.

## Requirements

- Real terminal (TTY) — piped or redirected I/O is not supported
- macOS or Linux — Windows is not supported

## Exports

- **RawMode** — enable/disable terminal raw mode via FFI
- **SystemIo** — I/O abstraction interface (stdin/stdout wrapper)
- **NativeIo** — concrete SystemIo implementation using dart:io
- **TerminalIo** — facade for input stream, write, flush, dimensions
- **RawModeState** — captured termios state with auto-restore
- **TermiosBindings** — FFI bindings to libc
- **Riverpod providers** — managed terminal instances

## Usage

```dart
final rawMode = container.read(rawModeProvider);
final terminalIo = container.read(terminalIoProvider);

rawMode.enable();
terminalIo.write('Hello');
terminalIo.flush();
// ... read terminalIo.inputStream ...
rawMode.disable();
```

Terminal state is automatically saved on `enable()` and restored on `disable()`.
```

### 6.3 `packages/lifecycle/README.md` — Rewrite

```markdown
# lifecycle

Application lifecycle management — terminal restoration and signal handling.

## Purpose

Ensures the terminal is restored to its normal state on any exit path — normal
exit, unhandled exception, or POSIX signal (SIGINT, SIGTERM, SIGTSTP).

## Why TerminalGuard is needed

When a TUI app runs in raw mode with alternate screen enabled, the terminal is
in a non-standard state: line buffering is disabled, echo is off, and the
terminal is in the alternate screen buffer. If the process exits without
restoring the terminal, the user's shell will be left in a broken state —
commands won't echo, the prompt will be garbled, and the user may need to run
`reset` to recover.

TerminalGuard ensures restoration runs exactly once via a cleanup callback,
whether the app exits normally, throws, or is interrupted.

## Why SignalHandler is needed

If the process receives SIGTERM (kill), SIGTSTP (Ctrl+Z), or SIGINT (Ctrl+C),
the normal exit path is bypassed. SignalHandler catches these signals and
triggers terminal restoration before the process exits.

## Exports

- **TerminalGuard** — lifecycle state machine with cleanup callback
- **SignalHandler** — POSIX signal handling with customizable callbacks
- **ProcessSignal** — sealed class: `Sigint`, `Sigterm`, `Sigtstp`, `Sigcont`
- **ProcessResult** — sealed class: `ProcessSuccess`, `ProcessTimeout`
- **Riverpod providers** — managed lifecycle components
```

### 6.4 `packages/capability/README.md` — Rewrite (comprehensive)

```markdown
# capability

Terminal capability probing — detect what features the terminal supports.

## Purpose

Before rendering, a TUI app should detect what the terminal supports to adapt
its output. This package probes:

- **Color profile** — ANSI 16, 256-color, or truecolor (24-bit RGB)
- **Synchronized updates** — whether the terminal supports DEC 2026 sync mode
  (prevents rendering tearing during frame updates)
- **Keyboard protocol** — whether the terminal supports Kitty keyboard
  protocol (disambiguates keys, reports modifiers, unicode codepoints)
- **DA1 (Device Attributes)** — terminal identity and feature flags via
  primary device attributes query

Each probe sends an ANSI query sequence to the terminal, waits for a response,
and falls back to environment variables (`COLORTERM`, `TERM`) or conservative
defaults if the terminal doesn't respond.

## How probing works

1. Send an ANSI query sequence (e.g., OSC 10 for color, CSI c for DA1)
2. Wait for the terminal to respond via stdin
3. Parse the response into a typed result
4. If the probe times out, fall back to environment variables or defaults

Results are aggregated into a `Capabilities` object containing color profile,
sync support, keyboard protocol, DA1 attributes, and terminal dimensions.

## Exports

- **Capabilities** — aggregated probe results
- **QueryResult** — sealed class: `Supported<T>`, `Unavailable`
- **Da1Result** — parsed DA1 response with terminal attributes
- **KeyboardProtocol** — enum: `basic`, `kitty`
- **Color probe** — detects color profile via OSC + env + DA1 fallback
- **Sync probe** — detects synchronized update support via DECRPM
- **Keyboard probe** — detects Kitty keyboard protocol support
- **DA1 probe** — queries terminal identity and feature flags
- **Riverpod providers** — managed probe functions

## Usage

```dart
final caps = await container.read(capabilitiesProvider).future;
print(caps.colorProfile);    // ColorProfile.trueColor
print(caps.syncSupported);   // true
print(caps.keyboardProtocol); // KeyboardProtocol.kitty
```

Probes are async and may take up to the configured timeout (default 100ms).
Run them once at startup before entering the main render loop.
```

### 6.5 `example/README.md` — Update

**Strengthen requirements:**
```markdown
## Requirements

- **Real terminal (TTY) required** — this app cannot run with:
  - Piped input: `echo "hello" | dart run bin/example.dart`
  - Redirected output: `dart run bin/example.dart > output.txt`
  - Non-interactive shells (CI, cron, etc.)
- macOS or Linux — Windows is not supported
- Dart SDK `^3.12.0`
```

**Add Troubleshooting section:**
```markdown
## Troubleshooting

### App exits immediately with no output
You are not running in a real terminal. This app requires an interactive TTY.
If you need to run tests, use `melos test` instead.
```

### 6.6 `.ai/code-standards.md` — Update

**Terminal I/O section:**
- "All I/O goes through `SystemIo`/`TerminalIo` interfaces. stdin/stdout are never accessed directly."
- "Raw mode is managed via `RawMode` using libc FFI (`tcgetattr`/`tcsetattr`)"
- "All apps require a real terminal (TTY)"
- "TerminalGuard manages lifecycle state with a cleanup callback"
- "SignalHandler restores terminal on POSIX signals"

---

## Phase 7: Verification

### 7.1 Build
```bash
melos build
```

### 7.2 Analyze
```bash
melos analyze
```

### 7.3 Format
```bash
melos format
```

### 7.4 Manual test
```bash
cd example
dart compile exe bin/example.dart -o example_app
./example_app
# Press q — verify clean exit, no StreamSink error
```

---

## Files Changed Summary

### Deleted (16 files + 1 directory)

| Path | Reason |
|------|--------|
| `packages/testing/` (entire directory) | User wants removed |
| `packages/terminal/lib/src/runner.dart` | Only one backend now |
| `packages/terminal/lib/src/io_raw_backend.dart` | FFI-only, no fallback |
| `packages/terminal/lib/src/raw_mode_backend.dart` | Interface — only one impl |
| `packages/terminal/lib/src/platform_service.dart` | Use `Platform` directly |
| `packages/terminal/lib/src/mac_impl.dart` | Use `Platform` directly |
| `packages/terminal/lib/src/linux_impl.dart` | Use `Platform` directly |
| `packages/terminal/test/runner_test.dart` | Tests for deleted classes |
| `packages/terminal/test/providers_test.dart` | Tests for deleted providers |
| `packages/terminal/test/terminal_test.dart` | Re-exports deleted tests |
| `packages/lifecycle/lib/src/alt_screen_manager.dart` | ANSI writes inline in app |
| `packages/lifecycle/test/terminal_guard_test.dart` | Needs rewrite |
| `packages/lifecycle/test/signal_handler_test.dart` | Needs rewrite |
| `example/test/compile_smoke_test.dart` | Depends on deleted setup |
| `example/test/e2e_smoke_test.dart` | Depends on deleted setup |

### Created (1 file)

| Path | Reason |
|------|--------|
| `packages/terminal/lib/src/raw_mode.dart` | Renamed from ffi_raw_backend.dart, simplified |

### Modified (26 files)

| Path | Change |
|------|--------|
| `packages/terminal/lib/src/native_io.dart` | Remove hasTerminal guards |
| `packages/terminal/lib/terminal.dart` | Update exports |
| `packages/terminal/lib/src/providers.dart` | Simplified providers |
| `packages/terminal/pubspec.yaml` | Remove notifier |
| `packages/lifecycle/lib/lifecycle.dart` | Remove AltScreenManager export |
| `packages/lifecycle/lib/src/terminal_guard.dart` | Callback-based |
| `packages/lifecycle/lib/src/signal_handler.dart` | onCleanup callback |
| `packages/lifecycle/lib/src/providers.dart` | Remove altScreenManagerProvider |
| `packages/lifecycle/pubspec.yaml` | Remove terminal, ansi |
| `packages/capability/lib/src/color_probe.dart` | Remove TerminalIoInterface |
| `packages/capability/lib/src/sync_probe.dart` | Remove TerminalIoInterface |
| `packages/capability/lib/src/keyboard_probe.dart` | Remove TerminalIoInterface |
| `packages/capability/lib/src/da1_probe.dart` | Remove TerminalIoInterface |
| `packages/capability/lib/src/terminal_probe_extension.dart` | Standalone function |
| `packages/capability/lib/src/color_probe_provider.dart` | Remove terminalIoProvider |
| `packages/capability/lib/src/sync_probe_provider.dart` | Remove terminalIoProvider |
| `packages/capability/lib/src/keyboard_probe_provider.dart` | Remove terminalIoProvider |
| `packages/capability/lib/src/da1_probe_provider.dart` | Remove terminalIoProvider |
| `packages/capability/lib/src/capabilities_provider.dart` | Use stdout for dims |
| `packages/capability/pubspec.yaml` | Remove terminal |
| `example/bin/example.dart` | Rewrite — no hasTty |
| `README.md` | Requirements + table update |
| `packages/terminal/README.md` | Complete rewrite |
| `packages/lifecycle/README.md` | Complete rewrite |
| `packages/capability/README.md` | Complete rewrite |
| `example/README.md` | Update requirements, add troubleshooting |
| `.ai/code-standards.md` | Update Terminal I/O section |
