# Terminal Package Refactoring Plan

## Architecture After Refactoring

```
Platform.operatingSystem  (dart:io, used only in providers)
         │
    ┌────┴────┐
    ▼         ▼
libcProvider  termiosProvider
(DynamicLib)  (Termios: LinuxTermios | MacosTermios)
    │              │
    └──────┬───────┘
           ▼
   termiosBindingsProvider
   (TermiosBindings)
           │
    ┌──────┴──────┐
    ▼             ▼
rawModeProvider  systemIoProvider
(RawMode         (TerminalIo + ValueNotifier<SystemContext>)
 as ValueNotifier             │
 <RawModeState>)        SIGWINCH → NativeCallable.listener + sigaction
                        → reads stdout.terminalColumns/Lines
                        → updates SystemContext.value
```

---

## Phase 0 — Write the plan file

- [x] Write plan to `./tmp/terminal_refactor.md`

---

## Phase 1 — Platform Abstraction (no behavior change)

### Step 1.1 — Convert `Termios` to sealed class with platform subclasses

**Modify** `packages/terminal/lib/src/termios.dart`:
- `final class Termios` → `sealed class Termios` with const constructor
- Remove `dart:io` import (no more `Platform.operatingSystem`)
- Shared constants stay on base class: `termiosEcho`, `termiosICanon`, `termiosISig`, `termiosIExten`, `termiosVminRaw`, `termiosVtimeRaw`, `tcsaNow`, `stdinFd`
- Platform-specific members become abstract getters:
  - `int get termiosStructSize`
  - `int get termiosOffsetIFlag`
  - `int get termiosOffsetOFlag`
  - `int get termiosOffsetCFlag`
  - `int get termiosOffsetLFlag`
  - `int get termiosOffsetCCMin`
  - `int get termiosOffsetCCTime`
  - `int readFlag(Pointer<Uint8> buf, int offset)`
  - `void writeFlag(Pointer<Uint8> buf, int offset, int value)`
- Remove `_isMacOS`, `_tcflagSize`, `_ccOffset`, `_vminIndex`, `_vtimeIndex`
- Remove static `readFlag`/`writeFlag` — they become instance methods on subclasses

**Create** `packages/terminal/lib/src/termios_linux.dart`:
- `final class LinuxTermios extends Termios` with `const` constructor
- tcflag_t = 4 bytes (unsigned int)
- Offsets: c_iflag=0, c_oflag=4, c_cflag=8, c_lflag=12, ccOffset=17, vminIndex=6, vtimeIndex=5
- `readFlag` → `buf.read32(offset)`, `writeFlag` → `buf.write32(offset, value)`
- `termiosStructSize` = 60

**Create** `packages/terminal/lib/src/termios_macos.dart`:
- `final class MacosTermios extends Termios` with `const` constructor
- tcflag_t = 8 bytes (unsigned long)
- Offsets: c_iflag=0, c_oflag=8, c_cflag=16, c_lflag=24, ccOffset=32, vminIndex=16, vtimeIndex=17
- `readFlag` → `buf.read64(offset)`, `writeFlag` → `buf.write64(offset, value)`
- `termiosStructSize` = 72

### Step 1.2 — Rename `TermiosBindings`

**Modify** `packages/terminal/lib/src/termios_bindings.dart`:
- Rename `abstract class TermiosBindings` → `abstract class TermiosBindings` with `const factory TermiosBindings(DynamicLibrary library) = _TermiosBindings;`
- Rename `final class TermiosBindingsImpl` → `final class _TermiosBindings implements TermiosBindings` (private)
- `malloc`/`free` function lookups cached in constructor fields (not looked up on every call)
- Remove `late` keywords — use real initializing formals

### Step 1.3 — Create `OperatingSystem` enum

**Create** `packages/terminal/lib/src/operating_system.dart`:
```dart
enum OperatingSystem { macOS, linux, windows }
```

### Step 1.4 — Replace `openLibc()` with Riverpod provider, delete `extensions.dart`

**Create** `packages/terminal/lib/src/libc_provider.dart`:
- `@riverpod DynamicLibrary libc(Ref ref)` — reads `Platform.operatingSystem`, opens correct libc:
  - `'macos'` → `DynamicLibrary.open(SymbolsFFI.libcMacOS)`
  - `'linux'` → glibc first (`libc.so.6`), then musl (`libc.musl-x86_64.so.1`, `libc.musl-aarch64.so.1`)
  - Uses import of `dart:io` for `Platform`

