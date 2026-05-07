# How to Create a Declarative and Ergonomic Terminal User Interface Renderer

## Analysis of 3 Dart TUI Frameworks

### Repositories Studied

| Repo | Architecture | Philosophy |
|---|---|---|
| **dart_tui** | Elm Architecture (TEA) — Model-Update-View | Pure functional, immutable state, message-driven. Closest to Bubble Tea. |
| **utopia_tui** | Imperative paint-surface model with diff optimization | Widget tree with `paint()` methods, theme system, imperative event handling. |
| **termkit** (termlib + termansi + termparser + termunicode) | Low-level toolkit, not a framework | Provides the primitives (ANSI codes, input parser, unicode tables, terminal control). No UI framework layer. |

---

## Foundational Layer: Terminal Primitives

### 1. ANSI Escape Code Management

**Every TUI renderer needs a module that produces ANSI sequences.** The cleanest approach (from termkit/termansi) is a pure-constant approach:

```
ANSI Code Module (termansi-style)
  ├── Color:     RGB fg/bg, 256-color, ANSI 16, underline coloring
  ├── Text:      bold, italic, dim, blink, reverse, strike, overline, reset
  ├── Cursor:    moveTo(y,x), hide/show, save/restore, style (block/bar/underline)
  ├── Erase:     screen/line clear variants
  ├── Term:      alt screen, mouse modes, sync updates, clipboard,
  │              bracketed paste, keyboard protocol (Kitty), hyperlinks,
  │              notifications, progress bar (ConEmu), terminal title,
  │              color queries (OSC 10/11), scroll up/down, soft reset
  └── Escape:    ESC, CSI, OSC, DCS, ST, BEL constants
```

**Key principle**: This should be a **zero-logic definitions layer** — pure string/constant generation. No terminal I/O. No state.

### 2. Terminal Capability Detection

From termlib's `probeTerminal()`, a sequential probe pipeline:

```
  Device Attrs (DA1)
  → Terminal Name/Version
  → Color queries (OSC 10 fg, OSC 11 bg)
  → Sync update support (?2026)
  → Keyboard enhancement (Kitty protocol)
  → Window size (pixels)
  → Unicode Core support
  → Color scheme (light/dark)
  → In-band resize
```

Each returns `QueryResult<T>` — either `Supported<T>` or `Unavailable`. These results determine rendering strategies (e.g., skip truecolor if unsupported).

### 3. Raw Mode & Terminal I/O

From termlib's `TermOs` and dart_tui's `Program`:

```
  Raw Mode Setup:
    - Disable echo (ECHO)
    - Disable canonical mode (ICANON) — line-by-line input off
    - Disable signal generation (ISIG) — Ctrl+C arrives as byte, not SIGINT
    - Disable extended functions (IEXTEN)
    - Set VMIN=1, VTIME=0 (blocking reads)
    - Optionally disable CR→NL mapping (ICRNL)

  Implementation: Dart FFI to libc (tcgetattr/tcsetattr on Unix)
  Fallback: Use dart:io's stdin.echoMode = false, stdin.lineMode = false
```

### 4. Input Parsing (State Machine)

From termparser — a **2-stage VT500-inspired parser**:

```
Stage 1: Engine (13-state VT500 state machine)
  Processes bytes one-at-a time
  Emits SequenceData objects (CharData, CsiSequenceData, OscSequenceData, etc.)

Stage 2: Semantic Parsers
  CSI Parser:   Arrows, F-keys, Home/End, Kitty protocol, SGR mouse, CPR, DA1
  ESC Parser:   SS3 sequences (F-keys from xterm)
  OSC Parser:   Color queries, clipboard, terminal title, hyperlinks
  DCS Parser:   Kitty graphics protocol
  Char Parser:  Printable chars, control chars, UTF-8 sequences

Event Hierarchy:
  Event
  ├── InputEvent     (user-generated)
  │   ├── KeyEvent       (KeyCode + KeyModifiers + event type)
  │   ├── MouseEvent     (button + action + position)
  │   ├── PasteEvent     (bracketed paste content)
  │   └── RawKeyEvent    (raw bytes bypass)
  ├── ResponseEvent  (terminal responses)
  │   ├── CursorPositionEvent, ColorQueryEvent, FocusEvent
  │   ├── PrimaryDeviceAttributesEvent, KeyboardEnhancementFlagsEvent
  │   ├── WindowResizeEvent, QuerySyncUpdateEvent, etc.
  ├── ErrorEvent
  └── InternalEvent
```

**Key**: This is the hardest part to get right. Use the VT500 parser spec and borrow from battle-tested implementations (annes, vaxis, termwiz).

