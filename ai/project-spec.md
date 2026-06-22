# Project Specification — t22e

## Project Overview

A declarative terminal user interface framework for Dart, built on The Elm Architecture
(TEA). The framework provides a widget system, layout engine, and ANSI renderer for
building interactive terminal applications.

## Package Structure

The project is a **Dart workspace monorepo** managed by Melos. All packages live under
`packages/<name>/` and use `resolution: workspace` for a single shared lockfile.

```
packages/
├── protocol/     Terminal escape sequence constants and byte-level definitions.
│                 Zero dependencies. Foundation for all other packages.
├── ansi/         ANSI escape sequence builders (cursor, color, erase, SGR).
│                 Depends on protocol.
├── unicode/      Character width calculation and grapheme cluster segmentation.
│                 Depends on protocol.
├── parser/       VT500 byte-level input parser state machine. Converts raw bytes
│                 to structured events (KeyEvent, MouseEvent, etc.).
│                 Depends on protocol, notifier.
├── terminal/     Raw mode management via FFI (libc tcgetattr/tcsetattr).
│                 SIGWINCH handler, stdin broadcast stream, stdout write.
│                 Depends on protocol, notifier, ffi.
├── core/         Data structures: Cell, CellGrid, Surface, TextStyle, Color,
│                 geometric types (Size, Point, Rect, Insets), layout constraints.
│                 Depends on protocol, unicode, ansi.
├── renderer/     Frame, DiffResult, LineRenderer, CellRenderer, SyncRenderer.
│                 Diffing and optimized ANSI output.
│                 Depends on protocol, ansi, core.
├── capability/   Terminal capability probing (truecolor, sync, keyboard, DA1).
│                 Depends on protocol, parser, core, terminal.
├── lifecycle/    Signal handling, alt screen, terminal restoration.
│                 Depends on protocol, notifier.
├── notifier/     Observable primitives: ValueNotifier, ChangeNotifier, Disposable,
│                 InitMixin. Flutter-inspired lifecycle guards for pure Dart.
│                 Depends on meta, riverpod.
├── widgets/      Declarative widget library: Model, Msg, Cmd, Widget base class,
│                 layout widgets (Row, Column, Box, Spacer), interactive widgets
│                 (TextInput, ListView, Dialog, ProgressBar, Spinner, Table).
│                 Depends on protocol, core, unicode, parser, notifier.
├── testing/      Empty/scaffolded testing utilities package.
└── example/      Demo chat application using the framework.
```

## Dependency Graph

```
protocol ─────────────────────────────────────────────────────────┐
  │                                                                │
  ├── ansi ────────────────────────────────────────┐               │
  ├── unicode ──────────────────────────────────┐  │               │
  ├── notifier ──┐                              │  │               │
  │       │      │                              │  │               │
  │       ├── parser (depends on protocol, notifier)              │
  │       ├── terminal (depends on protocol, notifier, ffi)       │
  │       └── lifecycle (depends on protocol, notifier)           │
  │              │                           │                    │
  │              └── core ────────────────────┤                    │
  │                     │                     │                    │
  │                     ├── renderer ─────────┤                    │
  │                     └── capability ───────┤                    │
  │                                          │                    │
  └──────────────────────── widgets ─────────┘────────────────────┘
```

## Data Structures

### Cell (`packages/core/lib/src/cell.dart`)

A single character cell on the terminal grid. Defined as a `@freezed` data class.

```dart
@freezed
abstract class Cell with _$Cell {
  const factory Cell({
    @Default(' ') String char,
    @Default(TextStyle.empty) TextStyle style,
    @Default(false) bool wideContinuation,
    String? hyperlink,
  }) = _Cell;
}
```

`wideContinuation` marks a cell that is part of a double-width character — it contains no
content of its own and is skipped during rendering.

### CellGrid (`packages/core/lib/src/cell_grid.dart`)

An extension type over `List<List<Cell>>`. Provides typed accessors (`height`, `width`,
`row()`, `getCell()`) and a factory `CellGrid.generate(Size)` that creates a blank grid.

