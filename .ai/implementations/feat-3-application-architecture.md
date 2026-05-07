# Implementation Plan: Feature 3 — Application Architecture (TEA)

**Version:** 2 (with magic value hardening)
**Feature:** Feat-3 Application Architecture
**Phase:** 3 | **Priority:** P0 | **Scope:** 3 stories, 11 tasks + 6 cleanup tasks
**Depends on:** Feat-1 (Terminal Foundation), Feat-2 (Rendering Core)
**Constraint:** No 3rd party dependencies — only Dart SDK (`dart:io`, `dart:async`, `dart:collection`)

---

## Architecture Overview

The Elm Architecture (TEA) event loop ties together all previous features into a coherent application runtime:

```
                    Msg
  ┌─────────────────────┐
  │                     ▼
  │           ┌─────────────────┐
  │           │   Model.update  │  ← pure function, returns (Model, Cmd?)
  │           └──────┬──────────┘
  │       ┌──────────┘
  │       ▼
  │  ┌────────┐    ┌──────────────────┐
  │  │  Cmd   │───▶│  fire-and-forget  │──▶ enqueue result as Msg
  │  └────────┘    └──────────────────┘
  │
  │         ┌──────────────────┐
  │         │  Model.view()    │  ← pure function, returns Surface
  │         └──────┬───────────┘
  │                ▼
  │         ┌──────────────────┐
  │         │  Frame/Surface   │  ← Snapshot current rendered state
  │         └──────┬───────────┘
  │                ▼
  │         ┌──────────────────┐
  │         │  Diff + Render   │  ← Compare with previous frame, emit ANSI
  │         └──────────────────┘
  │
  └── Wait for next input/tick ──▶ repeat
```

---

## Guiding Principles

| Principle | Application |
|-----------|-------------|
| **No magic values** | Every hardcoded byte, timer duration, or numeric constant has a descriptive name in `WellKnown` (for universal values) or in the appropriate `ansi/*.dart` module (for terminal sequences) |
| **Use existing abstractions** | New code uses existing `ansi/*.dart` functions instead of inline `\x1b[...` strings |
| **Single Responsibility** | Each file owns exactly one concern |
| **DRY** | Shared probe patterns extracted; Cmd hierarchy avoids duplicated fire-and-forget logic |
| **Pure functions where possible** | `Model.update()` and `Model.view()` are pure; side effects only in `Cmd.execute()` |
| **Testability** | Every component unit-testable by injecting mock stdin/stdout |
| **Exhaustive pattern matching** | `sealed class` for `Msg` and `Cmd` hierarchies |

---

## Directory & File Structure

```
lib/
├── t22e.dart                              # UPDATE
├── src/
│   ├── ansi/
│   │   ├── codes.dart                     # UPDATE: no changes (already pure constants)
│   │   ├── term.dart                      # UPDATE: add missing probe query sequences
│   │   └── ... (cursor.dart, color.dart, erase.dart unchanged)
│   ├── core/
│   │   ├── surface.dart                   # FIX: replace inline \x1b[Nm with ansi/codes.dart functions
│   │   ├── color.dart                     # FIX: replace inline \x1b[... with ansi codes constants
│   │   └── ... (cell.dart, geometry.dart, style.dart, layout.dart unchanged)
│   ├── renderer/
│   │   ├── line_renderer.dart             # FIX: replace inline \x1b[${row+1};0H with moveTo()
│   │   └── ... (frame.dart, sync_renderer.dart unchanged)
│   ├── loop/                              # NEW — TEA Event Loop
│   │   ├── well_known.dart                # NEW — universal well-known constants
│   │   ├── model.dart                     # 3.1.1 Model<M> abstract class
│   │   ├── msg.dart                       # 3.1.2 Msg sealed hierarchy + system messages
│   │   ├── cmd.dart                       # 3.1.3 Cmd sealed class hierarchy + built-in helpers
│   │   └── program.dart                   # 3.1.4 Program<M> event loop
│   ├── capability/                        # NEW — Terminal Capability Detection
│   │   ├── result.dart                    # QueryResult<T> + Capabilities + Da1Result
│   │   ├── da1_probe.dart                 # 3.2.1 DA1 query
│   │   ├── color_probe.dart               # 3.2.2 Color capability
│   │   ├── sync_probe.dart                # 3.2.3 Sync update
│   │   ├── keyboard_probe.dart            # 3.2.4 Keyboard protocol
│   │   └── pipeline.dart                  # Aggregate probe pipeline
│   └── lifecycle/                         # NEW — Lifecycle & Signal Handling
│       ├── terminal_guard.dart            # 3.3.1 Crash-safe restore
│       ├── signal_handler.dart            # 3.3.2 SIGINT/SIGTERM/SIGTSTP
│       └── alt_screen_manager.dart        # 3.3.3 Alt screen management
test/
├── all_test.dart                          # UPDATE
├── loop/                                  # NEW — tests
│   ├── well_known_test.dart
│   ├── model_test.dart
│   ├── msg_test.dart
│   ├── cmd_test.dart
│   └── program_test.dart
├── capability/                            # NEW — tests
│   ├── result_test.dart
│   ├── da1_probe_test.dart
│   ├── color_probe_test.dart
│   ├── sync_probe_test.dart
│   ├── keyboard_probe_test.dart
│   └── pipeline_test.dart
└── lifecycle/                             # NEW — tests
    ├── terminal_guard_test.dart
    ├── signal_handler_test.dart
    └── alt_screen_manager_test.dart
```