### 5. Unicode / Wide Character Support

From termunicode — a **3-stage lookup table** for O(1) character properties:

```
Stage1[high_byte] → offset into Stage2
Stage2[offset + low_byte] → index into Stage3
Stage3[index] → property byte (4 bits width + emoji + printable + private flags)

Properties per codepoint:
  Width:    0=zero, 1=narrow, 2=wide, 3=ambiguous
  Emoji:    flag
  Printable: Cc/Cf/Cs/Cn/Co/Zl/Zp detection
  Private:  non-character or private-use areas
```

**Critical**: Must handle grapheme clusters (base + zero-width joiners + variation selectors), ZWJ sequences (emoji), and CJK wide characters (occupy 2 terminal columns).

---

## Architecture Patterns for Declarative Rendering

### Pattern A: Elm Architecture (TEA) — from dart_tui

```
┌──────────────┐   Msg    ┌──────────────┐
│    Model     │ ──────▶  │    update    │
│  (immutable) │          │  (pure fn)   │
└──────────────┘          └──────┬───────┘
        ▲                        │ (Model, Cmd?)
        │                        ▼
        │                 ┌──────────────┐
        └──── render ───  │     view     │
                          │  (pure fn)   │
                          └──────────────┘
```

**Pros**: Pure, testable, predictable, excellent for deterministic rendering.
**Cons**: Immutable state copy overhead, learning curve for message-passing model.

### Pattern B: Imperative Paint-Surface — from utopia_tui

```
TuiRunner
  │
  ├── ctx.clear()
  ├── app.build(ctx)       // imperative painting into TuiSurface
  ├── ctx.renderDialogOverlay()
  ├── ctx.snapshot()       // diff against previous frame
  └── write changed rows to terminal
```

**Pros**: Familiar OOP pattern, easy state mutation, simpler mental model.
**Cons**: Harder to test, side effects in build phase, mutable state management.

### Recommended Synthesis

Use **Pattern A (TEA)** for the application architecture but **Pattern B's surface/painting** for the rendering layer. The best of both worlds:

```
Model (immutable)
  → View (declarative widget tree)
    → Layout (size calculation + position assignment)
      → Paint (render widgets into a 2D cell grid)
        → Diff (compare grid with previous frame)
          → Output (ANSI escape sequences to terminal)
```

---

## The Rendering Pipeline

### Layer 1: The 2D Cell Grid (TuiSurface-style)

```dart
class Cell {
  String char;          // grapheme cluster (may be multi-byte)
  TextStyle style;      // active SGR attributes
  bool wideContinuation; // true if this cell is the second half of a wide char
}

class Surface {
  List<List<Cell>> grid;  // width × height
  int width, height;

  void putText(x, y, text, style);     // grapheme-aware, wide-char aware, clipped
  void fillRect(x, y, w, h, char, style);
  void clearRect(x, y, w, h);
  void drawBorder(rect, borderChars, style, title);
  List<String> toAnsiLines();           // one string per row with ANSI codes
  List<String> toPlainLines();          // plain text per row for diff
}
```

### Layer 2: Widget → Paint

Each widget receives a `Rect` and a `Surface` and paints into it:

```dart
abstract class Widget {
  Size layout(Constraints constraints);  // measure pass
  void paint(PaintingContext context);   // render pass
}
```

