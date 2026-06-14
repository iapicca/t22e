# macOS / Linux Cross-Platform Incompatibilities

---

## 2. termios struct layout differs between macOS and Linux

- **File**: `packages/protocol/lib/src/defaults.dart:638-656`
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

### Plan
- Introduce platform-specific constants for struct size, field offsets, and VMIN/VTIME positions
- Use `Platform.operatingSystem` or FFI `sizeof` / `offsetof` approach to determine layout at runtime
- Alternatively, use `dart:ffi` struct definitions with proper types instead of manual byte-level manipulation, letting the compiler handle offsets

---

## 3. VMIN/VTIME offsets wrong on both OSes

- **File**: `packages/protocol/lib/src/defaults.dart:652-656`
- Even on Linux, `termiosOffsetCCMin = 17` and `termiosOffsetCCTime = 18` are wrong
- On Linux: `c_cc` starts at offset 17, VMIN is at `c_cc[6]` → offset 23, VTIME at `c_cc[5]` → offset 22
- On macOS: VMIN at `c_cc[16]` → offset 48, VTIME at `c_cc[17]` → offset 49
- The code writes to `c_cc[0]` (VINTR) and `c_cc[1]` (VQUIT) on Linux, and into bytes of `c_cflag` on macOS
- **Impact**: Breaks interrupt/quit characters on Linux; writes garbage into `c_cflag` on macOS

### Plan
- Same as #2 — platform-specific offsets or proper FFI struct definitions

---

## 4. No musl libc support on Linux

- **File**: `packages/terminal/lib/src/extensions.dart:34-37`
- Only tries `libc.so.6` then `libc.so.7`
- Fails on Alpine Linux, Void musl, etc. where libc is `libc.musl-x86_64.so.1` or similar
- **Impact**: Crash on musl-based distros; `libc.so.7` is dead code (glibc 2.7 is from 2008)

### Plan
- Add musl libc names to the fallback chain: `libc.musl-x86_64.so.1`, `libc.musl-aarch64.so.1`
- Or use `DynamicLibrary.process()` to resolve without specifying the libc name (but this may have security implications)
- Or catch the error and fall back to a non-FFI raw mode backend (currently not implemented)

---

## 5. `script -q` doesn't exist on macOS

- **File**: `example/test/e2e_smoke_test.dart:14`, `example/test/compile_smoke_test.dart:51`
- macOS uses BSD `script` which has no `-q` flag
- **Impact**: Tests fail on macOS

### Plan
- Detect platform and use `-q` only on Linux, or use the BSD-compatible flags on macOS
- Or use `unbuffer` / `socat` / other PTY-wrapping approach

---

## 6. Signal handler events won't fire from keyboard in raw mode

- **File**: `packages/lifecycle/lib/src/signal_handler.dart:1-62`
- **File**: `packages/lifecycle/lib/src/signal_providers.dart:1-23`
- Raw mode clears `ISIG` flag — Ctrl+C emits byte `0x03` instead of SIGINT, Ctrl+Z emits `0x1A` instead of SIGTSTP
- `dart:io.ProcessSignal.watch()` streams will never fire for keyboard-generated signals
- `SignalHandler` is used in `example/bin/example.dart:34-46` as the primary Ctrl+C quit mechanism
- SIGTERM from external `kill` command still works (doesn't involve terminal)
- **Impact**: Ctrl+C doesn't quit the app in raw mode

### Plan
- Add byte-level detection of `0x03` (Ctrl+C) in the input stream
- Keep SIGTERM handling for external process termination
- Remove or repurpose `InterruptMsg`/`SuspendMsg`/`ResumeMsg` in `packages/widgets/lib/src/msg.dart:14-24` (defined but never dispatched)

---

## 7. WindowResizeEvent never emitted by parser

- **File**: `packages/parser/lib/src/events.dart:143-176`
- `WindowResizeEvent` class is defined but never instantiated or returned by `TerminalParser.advance()`
- `example/bin/example.dart:94` checks for `WindowResizeEvent` — dead branch, never executes
- **Impact**: Terminal resize does nothing (no relay-out on window size change)

### Plan
- Add resize detection mechanism (poll `io.columns`/`io.rows` on a timer, or handle SIGWINCH)
- Move `WindowResizeEvent` out of parser or make parser emit it when it detects a size change

---

## 8. echoMode/lineMode on SystemIo dangerous in raw mode

- **File**: `packages/terminal/lib/src/system_io.dart:23-29`
- **File**: `packages/terminal/lib/src/terminal_io.dart:28-37`
- `echoMode` and `lineMode` getter/setter wrappers around `dart:io.stdin.echoMode`/`stdin.lineMode`
- In raw mode, calling these could re-enable echo or canonical processing, undoing raw mode
- These are exposed via `SystemIo` interface and implemented in `TerminalIo`
- **Impact**: Potential to accidentally exit raw mode if these are called

### Plan
- Guard behind a check, remove, or document as "do not call in raw mode"
- Evaluate whether they're used anywhere (appears they are not called in the example app)

---

## 9. EchoMode in widgets is correct and distinct

- **File**: `packages/widgets/lib/src/enums.dart:14` — `EchoMode` enum (normal, password, noEcho)
- **File**: `packages/widgets/lib/src/interactive/text_input.dart` — `echoMode` field and `_displayValue`
- This is display-layer logic (password masking), NOT terminal echo control
- Does not conflict with raw mode — no change needed
- **Verdict**: Keep as-is

---

## 10. Unnecessary `\n` bytes in test input

- **File**: `example/test/e2e_smoke_test.dart:37` — sends `q\n` instead of just `q`
- **File**: `example/test/compile_smoke_test.dart:51` — same pattern
- In raw mode, `\n` is a harmless extra byte but reveals the test author assumed line-buffered input
- **Impact**: Cosmetic — no functional difference

### Plan
- Replace `q\n` with just `q` in both test files