**Delete** `packages/terminal/lib/src/extensions.dart`:
- The `DynamicLibraryFfi` extension and `openLibc()` function are no longer needed
- `freePointer` is replaced by `TermiosBindings.free()`

### Step 1.5 — Provider for `TermiosBindings`

**Create** `packages/terminal/lib/src/termios_bindings_provider.dart`:
- `@riverpod TermiosBindings termiosBindings(Ref ref)` — reads `libcProvider` and returns `TermiosBindings(libc)`

### Step 1.6 — Provider for `Termios`

**Create** `packages/terminal/lib/src/termios_provider.dart`:
- `@riverpod Termios termios(Ref ref)` — reads `Platform.operatingSystem` and returns `const MacosTermios()` or `const LinuxTermios()`

### Step 1.7 — Update barrel exports

**Modify** `packages/terminal/lib/terminal.dart`:
- Add exports for new files: `termios_linux.dart`, `termios_macos.dart`, `operating_system.dart`, `libc_provider.dart`, `termios_bindings_provider.dart`, `termios_provider.dart`
- Remove export for `extensions.dart`
- Export `Termios` from `termios.dart` (sealed class with subclasses)

---

## Phase 2 — RawMode Cleanup (no behavior change)

### Step 2.1 — Rename `RawModeStateData` → `RawModeState`

**Modify** `packages/terminal/lib/src/raw_mode_state.dart`:
- Rename `RawModeStateData` → `RawModeState`
- Rename factory constructor accordingly
- Rename `_RawModeStateData` → `_RawModeState`
- Keep `Pointer<Uint8> buf` field (needed for buffer lifecycle in dispose)

### Step 2.2 — Delete `RawModeState` typedef

**Modify** `packages/terminal/lib/src/raw_mode_state.dart`:
- Delete: `typedef RawModeState = ValueNotifier<RawModeStateData?>;`

### Step 2.3 — Make `RawModeInterface` a `ValueNotifier<RawModeState?>`

**Modify** `packages/terminal/lib/src/raw_mode.dart`:
- `abstract class RawModeInterface with InitMixin, Disposable`:
  - Change to: `abstract class RawModeInterface extends ValueNotifier<RawModeState?> with InitMixin, Disposable`
  - Remove `RawModeState get state` getter (value is inherited from `ValueNotifier`)
