# macOS / Linux Cross-Platform Incompatibilities

## 1. SIGTSTP/SIGCONT unsupported on macOS

- **File**: `packages/lifecycle/lib/src/signal_providers.dart:17`
- `ProcessSignal.sigtstp.watch()` throws `SignalException` on macOS
- These signals serve no function in raw mode anyway (Ctrl+Z is captured as byte `0x1A`)
- **Impact**: Crash on startup — the current bug

### Plan
- Option A: Wrap each `.watch()` in try-catch, fall back to `const Stream.empty()` on `SignalException`. Keeps the code portable across platforms.
- Option B: Remove `sigtstpStreamProvider` and `sigcontStreamProvider` entirely, along with their usage in `signal_handler.dart` and `providers.dart`, since they serve no function in raw mode. Regenerate `providers.g.dart`.

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
