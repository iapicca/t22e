# Implementation Plan — New TUI Framework (no raw mode)

## Overview

A new TUI framework for Dart that renders entirely via ANSI escape codes, using
`dart:io` stdin modes instead of raw mode/FFI, with a `ValueNotifier<CellGrid>`
canvas-based rendering engine.

### Core Principles

- **No FFI**: Zero native dependencies, pure Dart, automatic cross-platform compatibility
- **ANSI-only rendering**: Write escape sequences directly to `stdout` via standard Dart I/O
- **Canvas-driven**: A `ValueNotifier<CellGrid>` acts as the reactive canvas — any
  change triggers a diff + render cycle
- **Hybrid TEA + ValueNotifier**: TEA for pure state transitions, ValueNotifier as
  the synchronous reactive glue between model and renderer
- **dart:io stdin modes**: `stdin.lineMode = false` + `stdin.echoMode = false` for
  character-by-character input without raw mode

## Lessons Learned from v1

| Problem | Resolution in v2 |
|---------|------------------|
| Raw mode testing nearly impossible | dart:io stdin modes are testable — inject a mock stream |
| Riverpod autoDispose lifecycle differs outside Flutter | Document subscription patterns; always use `container.listen()` with explicit `subscription.close()` |
| FFI platform divergence (macOS vs Linux struct layouts) | Eliminated entirely. No FFI. |
| Terminal capability probing adds complexity | Dropped. Basic ANSI codes work on all modern terminals. |
| Sync rendering (DEC 2026) requires capability detection | Use plain ANSI. Modern terminals handle it fine. |

## Architecture Decisions

### Key Decision: Hybrid TEA + ValueNotifier

The v2 framework keeps TEA for **pure state transitions** (update function) and uses
`ValueNotifier<CellGrid>` as the **reactive canvas** that triggers renders.

```
┌─────────────┐   Msg    ┌─────────────┐
│   Model     │ ────────→│   update    │
│  (your      │          │  (pure fn)  │
│   state)    │←─────────│             │
└─────────────┘ (M, Cmd?)└─────────────┘
                              │
                              │ model.view()
                              ▼
                        ┌─────────────┐
                        │ Widget tree │
                        └──────┬──────┘
                               │ layout + paint
                               ▼
                        ┌─────────────┐
                        │  Canvas     │
                        │ Value-      │
                        │ Notifier    │
                        │ <CellGrid>  │
                        └──────┬──────┘
                               │ notification (synchronous)
                               ▼
                        ┌─────────────┐
                        │  Renderer   │
                        │ (diff +     │
                        │  ansi out)  │
                        └──────┬──────┘
                               │
                               ▼
                            stdout
```

ValueNotifier is **synchronous** — listeners fire immediately when the value is set.
This eliminates the need for an async render loop and keeps the framework
predictable and testable.

### Key Decision: Canvas-based Rendering

The Canvas wraps `ValueNotifier<CellGrid>` and provides an API for painting cells:

```dart
class Canvas {
  final ValueNotifier<CellGrid> _grid;

  CellGrid get cells => _grid.value;

  void paint(int x, int y, String text, TextStyle style);
  void paintRect(int x, int y, int w, int h, String ch, TextStyle style);
  void clear();
  // ...
}
```

When the canvas is updated, `ValueNotifier` fires its listeners synchronously.
The renderer subscribes and performs a **cell-level diff**, outputting only the
changed characters.

### Riverpod Subscription Pattern

To avoid the autoDispose issue outside Flutter, the framework will document and
enforce this pattern:

```dart
final container = ProviderContainer();

// Establish a persistent subscription to keep the provider alive
final subscription = container.listen<CellGrid>(
  canvasGridProvider,
  (previous, next) {
    // Trigger render (synchronous)
    _renderer.render(previous, next);
  },
);

// When done:
subscription.close();
```

## Package Layout