```dart
extension type CellGrid(List<List<Cell>> _grid) implements List<List<Cell>> {
  int get height => _grid.length;
  int get width => isEmpty ? 0 : _grid[0].length;
  bool get isEmpty => _grid.isEmpty;

  const CellGrid.empty() : _grid = const [];

  CellGrid.generate(Size size)
    : _grid = List.generate(
        size.height,
        (_) => List.filled(size.width, const Cell(), growable: false),
        growable: false,
      );
}
```

### Surface (`packages/core/lib/src/surface.dart`)

A grid-based terminal canvas holding a `CellGrid`. Provides methods for:

- `putChar(int x, int y, String ch, TextStyle style)` — write a single character
- `putText(int x, int y, String text, TextStyle style)` — write text respecting grapheme clusters
- `fillRect(int x, int y, int w, int h, String ch, TextStyle style)` — fill a region
- `clearRect(int x, int y, int w, int h)` — clear a region to blank cells
- `drawBorder(Rect r, ...)` — draw a styled border with optional title
- `toPlainLines()` — export as plain text lines (no ANSI codes)
- `toAnsiLines()` — export as ANSI-escaped lines (via `SurfaceAnsiExport` extension)

### Frame (`packages/renderer/lib/src/frame.dart`)

A rendered frame representing a complete terminal screen state. Defined as a `@freezed`
data class.

```dart
@freezed
abstract class Frame with _$Frame {
  factory Frame(
    List<String> plainLines,
    List<String> styledLines, {
    @Default(CellGrid.empty()) CellGrid cells,
  }) = _Frame;

  factory Frame.fromSurface(Surface surface, {bool includeCells = false});
}
```

Created from a Surface via `Frame.fromSurface()`. Holds three representations:
- `plainLines` — plain text (for line-level diffing)
- `styledLines` — ANSI-escaped lines (for output)
- `cells` — optional CellGrid (for cell-level diffing)

### DiffResult (`packages/renderer/lib/src/diff_result.dart`)

Extension type over `List<int>` containing indices of changed rows between two frames.

```dart
extension type DiffResult(List<int> it) implements Iterable<int> {
  factory DiffResult.fromFrames(Frame previous, Frame current);
}
```

### TextStyle and Color (`packages/core/lib/src/style.dart`, `color.dart`)

- **TextStyle** (`@freezed`): bold, dim, italic, underline, blink, reverse,
  strikethrough, overline, foreground Color, background Color
- **Color**: sealed class with `Color16`, `Color256`, `TrueColor` (RGB). Implements
  `sgrSequence()` and `sgrSequence(background:)` for ANSI output.

### Geometry Types (`packages/core/lib/src/geometry.dart`)

- **Size**: width × height
- **Point**: x, y coordinates
- **Rect**: left, top, width, height with `intersect()`
- **Insets**: top, right, bottom, left padding
- **Constraints**: min/max size limits for layout

## TEA Architecture

### Model (`packages/widgets/lib/src/model.dart`)

Pure functional state container. Users extend `Model<M>` and implement:

```dart
abstract class Model<M extends Model<M>> {
  const Model();
  (M, Cmd?) update(Msg msg);  // Returns (newModel, optionalCommand)
  dynamic view();             // Returns Widget tree or Surface
}
```

### Msg (`packages/widgets/lib/src/msg.dart`)

Abstract base class for all events. Concrete subclasses:

| Class | Purpose |
|-------|---------|
| `QuitMsg` | Terminate the program |
| `WindowSizeMsg` | Terminal was resized (width, height) |
| `ClearScreenMsg` | Request full screen repaint |
| `EnterAltScreenMsg` | Enter alternate screen buffer |
| `ExitAltScreenMsg` | Exit alternate screen buffer |
| `HideCursorMsg` / `ShowCursorMsg` | Cursor visibility control |
| `KeyMsg` | Keyboard event (wraps `KeyEvent` from parser) |
| `MouseMsg` | Mouse event (wraps `MouseEvent` from parser) |
| `ProgressTickMsg` | Periodic tick for progress bar animation |
| `SpinnerTickMsg` | Periodic tick for spinner animation |
| `CursorBlinkMsg` | Periodic tick for text input cursor blink |
| `ListEnterMsg` | Item selected in ListView (index, label) |
| `DialogCloseMsg` | Dialog dismissed via Escape |
| `DialogButtonMsg` | Dialog button pressed (index, label) |