**Layout algorithm** (from utopia_tui's TuiLayout):
```
splitHorizontal(total, [fixed|flexible...], gap):
  - Fixed items get their exact width
  - Remaining space = total - sum(fixed) - gaps
  - Flexible items split remaining space evenly (or proportionally)

splitVertical(total, [fixed|flexible...], gap):
  - Same algorithm vertically
```

### Layer 3: Diff-based Output

From dart_tui's AnsiRenderer / utopia_tui's `_redraw()`:

```
PreviousFrame:
  [line0_plain, line1_plain, ...]
  [line0_styled, line1_styled, ...]

CurrentFrame:
  [line0_plain', line1_plain', ...]
  [line0_styled', line1_styled', ...]

For each row:
  if prev_plain[r] != curr_plain[r] || prev_styled[r] != curr_styled[r]:
    emit: CSI row;0H + curr_styled[r]
```

**Two levels of diff quality** (from dart_tui):

| Renderer | Granularity | Best For |
|---|---|---|
| Line-level (AnsiRenderer) | Entire row diff | Terminals with sync support (?2026) |
| Cell-level (CellRenderer) | Individual cell diff | Terminals without sync; less flicker |

**Cell renderer** (dart_tui CellRenderer):
```
Parse content into Cells[char, attrs] per position
For each cell:
  if attrs changed from previous: emit new SGR code
  if char changed: move cursor to (row, col), write char
```

### Layer 4: Synchronized Updates

From termlib and dart_tui — when terminal supports it:

```
\x1b[?2026h   // start synchronized update
  ... (all diff writes) ...
\x1b[?2026l   // end synchronized update (terminal flushes atomically)
```

This eliminates tearing/flicker entirely by batching all output.

---

## Styling System Design

### The Style Object (from dart_tui's Style + termlib's Style)

```dart
class TextStyle {
  // Colors (tiered for capability downgrade)
  RgbColor? foreground;        // true color
  int? foreground256;          // 256-color palette index
  AnsiColor? foregroundAnsi;   // 16-color ANSI
  // Same for background...

  // Text attributes
  bool bold, dim, italic, underline, blink, reverse, strikethrough, overline;

  // Layout
  EdgeInsets padding, margin;
  Border? border;
  int? width, height;
  TextAlign align;
  bool wordWrap;

  // Color resolution
  Color resolveForeground(ColorProfile profile) {
    // CompleteColor: pick appropriate tier
    // AdaptiveColor: pick light/dark based on bg
    // Otherwise: downgrade truecolor → 256 → 16 based on profile
  }
}
```

**Color capability downgrade chain:**
```
TrueColor (24-bit) → 256-color palette → ANSI 16 → no color
```

**Style inheritance** (dart_tui's `Style.inherit()`):
```
child.inherit(parent) → fills null fields from parent
Useful for theme-based component styling
```

### Color Management (from termlib)

```dart
class Color {
  ColorKind kind; // noColor, ansi(0-15), indexed(0-255), rgb(0xFFFFFF)

  Color convert(ColorKind target) {
    // rgb → indexed: 6×6×6 cube + grayscale ramp, nearest color by redmean distance
    // indexed → ansi: palette mapping
    // Never upgrades, only downgrades
  }

  String sequence({bool background}); // produce \x1b[38;...m or \x1b[48;...m
}
```

---

## Event Loop Design

From dart_tui's Program — the most mature loop:

```
while (running):
  // Drain ALL pending messages first
  while (queue.isNotEmpty && running):
    model, cmd = model.update(msg)    // or handle system Msg
    if cmd: fire(cmd)                  // async, result enqueues back
    fps_throttle.tick()

  // Render ONCE for the batch
  if (needs_render && running):
    view = model.view()
    renderer.render(view)

  // Wait for more activity
  FPS-throttled wait (e.g., 16ms for 60fps)
```

**Key properties:**
- All messages drain before any render — rapid events never block
- Commands are fire-and-forget (unawaited futures)
- FPS throttle only caps screen output, not message processing
- Timer for ESC disambiguation (10ms — standalone ESC vs escape sequence lead-in)

### Message Types

```
System Messages:
  QuitMsg, InterruptMsg, SuspendMsg, ResumeMsg
  WindowSizeMsg, ClearScreenMsg
  EnterAltScreenMsg, ExitAltScreenMsg
  HideCursorMsg, ShowCursorMsg
  PrintLineMsg (for println-style output above the TUI)
  ExecMsg (run external process)

Input Messages:
  KeyMsg (with key code, modifiers, runes)
  MouseMsg (button, action, x, y)
  FocusMsg, BlurMsg
  PasteMsg (bracketed paste content)

Custom Messages:
  User-defined: class MyMsg extends Msg {}
```

### Command System (side effects)

```dart
typedef Cmd = FutureOr<Msg?> Function();

// Built-in helpers:
Cmd tick(Duration, Msg Function(DateTime));     // one-shot delay
Cmd every(Duration, Msg Function(DateTime));    // repeating, wall-clock aligned
Cmd batch(List<Cmd?>);                          // concurrent execution
Cmd sequence(List<Cmd?>);                       // sequential execution
Cmd execProcess(String exe, List<String> args); // external process
```

---

## Component Library Architecture

From dart_tui's 27+ components — each component is a Model subclass:

```dart
class TextInputModel extends TeaModel {
  // State
  String value;
  int cursorPosition;
  EchoMode echoMode;
  String? Function(String)? validator;

  // Messages
  // KeyMsg → update character at cursor
  // TickMsg → blink cursor

  // View
  View view() {
    // Render current value with cursor position indicator
  }
}
```

**Composition pattern:**
```dart
class ParentModel extends TeaModel {
  final child = TextInputModel();

  (Model, Cmd?) update(Msg msg) {
    // Forward relevant messages to child
    if (msg is KeyMsg) return child.update(msg);
    return (this, null);
  }

  View view() {
    final inputView = child.view();
    // Compose into parent view
  }
}
```

---

## Implementation Strategy

### Recommended Package Structure

```
your_tui/
├── lib/
│   ├── your_tui.dart          # barrel export
│   ├── src/
│   │   ├── ansi/              # ANSI escape code definitions
│   │   │   ├── codes.dart     #   ESC, CSI, OSC, etc.
│   │   │   ├── color.dart     #   Color sequences
│   │   │   ├── cursor.dart    #   Cursor sequences
│   │   │   ├── erase.dart     #   Erase sequences
│   │   │   └── term.dart      #   Terminal mode sequences
│   │   ├── parser/            # Input parsing (VT500)
│   │   │   ├── engine.dart    #   State machine
│   │   │   ├── parser.dart    #   Semantic parsers
│   │   │   └── events.dart    #   Event types
│   │   ├── unicode/           # Unicode support
│   │   │   ├── tables.dart    #   3-stage lookup tables
│   │   │   └── width.dart     #   Width/emoji queries
│   │   ├── core/              # Core rendering
│   │   │   ├── surface.dart   #   2D cell grid
│   │   │   ├── style.dart     #   TextStyle with color resolution
│   │   │   ├── layout.dart    #   Split/measure algorithm
│   │   │   ├── rect.dart      #   Rect, Point, Insets
│   │   │   └── widget.dart    #   Widget abstract class
│   │   ├── renderer/          # Output strategies
│   │   │   ├── diff.dart      #   Frame comparison
│   │   │   ├── line.dart      #   Line-level renderer
│   │   │   └── cell.dart      #   Cell-level renderer
│   │   ├── loop/              # Event loop
│   │   │   ├── program.dart   #   TEA event loop
│   │   │   ├── model.dart     #   Model/OutcomeModel
│   │   │   ├── cmd.dart       #   Command (side effect)
│   │   │   └── msg.dart       #   Message types
│   │   ├── terminal/          # Terminal I/O
│   │   │   ├── raw.dart       #   Raw mode (FFI)
│   │   │   ├── probe.dart     #   Capability detection
│   │   │   └── runner.dart    #   Lifecycle manager
│   │   └── widgets/           # Built-in components
│   │       ├── text.dart
│   │       ├── box.dart
│   │       ├── list.dart
│   │       ├── input.dart
│   │       ├── spinner.dart
│   │       ├── progress.dart
│   │       ├── table.dart
│   │       └── ...
```

### Development Order (recommended)

**Phase 1 — Foundation**
1. ANSI code definitions (termansi-style, pure constants)
2. Raw mode + terminal I/O
3. Unicode width tables
4. Input parser (VT500 state machine)

**Phase 2 — Rendering Core**
5. 2D cell grid (Surface)
6. TextStyle with color resolution/downgrade
7. Layout algorithm
8. Diff engine (line-level first, cell-level later)
9. Synchronized update support

**Phase 3 — Application Architecture**
10. TEA event loop (Program)
11. Model/Msg/Cmd types
12. Terminal capability probing
13. Lifecycle manager (TermRunner-style)
14. Signal handling (SIGINT, SIGTERM, SIGTSTP)

**Phase 4 — Widget Library**
15. Text, Box (border + padding), Spacer
16. Row/Column layout
17. Scrollable viewport
18. Text input
19. List (selectable)
20. Progress, Spinner
21. Table
22. Dialog/overlay

**Phase 5 — Polish**
23. Cell-level renderer
24. Kitty keyboard protocol
25. Mouse support
26. Clipboard integration
27. Hyperlinks
28. Performance benchmarking
29. Testing utilities (virtual terminal for tests)

---

## Key Design Decisions

### What to borrow from each project:

| Concept | Source | Why |
|---|---|---|
| TEA architecture | dart_tui | Most ergonomic declarative model |
| Cell-level diff | dart_tui | Flicker-free on all terminals |
| Canvas compositing | dart_tui | z-index layering for complex layouts |
| 2-stage parser | termparser | Correct VT500-compatible parsing |
| Unicode 3-stage lookup | termunicode | O(1) character properties |
| Color management | termlib | Proper downgrade chain |
| Capability probe | termlib | Adaptive behavior |
| Imperative paint surface | utopia_tui | Simple, fast rasterization |
| Layout split algorithm | utopia_tui | Proven flex layout |
| Theme system | utopia_tui | Easy customization |
| Widget → paint pattern | utopia_tui | Familiar OOP pattern |

### What to avoid:

- **String-based rendering only** (no surface grid) — breaks down for complex layouts
- **Full-screen clears every frame** — flicker and performance issues
- **No wide character support** — broken display for CJK/emoji
- **No color capability detection** — degraded experience on basic terminals
- **Synchronous-only input** — blocks animations and responsiveness