- `final class RawMode extends RawModeInterface`:
  - Constructor takes `required TermiosBindings bindings, required Termios termios`
  - Remove `DynamicLibrary _library` late field
  - Remove `RawModeState _state` late field (the `ValueNotifier`'s `value` property replaces it)
  - `init()` uses `bindings.malloc()`, `bindings.tcGetAttr`, `bindings.tcSetAttr`
  - `dispose()` uses `bindings.free()` and `bindings.tcSetAttr`
  - All `DynamicLibrary.lookupFunction` calls removed
  - Rename `_state` references to `value` (inherited from `ValueNotifier`)

### Step 2.4 — Update `rawModeProvider`

**Modify** `packages/terminal/lib/src/raw_mode_provider.dart`:
- Read `termiosBindingsProvider` and `termiosProvider` from `ref`
- Construct: `RawMode(bindings: bindings, termios: termios)`

---

## Phase 3 — SystemContext + Resize Detection (new behavior)

### Step 3.1 — Create `SystemContext` freezed class

**Create** `packages/terminal/lib/src/system_context.dart`:
```dart
@freezed
abstract class SystemContext with _$SystemContext {
  const factory SystemContext({
    required int width,
    required int height,
    required bool hasTerminal,
    required OperatingSystem operatingSystem,
    @Default({}) Map<String, String> environment,
  }) = _SystemContext;
}
```

### Step 3.2 — Reduce `SystemIo` to core I/O + `ValueNotifier<SystemContext>`

**Modify** `packages/terminal/lib/src/system_io.dart`:
- Remove getters: `columns`, `rows`, `hasTerminal`, `echoMode`, `lineMode`, `echoMode` setter, `lineMode` setter, `operatingSystem`, `environment`
- Add: `ValueNotifier<SystemContext> get context`
- Keep: `inputStream`, `write()`, `flush()`
- The mixin stays focused on I/O operations only

### Step 3.3 — Implement `TerminalIo` with SIGWINCH via `sigaction`

**Modify** `packages/terminal/lib/src/terminal_io.dart`:
- Remove `echoMode`, `lineMode`, `hasTerminal`, `columns`, `rows`, `operatingSystem`, `environment` implementations
- Constructor becomes non-const: `TerminalIo()` — sets up SIGWINCH handler
- Add `_context` field: `final _context = ValueNotifier<SystemContext>(...)` initialized with current dimensions from `stdout.terminalColumns`/`terminalLines`
- `@override ValueNotifier<SystemContext> get context => _context;`
- Add `Disposable` to the class declaration
- `_initSigwinch()` method:
  - Uses `DynamicLibrary` from `libc.point` (or `openLibc()` until Phase 1 is complete) to look up `sigaction`
  - Allocates 256-byte buffer, zeros it
  - Creates `NativeCallable<Void Function(Int32)>.listener` callback that:
    - Reads `stdout.terminalColumns`/`terminalLines`
    - Updates `_context.value` with new `SystemContext` (copyWith width/height)
  - Writes `callback.nativeFunction.cast<Pointer<Void>>()` to buffer offset 0
  - Calls `sigaction(28, buffer.cast(), nullptr)` (SIGWINCH = 28)
  - Frees buffer
- `dispose()`:
  - Calls `sigaction(28, nullptr, nullptr)` to restore default handler
  - Calls `callback.close()`
  - Disposes `_context`

### Step 3.4 — FFI binding for `sigaction`

**Create** `packages/terminal/lib/src/signal_bindings.dart`:
- Typedefs (can be inline in terminal_io.dart or in this dedicated file):
  - `NativeSigaction = Int32 Function(Int32 signum, Pointer<Void> act, Pointer<Void> oldact)`
  - `Sigaction = int Function(int signum, Pointer<Void> act, Pointer<Void> oldact)`
- The handler is `void (*)(int)` — via `NativeCallable<Void Function(Int32)>`

### Step 3.5 — Update `systemIoProvider`

**Modify** `packages/terminal/lib/src/system_io_provider.dart`:
- `TerminalIo()` is no longer const, provider creates it with disposal:
```dart
@riverpod
SystemIo systemIo(Ref ref) {
  final io = TerminalIo();
  ref.onDispose(() {
    io.context.dispose();
  });
  return io;
}
```

### Step 3.6 — Update barrel exports

**Modify** `packages/terminal/lib/terminal.dart`:
- Add exports for: `system_context.dart`, `signal_bindings.dart`
- Remove old exports that no longer exist

---

## Phase 4 — Parser Cleanup (remove `WindowResizeEvent`)

### Step 4.1 — Remove `WindowResizeEvent` class

**Modify** `packages/parser/lib/src/events.dart`:
- Delete lines 143-177: `WindowResizeEvent` class with its `==`, `hashCode`, and `toString`

### Step 4.2 — Remove `WindowResizeEvent` test

**Modify** `packages/parser/test/events_test.dart`:
- Remove lines 101-107: `group('WindowResizeEvent', ...)` test

---

## Phase 5 — Consumer Updates

### Step 5.1 — Update `capabilities_provider.dart`

**Modify** `packages/capability/lib/src/capabilities_provider.dart`:
- `io.columns` → `io.context.value.width`
- `io.rows` → `io.context.value.height`

### Step 5.2 — Update `color_probe_provider.dart`

**Modify** `packages/capability/lib/src/color_probe_provider.dart`:
- `io.environment` → `io.context.value.environment`

### Step 5.3 — Update `color_probe.dart`

**Modify** `packages/capability/lib/src/color_probe.dart`:
- `io.environment` → `io.context.value.environment`

### Step 5.4 — Update `example/bin/example.dart`

**Modify** `example/bin/example.dart`:
- Import `package:terminal/terminal.dart` already exists
- Remove the dead `WindowResizeEvent` branch (lines 94-97)
- Add a listener on `io.context` after initialization:
```dart
var lastWidth = width;
var lastHeight = height;
io.context.addListener(() {
  final ctx = io.context.value;
  if (ctx.width != lastWidth || ctx.height != lastHeight) {
    lastWidth = ctx.width;
    lastHeight = ctx.height;
    if (!running) return;
    final result = model.update(WindowSizeMsg(ctx.width, ctx.height));
    model = result.$1;
    container.read(modelProvider.notifier).updateModel(model);
    _render(model, io, ref: previousFrame);
    previousFrame = _currentFrame(model);
  }
});
```
- Remove `import 'package:parser/terminal_parser.dart'` if it was only needed for `WindowResizeEvent` — but it's also needed for `KeyEvent`, `KeyCode`, so keep the import

### Step 5.5 — Remove `WindowResizeEvent` import usage

- `example/bin/example.dart` no longer references `WindowResizeEvent` — the `event is WindowResizeEvent` check is replaced by the `io.context` listener. The import of `terminal_parser.dart` stays for `KeyEvent`, `KeyCode`.

---

## Phase 6 — Verification

### Step 6.1 — Run code generation

```bash
dart run melos build
```

### Step 6.2 — Run static analysis

```bash
dart run melos analyze
```

### Step 6.3 — Run formatter

```bash
dart run melos format
```

### Step 6.4 — Run tests

```bash
dart run melos test
```

All four commands must pass without errors.

---

## Summary of All File Changes

| Action | File |
|--------|------|
| **DELETE** | `packages/terminal/lib/src/extensions.dart` |
| **CREATE** | `packages/terminal/lib/src/termios_linux.dart` |
| **CREATE** | `packages/terminal/lib/src/termios_macos.dart` |
| **CREATE** | `packages/terminal/lib/src/operating_system.dart` |
| **CREATE** | `packages/terminal/lib/src/system_context.dart` |
| **CREATE** | `packages/terminal/lib/src/system_context.freezed.dart` (generated) |
| **CREATE** | `packages/terminal/lib/src/libc_provider.dart` |
| **CREATE** | `packages/terminal/lib/src/libc_provider.g.dart` (generated) |
| **CREATE** | `packages/terminal/lib/src/termios_provider.dart` |
| **CREATE** | `packages/terminal/lib/src/termios_provider.g.dart` (generated) |
| **CREATE** | `packages/terminal/lib/src/termios_bindings_provider.dart` |
| **CREATE** | `packages/terminal/lib/src/termios_bindings_provider.g.dart` (generated) |
| **CREATE** | `packages/terminal/lib/src/signal_bindings.dart` |
| **MODIFY** | `packages/terminal/lib/src/termios.dart` |
| **MODIFY** | `packages/terminal/lib/src/termios_bindings.dart` |
| **MODIFY** | `packages/terminal/lib/src/raw_mode.dart` |
| **MODIFY** | `packages/terminal/lib/src/raw_mode_state.dart` |
| **MODIFY** | `packages/terminal/lib/src/raw_mode_state.freezed.dart` (regenerated) |
| **MODIFY** | `packages/terminal/lib/src/raw_mode_provider.dart` |
| **MODIFY** | `packages/terminal/lib/src/raw_mode_provider.g.dart` (regenerated) |
| **MODIFY** | `packages/terminal/lib/src/system_io.dart` |
| **MODIFY** | `packages/terminal/lib/src/terminal_io.dart` |
| **MODIFY** | `packages/terminal/lib/src/system_io_provider.dart` |
| **MODIFY** | `packages/terminal/lib/src/system_io_provider.g.dart` (regenerated) |
| **MODIFY** | `packages/terminal/lib/terminal.dart` |
| **MODIFY** | `packages/parser/lib/src/events.dart` |
| **MODIFY** | `packages/parser/lib/src/events.freezed.dart` (regenerated) |
| **MODIFY** | `packages/parser/test/events_test.dart` |
| **MODIFY** | `packages/capability/lib/src/capabilities_provider.dart` |
| **MODIFY** | `packages/capability/lib/src/capabilities_provider.g.dart` (regenerated if needed) |
| **MODIFY** | `packages/capability/lib/src/color_probe_provider.dart` |
| **MODIFY** | `packages/capability/lib/src/color_probe.dart` |
| **MODIFY** | `example/bin/example.dart` |