---

## Well-Known Constants

**File:** `lib/src/loop/well_known.dart`

Every magic byte value, timer duration, and numeric constant lives here with a descriptive name. No code should contain `0x` literals for control characters outside the `ansi/*.dart` modules.

---

## Existing File Cleanup (from feat-1/feat-2)

### Fix `surface.dart` — Use `ansi/codes.dart` SGR functions
Replace inline `'\x1b[1m'`, `'\x1b[2m'`, etc. in `_styleToAnsi()` with calls to `bold(true)`, `dim(true)`, etc.

### Fix `color.dart` — Use `ansi/codes.dart` CSI constant
Replace inline `'\x1b[49m'` with `'${csi}49m'`, etc.

### Fix `line_renderer.dart` — Use `moveTo()` from `ansi/cursor.dart`
Replace inline `'\x1b[${row + 1};0H'` with `moveTo(row + 1, 0)`.

### Fix `ansi/term.dart` — Add missing probe sequences
Add `queryDa1()`, `querySyncUpdate()`, `queryCursorPosition()`.

### Fix `engine.dart` — All VT500 byte comparisons use `WellKnown`
Replace 122+ hex byte references with `WellKnown.escapeByte`, `WellKnown.csiIntroducerByte`, etc.

### Fix `csi_parser.dart`, `esc_parser.dart` — Use `WellKnown` for control bytes, char literals for ASCII
Use `WellKnown.escapeByte` for ESC, `'A'.codeUnitAt(0)` for ASCII final bytes.

---

## Stories & Tasks

### Story 3.1 — TEA Event Loop (XL)
- **3.1.1 Model:** Abstract class `Model<M extends Model<M>>` with `update(Msg) → (M, Cmd?)` and `view()`
- **3.1.2 Msg:** `sealed class Msg` with system messages (`QuitMsg`, `InterruptMsg`, `WindowSizeMsg`, etc.) and input bridge messages (`KeyMsg`, `MouseMsg`, etc.)
- **3.1.3 Cmd:** Sealed class hierarchy (`TickCmd`, `EveryCmd`, `BatchCmd`, `SequenceCmd`, `ExecCmd`, `NoCmd`) with `execute(enqueue)` method
- **3.1.4 Program:** Generic `Program<M>` event loop with message queue draining, FPS throttle, ESC disambiguation, input bridge, render cycle, and clean shutdown

### Story 3.2 — Terminal Capability Detection (L)
- **3.2.1 DA1:** Sends `queryDa1()`, parses `PrimaryDeviceAttributesEvent` into `Da1Result`
- **3.2.2 Color:** Detects color depth via OSC 10/11 queries, env vars, DA1, TERM heuristic
- **3.2.3 Sync:** DECRPM query for synchronized update support
- **3.2.4 Keyboard:** Kitty keyboard protocol probe with push/pop pattern