```
packages/
├── protocol/      KEPT from v1 (ANSI constants, no changes)
├── ansi/          KEPT from v1 (ANSI builders, no changes)
├── unicode/       KEPT from v1 (char width, grapheme clusters, no changes)
├── notifier/      KEPT from v1 (ValueNotifier, ChangeNotifier, Disposable)
│                  Minor additions: add cellGridProvider pattern documentation
├── core/          REWORKED from v1
│                  Keep: Cell (freezed), CellGrid, TextStyle, Color, geometry
│                  NEW: Canvas class
│                  Remove: Surface (replaced by Canvas), drawBorder (moved to
│                  widgets), toAnsiLines/toPlainLines (moved to renderer)
├── renderer/      REWORKED from v1
│                  Keep: Frame, DiffResult, LineRenderer
│                  Remove: CellRenderer (simplified cell diff), SyncRenderer
│                  NEW: CanvasRenderer (subscribes to Canvas ValueNotifier)
├── input/         NEW package (replaces parser + terminal)
│                  dart:io stdin modes, byte stream, simplified key parser
├── widgets/       REWORKED from v1
│                  Keep: Model, Msg, Cmd, Widget base class
│                  Rework: paint targets Canvas instead of Surface
│                  Keep: layout widgets (Row, Column, Box, Spacer)
│                  Conditional: interactive widgets (TextInput, ListView, etc.)
│                  Remove: Dialog, Table, Spinner, ProgressBar initially
└── example/       REWORKED
                   Demo chat app using the new architecture

REMOVED packages:
├── terminal/      REMOVED (raw mode, FFI, SIGWINCH handler — replaced by input)
├── parser/        REMOVED (VT500 state machine — replaced by simplified input parser)
├── capability/    REMOVED (terminal probing — unnecessary for basic ANSI)
├── lifecycle/     REMOVED (signal handling — handled by dart:io)
└── testing/       REMOVED (empty package, merge into test utilities)
```

## Phase 1: Foundation

**Goal**: Establish the workspace and bring in unchanged packages.

**Tasks**:
1. Create new root workspace with Melos
2. Copy `protocol`, `ansi`, `unicode`, `notifier` packages from v1
3. Update pubspec.yaml files (remove old cross-references, update workspace config)
4. Run `melos analyze` to confirm clean start
5. Write `.ai/code-standards.md` (already done)

**Deliverables**: Clean workspace with 4 packages passing analysis.

## Phase 2: Core Data Structures

**Goal**: Implement Cell, CellGrid, and supporting types as freezed data classes.

**Tasks**:
1. Create `core` package
2. Implement `Cell` (freezed):
   - `char` (String, default `' '`)
   - `style` (TextStyle, default `TextStyle.empty`)
   - `wideContinuation` (bool, default `false`)
   - `hyperlink` (String?)
3. Implement `CellGrid` (extension type over `List<List<Cell>>`):
   - `generate(Size)` factory
   - `height`, `width`, `isEmpty` getters
   - `row(int)`, `getCell(int, int)` accessors
4. Implement `TextStyle` (freezed):
   - SGR attributes: bold, dim, italic, underline, blink, reverse, strikethrough, overline
   - `foreground` Color?, `background` Color?
5. Implement `Color` (sealed):
   - `Color16`, `Color256`, `TrueColor(RgbColor)`
   - `sgrSequence()` method
6. Implement geometry types:
   - `Size`, `Point`, `Rect`, `Insets`, `Constraints`
   - `Rect.intersect()` method
7. Write tests for Cell, CellGrid, TextStyle, Color

**Deliverables**: `core` package with all data structures, fully tested.

## Phase 3: Canvas Rendering Engine

**Goal**: Implement the Canvas class backed by `ValueNotifier<CellGrid>`.

This is the heart of the new framework. The Canvas is the single source of truth
for what's on the terminal screen. Any change to it notifies listeners synchronously.

**Tasks**:
1. Create `canvas` package (or add to `core`)
2. Implement `Canvas` class:
   ```dart
   class Canvas {
     final ValueNotifier<CellGrid> _grid;

     Canvas(Size size) : _grid = ValueNotifier(CellGrid.generate(size));

     CellGrid get cells => _grid.value;
     ValueNotifier<CellGrid> get notifier => _grid;

     void putCell(int x, int y, Cell cell);
     void putChar(int x, int y, String ch, TextStyle style);
     void putText(int x, int y, String text, TextStyle style);
     void clear();
   }
   ```