### Cmd (`packages/widgets/lib/src/cmd.dart`)

Sealed class for side-effect commands. The dispatch loop calls `cmd.execute(enqueue)`.

| Class | Purpose |
|-------|---------|
| `TickCmd` | One-shot delayed message (`Future.delayed`) |
| `EveryCmd` | Periodic timer (`Timer.periodic`) |
| `BatchCmd` | Run commands concurrently (`Future.wait`) |
| `SequenceCmd` | Run commands sequentially |
| `ExecCmd` | Run external process (`Process.run`) |
| `NoCmd` | No-op |

Factory functions provide ergonomic creation: `tick()`, `every()`, `batch()`,
`sequence()`, `execProcess()`, `none()`.

### Dispatch Loop

```
Msg ──→ Model.update(msg) ──→ (newModel, Cmd?)
                                     │
                                     ▼
                              cmd.execute(enqueue)
                                     │
                                     ▼
                              enqueue(result) ──→ back to update
```

1. A `Msg` enters the dispatch loop
2. `Model.update(msg)` returns the new model state and an optional `Cmd`
3. If a `Cmd` is present, its `execute(enqueue)` is called
4. The command may produce messages synchronously, asynchronously, or via callbacks
5. Any produced message is enqueued back into the dispatch loop

## Widget System

Widgets follow a two-phase model (inspired by Flutter):

### Widget (`packages/widgets/lib/src/widget.dart`)

```dart
abstract class Widget {
  Size layout(Constraints constraints);  // Phase 1: measure
  void paint(PaintingContext context);   // Phase 2: draw onto Surface
}
```

**Phase 1 — Layout**: `layout(Constraints)` computes the widget's size given minimum
and maximum constraints. This is a top-down pass.

**Phase 2 — Paint**: `paint(PaintingContext)` draws into the provided surface at the
current offset. `PaintingContext` carries the target `Surface`, positional offset,
and inherited `TextStyle`.

### Widget Categories

- **Basic**: `Text`, `Hyperlink`, `Box`, `Spacer`
- **Layout Containers**: `Row`, `Column` (flexbox-like via `splitHorizontal` / `splitVertical`)
- **Interactive**: `TextInput`, `ListView`, `ListItem`, `Scrollable`
- **Visual**: `ProgressBar`, `Spinner`, `Table`, `Dialog`

## Rendering Pipeline

```
Widget tree
    │  layout(Constraints)  ← Phase 1: measure
    ▼
    │  paint(PaintingContext)  ← Phase 2: draw
    ▼
  Surface (CellGrid)
    │  Frame.fromSurface(surface)
    ▼
  Frame (plainLines, styledLines, cells)
    │  DiffResult.fromFrames(previous, current)
    ▼
  DiffResult (changed row indices)
    │
    ├─── LineRenderer  →  cursor-positioned ANSI for changed rows only
    │        OR
    └─── cellRender()  →  per-cell diff with repositioned cursor
    │
    ▼
  ANSI output (stdout)
    │  (optional) SyncRenderer wraps with DEC 2026 markers
    ▼
  Terminal display
```

### LineRenderer

Compares rows by their combined `(plain, styled)` pair. Only rows that changed
are re-output via cursor positioning (`moveTo(row, col)`) followed by the styled line.

### CellRenderer

Compares individual cells between two frames. Only outputs cells whose `char`
or `style` changed. Uses cursor repositioning (`\x1b[row;colH`) to jump to
specific cells, avoiding full-line redraws.

### SyncRenderer

Wraps the output with DEC 2026 `synchronizedUpdateBegin()` /
`synchronizedUpdateEnd()` markers when the terminal supports synchronized updates.

## Input Pipeline

```
Raw bytes (stdin)
    │
    │  Vt500Engine.advance()  — byte-level state machine
    ▼
  SequenceData (CSI, ESC, OSC, DCS, plain char)
    │
    │  TerminalParser._interpret()  — semantic dispatch
    ▼
  Event (KeyEvent, MouseEvent, PasteEvent, etc.)
    │
    │  wrapped as Msg
    ▼
  Model.update(msg)  — user's state transition
```