### Story 3.3 — Lifecycle & Signal Handling (M)
- **3.3.1 TerminalGuard:** Idempotent crash-safe terminal restore with `arm()`/`restore()`/`runGuarded()`
- **3.3.2 SignalHandler:** SIGINT → InterruptMsg; SIGTERM → clean restore + exit; SIGTSTP → restore → suspend → resume
- **3.3.3 AltScreenManager:** Enter/exit alt screen using existing `ansi/term.dart` and `ansi/cursor.dart` functions

---

## Implementation Order

| Step | Task | Description | Depends On |
|------|------|-------------|------------|
| 1 | WellKnown | Create `well_known.dart` | Nothing |
| 2 | Fix `ansi/term.dart` | Add `queryDa1()`, `querySyncUpdate()`, `queryCursorPosition()` | WellKnown |
| 3 | Fix `surface.dart` | Replace inline `\x1b[Nm` with `ansi/codes.dart` functions | WellKnown |
| 4 | Fix `color.dart` | Replace inline `\x1b[...` with `csi` constant | WellKnown |
| 5 | Fix `line_renderer.dart` | Replace inline move with `moveTo()` | WellKnown |
| 6 | Fix `engine.dart` | Replace raw hex bytes with WellKnown constants | WellKnown |
| 7 | Fix `csi_parser.dart`, `esc_parser.dart` | Replace raw hex with WellKnown + char literals | WellKnown |
| 8 | `AltScreenManager` | Create, uses existing ANSI functions | Step 2 |
| 9 | `Msg` | Create sealed class hierarchy | Nothing |
| 10 | `Model` | Create abstract class | Step 9 |
| 11 | `Cmd` | Create sealed class hierarchy | Step 9 |
| 12 | `TerminalGuard` | Create | Step 8 |
| 13 | `SignalHandler` | Create, refactor `runner.dart` | Step 12 |
| 14 | `result.dart` | Create `QueryResult`, `Capabilities`, `Da1Result` | Nothing |
| 15 | `Da1Probe` | Create | Steps 1, 2, 14 |
| 16 | `ColorProbe` | Create | Steps 1, 2, 14, 15 |
| 17 | `SyncProbe` | Create | Steps 1, 2, 14 |
| 18 | `KeyboardProbe` | Create | Steps 1, 2, 14 |
| 19 | `ProbePipeline` | Aggregate | Steps 15-18 |
| 20 | `Program` | Create | Everything above |
| 21 | Barrel export | Update `t22e.dart` | All tasks |
| 22 | Test manifest | Update `all_test.dart` | All tasks |

---

## Dart Official Documentation References

| Topic | URL |
|-------|-----|
| Generics | https://dart.dev/language/generics |
| Sealed classes | https://dart.dev/language/class-modifiers#sealed |
| Abstract classes | https://dart.dev/language/classes#abstract-classes |
| Constructors (const) | https://dart.dev/language/constructors |
| Records | https://dart.dev/language/records |
| Switch expressions | https://dart.dev/language/branches#switch-expressions |
| Control flow | https://dart.dev/language/control-flow |
| Collections | https://dart.dev/language/collections |
| `ProcessSignal` | https://api.dart.dev/stable/dart-io/ProcessSignal-class.html |
| `stdin.listen` | https://api.dart.dev/stable/dart-io/Stdin/listen.html |
| `Future.wait()` | https://api.dart.dev/stable/dart-async/Future/wait.html |
| `Timer.periodic()` | https://api.dart.dev/stable/dart-async/Timer/Timer.periodic.html |
| `Completer` | https://api.dart.dev/stable/dart-async/Completer-class.html |
| `StreamSubscription` | https://api.dart.dev/stable/dart-async/StreamSubscription-class.html |
| `unawaited()` | https://api.dart.dev/stable/dart-async/unawaited.html |
| `Object.hash()` | https://api.dart.dev/stable/dart-core/Object/hash.html |
| Writing tests | https://dart.dev/guides/testing |
| `package:test` | https://api.dart.dev/stable/dart-test/dart-test-library.html |