3. Critical implementation detail: writes to CellGrid must create **new rows** for
   the modified positions (since rows are immutable `List<Cell>`). This ensures
   the reference changes and ValueNotifier fires correctly.
4. Implement grapheme-aware text writing (handle wide characters)
5. Write tests:
   - Basic putChar: assert character and style at position
   - putText with grapheme clusters
   - Wide character continuation cells
   - ValueNotifier fires on change
   - ValueNotifier does NOT fire on identical content
   - Clear canvas

**Deliverables**: Canvas class with reactive CellGrid, fully tested.

## Phase 4: Input System

**Goal**: Implement character-by-character input using `dart:io` stdin modes.

Replace the entire `parser` + `terminal` v1 packages with a simpler approach.

**Tasks**:
1. Create `input` package
2. Implement `TerminalInput` class:
   ```dart
   class TerminalInput {
     void init();    // Sets stdin.lineMode = false, stdin.echoMode = false
     void dispose(); // Restores stdin to normal mode
     Stream<int> get input; // Stream of individual bytes
   }
   ```
3. Implement `KeyParser` — simplified parser for common escape sequences:
   - Printable characters (plain bytes)
   - Arrow keys (`\x1b[A`, `\x1b[B`, `\x1b[C`, `\x1b[D`)
   - Enter (`\r`, `\n`)
   - Escape (`\x1b`)
   - Backspace (`\x7f` / `\b`)
   - Tab (`\t`)
   - Ctrl+key combinations (`\x01`-`\x1a`)
   - Function keys (optional, can be added later)
4. Do NOT implement the full VT500 state machine — only what's needed for a chat app
5. Implement Riverpod providers for TerminalInput and KeyParser
6. Write tests:
   - Mock stdin stream, verify bytes are parsed correctly
   - Arrow key sequences → correct key events
   - Ctrl+C → quit signal
   - Printable characters → character events
   - TerminalInput init/dispose lifecycle

**Notes**:
- `stdin.lineMode = false` provides character-at-a-time reading
- `stdin.echoMode = false` prevents input from being printed to the terminal
- The input stream can be mocked in tests by injecting any `Stream<int>`

**Deliverables**: `input` package with TerminalInput, KeyParser, and providers.

## Phase 5: Renderer

**Goal**: Implement diff-based ANSI rendering triggered by canvas changes.

**Tasks**:
1. Rewrite `renderer` package
2. Implement `Frame` (freezed, kept from v1 but simplified):
   - `plainLines`, `styledLines`
   - Remove optional `cells` field (canvas handles this)
3. Implement `CanvasRenderer`:
   ```dart
   class CanvasRenderer {
     Frame? _previousFrame;

     void render(CellGrid currentGrid) {
       final surface = Surface.fromGrid(currentGrid);
       final currentFrame = Frame.fromSurface(surface);
       if (_previousFrame != null) {
         final diff = DiffResult.fromFrames(_previousFrame!, currentFrame);
         if (diff.hasChanges) {
           stdout.write(_renderDiff(diff, currentFrame));
           stdout.write(moveTo(1, 1)); // Reset cursor
         }
       } else {
         stdout.write(fullFrameRender(currentFrame));
       }
       _previousFrame = currentFrame;
     }
   }
   ```
4. Implement `DiffResult` (kept from v1, extension type over `List<int>`)
5. Implement `LineRenderer` (kept from v1):
   - Compares `(plain, styled)` pairs
   - Outputs cursor-positioned ANSI for changed rows only
6. Remove: SyncRenderer (DEC 2026), CellRenderer
7. Write tests:
   - Diff two frames, verify only changed rows
   - Render output contains correct ANSI sequences
   - First frame → full render
   - Subsequent frames → diff render
   - No changes → no output

**Deliverables**: `renderer` package with CanvasRenderer, tested.

## Phase 6: Widgets

**Goal**: Implement the widget system that paints to Canvas.

