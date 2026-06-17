# macOS / Linux Cross-Platform Incompatibilities

---

## 2. termios struct layout differs between macOS and Linux

**Status: DONE**

- **File**: `packages/terminal/lib/src/termios.dart:17-35`
- `tcflag_t` is 4 bytes on Linux (`unsigned int`), 8 bytes on macOS 64-bit (`unsigned long`)
- Struct size: 60 bytes (Linux) vs 72 bytes (macOS)

| Field   | Code uses (Linux) | macOS 64-bit | Correct Linux |
|---------|-------------------|--------------|---------------|
| `c_iflag` | 0 | 0 | 0 |
| `c_oflag` | 4 | **8** | 4 |
| `c_cflag` | 8 | **16** | 8 |
| `c_lflag` | 12 | **24** | 12 |
| VMIN    | 17 | **48** | 23 |
| VTIME   | 18 | **49** | 22 |

- **Impact**: On macOS 64-bit, the code reads/writes the **wrong fields**. Flag changes land on bytes belonging to different fields. Raw mode is effectively broken on macOS. On Linux, VMIN/VTIME offsets are also wrong.

### Implementation
- `Termios` fields converted from `static const` to platform-aware getters using `Platform.operatingSystem`
- `tcflagSize` → 4 (Linux) / 8 (macOS); offsets computed from `tcflagSize * N`
- `ccOffset → 17 (Linux, after c_line) / 32 (macOS, directly after flags)
- `vminIndex → 6 (Linux) / 16 (macOS); vtimeIndex → 5 (Linux) / 17 (macOS)
- `termiosStructSize → 60 (Linux) / 72 (macOS)
- Added `read64`/`write64` to `PointerUint8Ops` for macOS 8-byte flag fields
- Added `Termios.readFlag`/`Termios.writeFlag` static methods abstracting platform width
- `RawMode.init()` and `dispose()` use `Termios.readFlag`/`writeFlag` instead of raw `read32`/`write32`
- Files: `pointer_extensions.dart`, `termios.dart`, `raw_mode.dart`

---

## 3. VMIN/VTIME offsets wrong on both OSes

**Status: DONE (resolved together with #2)**

- **File**: `packages/terminal/lib/src/termios.dart:32-36`
- Even on Linux, `termiosOffsetCCMin = 17` and `termiosOffsetCCTime = 18` are wrong
- On Linux: `c_cc` starts at offset 17, VMIN is at `c_cc[6]` → offset 23, VTIME at `c_cc[5]` → offset 22
- On macOS: VMIN at `c_cc[16]` → offset 48, VTIME at `c_cc[17]` → offset 49
- The code writes to `c_cc[0]` (VINTR) and `c_cc[1]` (VQUIT) on Linux, and into bytes of `c_cflag` on macOS
- **Impact**: Breaks interrupt/quit characters on Linux; writes garbage into `c_cflag` on macOS

### Implementation
- Offsets now computed as `ccOffset + vminIndex`/`ccOffset + vtimeIndex` with platform-aware `ccOffset` and indices
- Same changes as #2 above

---

## 4. No musl libc support on Linux

**Status: DONE**

- **File**: `packages/terminal/lib/src/extensions.dart:34-37`
- Only tries `libc.so.6` then `libc.so.7`
- Fails on Alpine Linux, Void musl, etc. where libc is `libc.musl-x86_64.so.1` or similar
- **Impact**: Crash on musl-based distros; `libc.so.7` is dead code (glibc 2.7 is from 2008)

### Implementation
- Added musl libc paths in `symbols_ffi.dart`: `libcMuslX86`, `libcMuslAarch64`
- `_openLinuxLibc()` now tries `libc.so.6` → `libc.musl-x86_64.so.1` → `libc.musl-aarch64.so.1`
- Removed dead `libc.so.7` entry
- Files: `symbols_ffi.dart`, `extensions.dart`

---

## 5. `script -q` doesn't exist on macOS

**Status: DONE**

- **File**: `example/test/e2e_smoke_test.dart:14`, `example/test/compile_smoke_test.dart:51`
- macOS uses BSD `script` which has no `-q` flag
- **Impact**: Tests fail on macOS

### Implementation
- `-q` flag now conditional: `if (Platform.isLinux) '-q'` using collection-if in arg lists
- Files: `e2e_smoke_test.dart`, `compile_smoke_test.dart`

---

## 6. Signal handler events won't fire from keyboard in raw mode

**Status: DONE**

- **File**: `packages/lifecycle/lib/src/signal_handler.dart:1-62`
- **File**: `packages/lifecycle/lib/src/signal_providers.dart:1-23`
- Raw mode clears `ISIG` flag — Ctrl+C emits byte `0x03` instead of SIGINT, Ctrl+Z emits `0x1A` instead of SIGTSTP
- `dart:io.ProcessSignal.watch()` streams will never fire for keyboard-generated signals
- `SignalHandler` is used in `example/bin/example.dart:34-46` as the primary Ctrl+C quit mechanism
- SIGTERM from external `kill` command still works (doesn't involve terminal)
- **Impact**: Ctrl+C doesn't quit the app in raw mode

### Implementation
- VT500 engine now passes `0x03` (Ctrl+C) through as `CharData(0x03)` instead of swallowing it in `_onGround`
- Example app quit condition extended: `event.codepoint == 113 || event.codepoint == 3`
- `SignalHandler` docs updated to note SIGINT won't fire from keyboard in raw mode
- Removed dead `InterruptMsg`/`SuspendMsg`/`ResumeMsg` from `msg.dart` (never dispatched)
- Files: `engine.dart`, `example.dart`, `signal_handler.dart`, `msg.dart`

---

## 7. WindowResizeEvent never emitted by parser

**Status: DONE (via different architecture)**

- `WindowResizeEvent` class was removed (never existed in current codebase)
- Resize detection is implemented via SIGWINCH FFI handler in `TerminalIo._initSigwinch()`, not parser events
- SIGWINCH callback updates `SystemContext` via `ValueNotifier.copyWith`, triggering listeners
- Example app listens to `io.context` and dispatches `WindowSizeMsg` to MVU model
- This push-based `ValueNotifier` approach is architecturally cleaner than parser-emitted events

### Implementation
- FFI `sigaction()` (signal 28) handler in `packages/terminal/lib/src/terminal_io.dart:57-96`
- `SystemContext` propagates changes via `ValueNotifier` listeners
- Example app at `example/bin/example.dart:91-103` handles resize via `WindowSizeMsg`
- No `WindowResizeEvent` class needed — resize is outside the input parser's concern
- Files: `terminal_io.dart`, `system_context.dart`, `example.dart`

---

## 8. echoMode/lineMode on SystemIo dangerous in raw mode

**Status: DONE (risk never materialized)**

- `echoMode` and `lineMode` getter/setter wrappers described in the original issue never existed in the current codebase
- `SystemIo` mixin defines only `inputStream`, `write`, `flush`, and `context` — no echo/line mode surface
- `TerminalIo` wraps `stdin`/`stdout` directly; echo/line disabling is handled at OS level by `RawMode` via `tcsetattr` FFI
- No `dart:io.stdin.echoMode` or `stdin.lineMode` calls exist anywhere in the project

### Implementation
- Echo and canonical mode disabled via `RawMode.init()` clearing `ECHO`/`ICANON` bits in `c_lflag` using `tcsetattr`
- `RawMode.dispose()` restores original termios state on any exit path
- No getter/setter wrappers to guard — `SystemIo` surface is already clean
- Files: `raw_mode.dart`, `system_io.dart`, `terminal_io.dart`

---

## 9. EchoMode in widgets is correct and distinct

**Status: VERIFIED — no change needed**

- **File**: `packages/widgets/lib/src/enums.dart:14` — `EchoMode` enum (normal, password, noEcho)
- **File**: `packages/widgets/lib/src/interactive/text_input.dart` — `echoMode` field and `_displayValue`
- This is display-layer logic (password masking), NOT terminal echo control
- Does not conflict with raw mode — no change needed
- **Verdict**: Confirmed correct; kept as-is

---

## 10. Unnecessary `\n` bytes in test input

**Status: DONE**

- **File**: `example/test/e2e_smoke_test.dart:37` — sends `q\n` instead of just `q`
- **File**: `example/test/compile_smoke_test.dart:51` — same pattern
- In raw mode, `\n` is a harmless extra byte but reveals the test author assumed line-buffered input
- **Impact**: Cosmetic — no functional difference

### Implementation
- Replaced `'q\n'` with `'q'` in both test files
- Files: `e2e_smoke_test.dart`, `compile_smoke_test.dart`

---

## Resolution Summary

| # | Issue | Status |
|---|-------|--------|
| 2 | termios struct layout differs macOS/Linux | DONE |
| 3 | VMIN/VTIME offsets wrong on both OSes | DONE |
| 4 | No musl libc support on Linux | DONE |
| 5 | `script -q` doesn't exist on macOS | DONE |
| 6 | Signal handler events won't fire from keyboard in raw mode | DONE |
| 7 | WindowResizeEvent never emitted by parser | DONE (SIGWINCH FFI approach) |
| 8 | echoMode/lineMode on SystemIo dangerous in raw mode | DONE (risk never materialized) |
| 9 | EchoMode in widgets is correct and distinct | VERIFIED (keep as-is) |
| 10 | Unnecessary `\n` bytes in test input | DONE |

All issues resolved. File archived on 2025-06-17.