### Vt500Engine (`packages/parser/lib/src/engine.dart`)

A full VT500 byte-level state machine implementing the DEC VT500 terminal specification.
States: `ground`, `escape`, `escapeIntermediate`, `csiEntry`, `csiParam`,
`csiIntermediate`, `csiIgnore`, `oscString`, `dcsEntry`, `dcsParam`, `dcsIntermediate`,
`dcsIgnore`, `dcsPassthrough`.

Feeds bytes one at a time via `advance(int byte) → SequenceData?` or calls
`advanceAll(List<int> bytes) → List<SequenceData>`.

### TerminalParser (`packages/parser/lib/src/terminal_parser.dart`)

Composes the Vt500Engine with four specialized sub-parsers:

- `CsiParser` — CSI sequences (cursor keys, function keys, mouse events)
- `EscParser` — ESC sequences (alt+key, function key variants)
- `OscParser` — OSC sequences (paste, color queries)
- `DcsParser` — DCS sequences (Kitty keyboard protocol)

Produces `Event` objects that are then wrapped into `Msg` for delivery to the model.

## Terminal I/O

The `terminal` package manages raw mode via **FFI with libc fallback**.

### FFI Backend

- Opens `libSystem.dylib` (macOS) or `libc.so.6` / `libc.musl-*` (Linux)
- Looks up `tcgetattr`, `tcsetattr`, `malloc`, `free`, `write` via `library.lookupFunction()`
- Platform-specific `Termios` implementations handle different struct layouts:
  - **macOS**: 72-byte struct, 8-byte tcflag_t (64-bit reads/writes)
  - **Linux**: 60-byte struct, 4-byte tcflag_t (32-bit reads/writes)

### Raw Mode Lifecycle

1. **init()**: Allocate termios buffer via `malloc`, read current attributes via `tcgetattr`,
   save flags to `RawModeState`, clear `ECHO | ICANON | ISIG | IEXTEN`, set `VMIN=1 VTIME=0`,
   apply via `tcsetattr`
2. **dispose()**: Restore all saved flags via `tcsetattr`, free the buffer via `free`

### SIGWINCH Handler

Registers a signal handler via FFI `sigaction()` with `NativeCallable.listener` to
detect terminal resize events and update `SystemContext` (stored in a `ValueNotifier`).

### Stdin Broadcasting

Creates a `StreamController<List<int>>.broadcast()` and pipes `stdin.listen(...)`
into it. The parser consumes this stream.

### Stdout Writing

Output is written via FFI `write()` to file descriptor 1 (stdout), bypassing
Dart's `stdout` buffering for maximum control.

## Lifecycle

### notifier Package

Provides Flutter-like observable primitives with structured lifecycle guards:

- **`Disposable`** mixin: Tracks disposed state, `check()` throws `StateError` after disposal
- **`InitMixin`** mixin: Tracks initialization state, `checkInit()` throws `StateError` before init
- **`ChangeNotifier`**: Manages listener list, notifies on change with disposal guards
- **`ValueNotifier<T>`**: Holds a single value, notifies listeners on change, guards against use-after-dispose
- **`Disposed`** / **`Initialized`**: Extension types used as immutable guards

### Riverpod Providers

All lifecycle-managed objects use `@riverpod` providers with code generation:

- Provider file convention: `my_class.dart` → `my_class_provider.dart`
- `ref.onDispose()` wires cleanup to provider disposal
- `keepAlive: true` for singleton-like providers
- Consumers use `ProviderContainer` or `ref.watch()` — never instantiate raw classes directly
- Raw implementation classes that have providers are annotated `@internal`

## Testing Strategy

- All tests use `package:test`
- **Widget tests**: Create a `Surface`, run `layout()` + `paint()`, assert on cell contents
  (characters and styles at specific grid positions)
- **Model tests**: Call `model.update(msg)`, assert on returned `(newModel, cmd?)` tuple
- **Parser tests**: Feed bytes to `Vt500Engine.advance()`, assert on `SequenceData` types/fields
- **Lifecycle tests**: Verify `StateError` is thrown on use-after-dispose
- **Terminal tests**: Use `script -q /dev/null` to fake a TTY when needed
- No real terminal is required for most test execution