**Tasks**:
1. Rewrite `widgets` package
2. Keep TEA core:
   - `Model<M>` base class with `update(Msg) → (M, Cmd?)` and `view() → Widget`
   - `Msg` base class (QuitMsg, KeyMsg, WindowSizeMsg, etc.)
   - `Cmd` sealed class (TickCmd, EveryCmd, BatchCmd, NoCmd)
3. Rewrite `Widget` base class to target `Canvas`:
   ```dart
   abstract class Widget {
     Size layout(Constraints constraints);
     void paint(Canvas canvas, int offsetX, int offsetY);
   }
   ```
4. Rewrite basic widgets (same widget types, updated paint to use Canvas):
   - `Text`: layout measures string width, paint calls canvas.putText()
   - `Box`: draws borders using canvas.putChar()
   - `Spacer`: takes remaining space
   - `Row`, `Column`: flexbox-like layout
5. Write widget tests:
   - Text widget: assert characters at correct positions in canvas CellGrid
   - Box widget: assert border characters at correct positions
   - Row/Column layout: assert correct size and child positions
6. Implement the dispatch loop / event loop:
   ```dart
   class TuiApp<M extends Model<M>> {
     final Canvas _canvas;

     void run(M initialModel) {
       final subscription = _canvas.notifier.addListener(_render);
       _canvas.notifier.addListener(_render);
       // ... input loop, dispatch, etc.
     }
   }
   ```

**Deliverables**: `widgets` package with Canvas-based paint, fully tested.

## Phase 7: Example Chat App

**Goal**: Build a working chat demo using the new framework.

**Tasks**:
1. Create `example` package
2. Implement `ChatModel` (TEA model for chat state)
3. Implement `ChatApp` (wiring TEA dispatch with Canvas renderer)
4. Implement chat widgets: message list, input bar, chat bubbles
5. Wire everything together:
   ```
   Input (stdin) → KeyParser → Msg → ChatModel.update() → Widget tree
   → Canvas.paint() → ValueNotifier fires → CanvasRenderer.render()
   → ANSI output to stdout
   ```
6. Manual testing: run the chat app and verify typing, scrolling, message display
7. Write integration tests: mock input stream, assert final CellGrid state

**Deliverables**: Working chat application, manually verified.

## Migration Notes

### What to Bring Forward from v1

| Component | How |
|-----------|-----|
| Freezed data classes | Identical pattern, same `@freezed` annotation |
| Cell / CellGrid / TextStyle | Same types, keep the same structure |
| Code generation pipeline | Same: `melos build` → build_runner → freezed |
| Riverpod providers | Same pattern, but with documented subscription management |
| ValueNotifier lifecycle | Same Disposable/InitMixin guards |
| Test patterns | Same surface/frame snapshot testing, adapted to Canvas |
| Collection expressions | Same pattern: collection-for over mutable accumulation |
| Cascade notation | Same preference |

### What Goes Away Completely

| v1 Component | Reason |
|-------------|--------|
| `terminal` package (FFI, tcgetattr/tcsetattr) | Replaced by dart:io stdin modes |
| `parser` package (VT500 state machine) | Replaced by simplified KeyParser |
| `capability` package (terminal probing) | Unnecessary — basic ANSI works everywhere |
| `lifecycle` package (signal handling) | No FFI signal handling needed |
| Raw mode state tracking (RawModeState) | No raw mode at all |
| SyncRenderer (DEC 2026) | Unnecessary for basic terminal usage |
| Platform-specific Termios layouts | No FFI, no platform divergence |

## Risk Assessment

| Risk | Mitigation |
|------|-----------|
| dart:io stdin modes may not capture all key combinations | Focus on common keys for chat; expand parser later if needed |
| Escape codes from stdin maybe incomplete without raw mode | Test on macOS and Linux; use stdin.lineMode = false |
| ValueNotifier synchronous notification may stack overflow with rapid updates | Batch updates: only set canvas notifier value once per frame, not per cell |
| Riverpod autoDispose still tricky outside Flutter | Document and enforce subscription pattern; consider custom ProviderContainer wrapper |
