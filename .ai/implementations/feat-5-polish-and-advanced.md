# Implementation Plan: Feature 5 — Polish & Advanced Features

**Version:** 1
**Feature:** Feat-5 Polish & Advanced
**Phase:** 5 | **Priority:** P2 | **Scope:** 3 stories, 7 tasks
**Depends on:** All prior features (Feat-1 through Feat-4)
**Constraint:** No 3rd party dependencies — only Dart SDK (`dart:io`, `dart:async`, `dart:convert`, `dart:math`, `dart:collection`)

---

## Architecture Overview

Feature 5 adds three major capabilities on top of the existing TUI framework:

```
┌──────────────────────────────────────────────────┐
│                  Feat-5 Scope                      │
│                                                    │
│  Story 5.1: Cell-Level Renderer                    │
│  ┌──────────────────┐    ┌─────────────────────┐   │
│  │ CellRenderer     │                         │   │
│  │ (cell-level diff)│                         │   │
│  └───────┬──────────┘    └─────────────────────┘   │
│          │ uses                                     │
│          ▼                                          │
│  ┌──────────────────┐                              │
│  │ Cell (existing)  │ ← Frame (existing)            │
│  └──────────────────┘                              │
│                                                    │
│  Story 5.2: Advanced Input                          │
│  ┌──────────┐ ┌──────────┐ ┌────────┐ ┌─────────┐ │
│  │ Kitty    │ │ Mouse    │ │Clipboard│ │Hyperlink│ │
│  │ Keyboard │ │ (SGR)    │ │(OSC 52) │ │(OSC 8)  │ │
│  └────┬─────┘ └────┬─────┘ └───┬────┘ └────┬────┘ │
│       │             │           │           │       │
│       └──────┬──────┘           │           │       │
│              ▼                  ▼           ▼       │
│  ┌──────────────────────┐  ┌─────────────┐         │
│  │ TermParser (extend)  │  │ ansi/term   │         │
│  │ CsiParser (extend)   │  │ (sequences) │         │
│  │ events (extend)      │  └─────────────┘         │
│  └──────────────────────┘                          │
│                                                    │
│  Story 5.3: Testing & Quality                       │
│  ┌──────────────────────┐  ┌────────────────────┐  │
│  │ VirtualTerminal      │  │ WidgetTester       │  │
│  │ (in-memory ANSI      │  │ (pumpWidget,       │  │
│  │  terminal emulator)  │  │  sendKeyEvent,     │  │
│  └──────────┬───────────┘  │  expectCell)       │  │
│             │              └────────────────────┘  │
│             ▼                                       │
│  ┌──────────────────────┐                          │
│  │ Cell + Surface       │                          │
│  │ (reuse existing)     │                          │
│  └──────────────────────┘                          │
└──────────────────────────────────────────────────────┘
```

---

## Guiding Principles

| Principle | Application |
|-----------|-------------|
| **Single Responsibility** | Each file owns exactly one concern: `cell_renderer.dart` does diff, `frame.dart` (unchanged) provides diff results |
| **DRY** | Shared rendering patterns extracted; mouse/kitty parsing uses existing CSI parser patterns; virtual terminal reuses `Cell` and `TextStyle` |
| **Pure functions where possible** | `CellRenderer.render()` is deterministic given two frames |
| **Sealed class exhaustiveness** | New events added to the existing sealed `Event` hierarchy; new messages to `Msg` hierarchy |
| **Graceful degradation** | Every advanced protocol detects capability and falls back; no crashes on unsupported terminals |
| **Testability** | Virtual terminal enables testing all rendering without a real terminal |
| **No magic values** | All new ANSI sequences in `ansi/term.dart` as named functions; probe timeouts in `WellKnown` |

---

## Directory & File Structure

```
lib/
├── t22e.dart                                          # UPDATE: barrel exports
├── src/
│   ├── ansi/
│   │   └── term.dart                                  # UPDATE: add clipboard, hyperlink, kitty, mouse seqs
│   ├── parser/
│   │   ├── events.dart                                # UPDATE: add clipboard event, hyperlink event, kitty key parsing
│   │   ├── csi_parser.dart                            # UPDATE: add kitty CSI parsing, improve mouse parsing
│   │   └── osc_parser.dart                            # UPDATE: add clipboard/hyperlink OSC event emission
│   ├── core/
│   │   └── style.dart                                 # UPDATE: add TextStyle.link() convenience
│   ├── renderer/
│   │   └── cell_renderer.dart                         # NEW  (5.1.1) — Cell-level diff renderer
│   ├── testing/
│   │   ├── virtual_terminal.dart                      # NEW  (5.3.1) — In-memory ANSI terminal emulator
│   │   └── widget_tester.dart                         # NEW  (5.3.2) — Widget test harness + assertions
│   └── widgets/
│       └── basic/
│           └── link.dart                              # NEW  (5.2.4) — HyperlinkSpan widget
test/
├── all_test.dart                                      # UPDATE
├── renderer/
│   └── cell_renderer_test.dart                        # NEW  — cell-level renderer tests
├── testing/
│   ├── virtual_terminal_test.dart                     # NEW  — virtual terminal tests
│   └── widget_tester_test.dart                        # NEW  — widget test utility tests
├── clipboard_test.dart                                # NEW  — clipboard integration tests
└── widgets/
    └── basic/
        └── link_test.dart                             # NEW  — hyperlink widget tests
```

---

## Task Details

---

### Story 5.1 — Cell-Level Renderer (L, 1 task)

#### Task 5.1.1: Cell-Level Diff Renderer

**File:** `lib/src/renderer/cell_renderer.dart`

**Purpose:** Compare individual cells between two frames and emit ANSI only for changed cells. Significantly reduces output vs. line-level on sparse updates.

**Design:**

```dart
class CellRenderer {
  const CellRenderer();

  String render(Frame previous, Frame current);
}
```

**Algorithm:**

```
For each row r in [0, max(current.height, previous.height)):
  For each col c in [0, current.width):
    prevCell = cellAt(previous, r, c)
    currCell = cellAt(current, r, c)

    If both exist and equal: skip
    If currCell is wideContinuation: skip
    If different char or different style:
      If style changed or previous didn't exist:
        emit SGR for new style
      If char changed or previous didn't exist:
        emit CSI r+1;c+1 H + currCell.char
```

**Key behaviors:**
- For cells outside previous frame (resize), always emit
- For wide characters, only emit at the start cell; skip continuation cells
- SGR codes emitted only when style changes (tracks `TextStyle? lastEmittedStyle` per row)
- Cursor positioning via absolute addressing `CSI row;col H` using `moveTo(row, col)` from `ansi/cursor.dart`
- Uses `ansi/cursor.dart:moveTo()` for cursor positioning
- Uses `ansi/codes.dart:bold(true)`, etc. for SGR sequences

**Performance target:** Diff 80×24 grid in < 0.5ms

**Dart documentation references:**
- https://api.dart.dev/stable/dart-core/StringBuffer-class.html
- https://api.dart.dev/stable/dart-core/StringBuffer/write.html

**Tests (`test/renderer/cell_renderer_test.dart`):**
- Single cell char change
- Single cell style change
- Both char and style change
- Wide character update (only at start cell)
- Full frame (no previous = all emitted)
- Resize (new cells outside previous frame)
- No change (empty output)
- SGR optimization (same style across adjacent cells = no redundant SGR)

---

---

### Story 5.2 — Advanced Input (L, 4 tasks)

#### Task 5.2.1: Kitty Keyboard Protocol

**Files affected:**
- `lib/src/ansi/term.dart` — already has `enableKittyKeyboard()`, `disableKittyKeyboard()`, `queryKittyKeyboard()` (existing)
- `lib/src/parser/events.dart` — update `KeyEvent` if needed for new event types
- `lib/src/parser/csi_parser.dart` — implement `_parseKittyKey()` dispatch

**Purpose:** Full Kitty keyboard protocol support — Ctrl+letter sends actual key code, proper press/repeat/release events.

**Implementation:**

In `csi_parser.dart`, the `parse()` method already handles Kitty-style CSI sequences. Need to:

1. Add dispatch for Kitty key events when intermediate byte is `0x3E` (`>`) and final byte is `0x75` (`u`) — this is the CSI `>` prefix for Kitty protocol responses.

```dart
// In csi_parser.dart parse():
// CSI > params u — Kitty keyboard event
// Already partially implemented via _parseKittyKey/_kittyCodeMap/_kittyModifiers
// Need to wire it: detect '>' intermediate + 'u' final byte → _parseKittyKey(params)
```

2. The Kitty event format `CSI code;modifiers;eventType;text;baseline;focused u`:
   - `code`: key code (ASCII for printable, special values for controls)
   - `modifiers`: bitmask (1=shift, 2=alt, 4=ctrl, 8=meta)
   - `eventType`: 1=press, 2=release, 3=repeat
   - `text`: UTF-8 encoded text for the key (optional)
   - `baseline`: unshifted key code (optional)
   - `focused`: 0/1 (optional)

3. The existing `_kittyCodeMap` maps special codes to `KeyCode` enum values; `_kittyModifiers` decodes bitmask.

4. When enable flags >= 1 (DISAMBIGUATE): `Tab` vs `Ctrl+I`, `Esc` vs `Ctrl+[`, `Enter` vs `Ctrl+M` are all disambiguated.

**Enabling in `Program`:**

In `lib/src/loop/program.dart`, after capability probe confirms `KeyboardProtocol.kitty`:
- Call `stdout.write(enableKittyKeyboard(flags))` where flags = 1 (disambiguate) | 2 (event types) = 3
- On shutdown, call `stdout.write(disableKittyKeyboard())`

**Dart documentation references:**
- https://api.dart.dev/stable/dart-core/int/bitLength.html
- https://api.dart.dev/stable/dart-core/List/sublist.html
- https://api.dart.dev/stable/dart-core/Set-class.html

**Tests (existing `test/parser/csi_parser_test.dart` update):**
- Kitty: Ctrl+C sends code 3 with ctrl modifier
- Kitty: Tab (vs Ctrl+I) sends code 9 with no ctrl
- Kitty: Key repeat sends event type 3
- Kitty: Key release sends event type 2

---

#### Task 5.2.2: Mouse Support (SGR)

**Files affected:**
- `lib/src/ansi/term.dart` — UPDATE: already has `enableNormalMouse()`, `enableButtonEvents()`, `enableSgrMouse()`, `disableMouse()`
- `lib/src/parser/csi_parser.dart` — UPDATE: `_parseSgrMouseParams()` exists, needs drag event handling
- `lib/src/parser/events.dart` — UPDATE: `MouseEvent` already has `MouseAction.drag`
- `lib/src/loop/program.dart` — UPDATE: enable mouse modes on start, disable on shutdown
- `lib/src/lifecycle/alt_screen_manager.dart` — UPDATE: enable mouse when entering alt screen

**Purpose:** SGR mouse mode with click, release, drag, and wheel events.

**SGR Mouse Protocol:**
- Enable: `CSI ? 1000 h` (basic), `CSI ? 1002 h` (button events + drag), `CSI ? 1006 h` (SGR encoding)
- Disable: `CSI ? 1000 l`, `CSI ? 1002 l`, `CSI ? 1006 l`
- Event format: `CSI < button;x;y {M,m}` — `M` = press, `m` = release
- Button encoding: 0=left, 1=middle, 2=right, 32=drag, 64=wheel_up, 65=wheel_down

**Implementation in `csi_parser.dart`:**

The existing `_parseSgrMouseParams()` handles basic press/release. Need to extend:

```dart
Event? _parseSgrMouseParams(List<int> params) {
  final cb = params[0];
  final x = params[1] - 1;  // 1-based → 0-based
  final y = params[2] - 1;

  // Detect wheel
  if (cb == 64) return MouseEvent(button: MouseButton.wheelUp, action: MouseAction.press, x: x, y: y);
  if (cb == 65) return MouseEvent(button: MouseButton.wheelDown, action: MouseAction.press, x: x, y: y);

  // Detect drag (bit 5 set)
  if ((cb & 32) != 0 && (cb & 3) != 3) {
    final button = _mouseButtonFromCode(cb & 3);
    return MouseEvent(button: button, action: MouseAction.drag, x: x, y: y);
  }

  // Detect release (bit 5 set, lower bits = 3 for "no button")
  if ((cb & 32) != 0) {
    return MouseEvent(button: MouseButton.none, action: MouseAction.release, x: x, y: y);
  }

  // Detect press
  final button = _mouseButtonFromCode(cb & 3);
  return MouseEvent(button: button, action: MouseAction.press, x: x, y: y);
}
```

**Enabling in `Program`:**
- In `Program.run()`: call `stdout.write(enableNormalMouse())`, `stdout.write(enableButtonEvents())`, `stdout.write(enableSgrMouse())`
- In `Program._shutdown()`: call `stdout.write(disableMouse())`

**Dart documentation references:**
- https://api.dart.dev/stable/dart-core/String/write.html
- https://api.dart.dev/stable/dart-io/Stdout/write.html

**Tests (`test/parser/csi_parser_test.dart` update):**
- Left click: `\x1b[<0;5;10M` → button=left, action=press, x=4, y=9
- Right click: `\x1b[<2;5;10M` → button=right
- Release: `\x1b[<0;5;10m` → button=left, action=release
- Drag: `\x1b[<32;5;10M` → button=left, action=drag
- Wheel up: `\x1b[<64;5;10M` → button=wheelUp
- Wheel down: `\x1b[<65;5;10M` → button=wheelDown

---

#### Task 5.2.3: Clipboard Integration

**Files affected:**
- `lib/src/ansi/term.dart` — UPDATE: add `queryClipboard()`, `writeClipboard()`
- `lib/src/parser/osc_parser.dart` — UPDATE: emit typed event for clipboard responses

**Purpose:** Read/write system clipboard via OSC 52.

**Implementation:**

In `ansi/term.dart`:
```dart
String writeClipboard(String base64Data, {String clipboard = 'c'}) =>
    '\x1b]52;$clipboard;$base64Data\x07';
String queryClipboard({String clipboard = 'c'}) =>
    '\x1b]52;$clipboard;?\x07';
```

Create `Clipboard` class:
```dart
class Clipboard {
  static Future<String?> read(TerminalIo io, {Duration timeout = ...}) async {
    // Send query, listen for OSC 52 response, parse base64
  }

  static Future<void> write(TerminalIo io, String text) async {
    // Encode text as base64, send OSC 52
  }
}
```

In `osc_parser.dart`: Update OSC 52 handling to emit a proper `ClipboardEvent` (new event type) instead of `InternalEvent`:

```dart
// Add to events.dart:
final class ClipboardEvent extends Event {
  final String clipboard;  // 'c' or 'p'
  final String? base64;    // null if query, data if response
  const ClipboardEvent(this.clipboard, this.base64);
}

// In osc_parser.dart:
52 => _parseClipboard(value),
```

**Base64 encoding/decoding:** Use `dart:convert` `base64Encode` / `base64Decode`.

**Dart documentation references:**
- https://api.dart.dev/stable/dart-convert/base64Encode.html
- https://api.dart.dev/stable/dart-convert/base64Decode.html
- https://api.dart.dev/stable/dart-async/Completer-class.html
- https://api.dart.dev/stable/dart-async/Timer/Timer.html

**Tests (`test/osc_parser_test.dart` update + `test/clipboard_test.dart`):**
- OSC 52 parse: `\x1b]52;c;SGVsbG8=\x07` → ClipboardEvent('c', 'SGVsbG8=')
- Base64 round-trip encode/decode
- Graceful degradation: timeout returns null

---

#### Task 5.2.4: Hyperlinks

**Files affected:**
- `lib/src/ansi/term.dart` — UPDATE: already has `hyperlink()` function
- `lib/src/core/style.dart` — UPDATE: add `TextStyle.link()` convenience constructor
- `lib/src/widgets/basic/link.dart` — NEW: `HyperlinkSpan` widget

**Purpose:** Render clickable hyperlinks via OSC 8 sequences.

**Implementation:**

In `ansi/term.dart` (already exists):
```dart
String hyperlink(String uri, String text) => '\x1b]8;;${uri}\x07${text}\x1b]8;;\x07';
```

Extend with optional `id` parameter:
```dart
String hyperlink(String uri, String text, {String? id}) {
  final params = id != null ? 'id=$id' : '';
  return '\x1b]8;$params;$uri\x07$text\x1b]8;;\x07';
}
```

In `style.dart`:
```dart
TextStyle.link({String? uri}) => TextStyle(
  foreground: Color.rgb(0, 102, 204),  // blue
  underline: true,
);
```

New widget `link.dart`:
```dart
class HyperlinkSpan extends Widget {
  final String uri;
  final String text;
  final TextStyle? style;

  // layout: measure text width
  // paint: render with hyperlink ANSI wrapping
}
```

**Hyperlink in `Surface`:**
The `Surface` class needs to be aware of hyperlinks. Add optional `hyperlink` field to `Cell` or handle via ANSI wrapping in the output renderer. Since hyperlinks are an ANSI-level feature, the cleanest approach is to handle them at the renderer level:

Option A: Add `String? hyperlink` to `Cell` and emit OSC 8 sequences in `toAnsiLines()` / cell renderer.
Option B: Handle hyperlink wrapping in the `HyperlinkSpan` widget's paint method by writing start/end markers.

Use **Option A**: Add `hyperlink` field to `Cell` and emit OSC 8 wrapping in both `line_renderer.dart` and `cell_renderer.dart`.

**Dart documentation references:**
- https://api.dart.dev/stable/dart-core/String-class.html
- https://api.dart.dev/stable/dart-core/Uri-class.html

**Tests (`test/widgets/basic/link_test.dart`):**
- Hyperlink widget renders text with OSC 8 wrapping
- URI encoded without breaking param separators
- Optional id param included
- Without id param, params field is empty
- Graceful degradation: on unsupported terminals, renders plain underlined text

---

### Story 5.3 — Testing & Quality (M, 2 tasks)

#### Task 5.3.1: Virtual Terminal for Tests

**File:** `lib/src/testing/virtual_terminal.dart`

**Purpose:** In-memory ANSI terminal emulator for deterministic testing without a real terminal.

**Design:**

```dart
class VirtualTerminal {
  int width;
  int height;
  late List<List<Cell>> _grid;
  int _cursorX = 0;
  int _cursorY = 0;
  TextStyle _currentStyle = TextStyle.empty;
  bool _altScreen = false;
  List<List<Cell>> _normalScreenBuffer = [];

  VirtualTerminal({this.width = 80, this.height = 24}) {
    _resetGrid();
  }

  void write(String ansi);
  void resize(int newWidth, int newHeight);

  Cell cellAt(int row, int col);
  String plainText();
  String styledText();

  void _resetGrid();
  void _newline();
  void _scrollUp();
}
```

**Supported ANSI operations:**
- SGR: bold, dim, italic, underline, blink, reverse, strikethrough, overline, foreground/background color (24-bit, 256, 16)
- Cursor: `CSI row;col H` (absolute), `CSI A`/`B`/`C`/`D` (relative up/down/right/left), save/restore
- Erase: `CSI J` (screen clear), `CSI K` (line clear), `CSI ? J` (protected)
- Line feed (`\n`), carriage return (`\r`)
- Scroll: when cursor passes bottom, scroll content up
- Alternate screen: track buffer swap
- Reset: `ESC c` (RIS)

**Implementation approach:**

Parse ANSI sequences using the existing `Vt500Engine` + `CsiParser` from the parser module (reuse, don't duplicate). Actually, for simplicity and to avoid a dependency on real stdin, implement a lightweight ANSI sequence parser specifically for the virtual terminal. The virtual terminal needs to handle output sequences (SGR, cursor, erase), not input sequences (key events).

The cleanest approach: implement ANSI parsing directly in `VirtualTerminal.write()` by scanning for `\x1b[` sequences and dispatching to internal handlers. This keeps the virtual terminal self-contained and avoids coupling to the input parser.

```dart
void write(String ansi) {
  final buffer = ansi;
  var i = 0;
  while (i < buffer.length) {
    if (buffer.codeUnitAt(i) == 0x1B && i + 1 < buffer.length) {
      if (buffer.codeUnitAt(i + 1) == 0x5B) { // CSI
        i = _handleCsi(buffer, i + 2);
      } else if (buffer.codeUnitAt(i + 1) == 0x5D) { // OSC
        i = _handleOsc(buffer, i + 2);
      } else if (buffer.codeUnitAt(i + 1) == 0x63) { // RIS
        _resetGrid();
        i += 2;
      } else {
        i += 2;
      }
    } else if (buffer.codeUnitAt(i) == 0x0A) { // LF
      _newline();
      i++;
    } else if (buffer.codeUnitAt(i) == 0x0D) { // CR
      _cursorX = 0;
      i++;
    } else {
      _putChar(buffer[i]);
      i++;
    }
  }
}
```

**Dart documentation references:**
- https://api.dart.dev/stable/dart-core/RegExp-class.html
- https://api.dart.dev/stable/dart-core/String/codeUnitAt.html
- https://api.dart.dev/stable/dart-core/int/parse.html
- https://api.dart.dev/stable/dart-core/StringBuffer-class.html

**Tests (`test/testing/virtual_terminal_test.dart`):**
- Write plain text → appears in grid
- Write SGR → subsequent text styled
- `\x1b[1m` → bold=true on subsequent cells
- `\x1b[31m` → red foreground on subsequent cells
- `\x1b[2J` → all cells cleared
- `\x1b[5;10H` → cursor positioned to row 5, col 10
- Newlines: cursor moves down, scrolls at bottom
- Wide characters: occupy 2 cells
- Resize: grid reshaped, content preserved within bounds
- Cell inspection: `cellAt(0, 0) == Cell(char: 'H', style: TextStyle(...))`

---

#### Task 5.3.2: Widget Test Utilities

**File:** `lib/src/testing/widget_tester.dart`

**Purpose:** Test harness for widgets — render a widget tree into `VirtualTerminal`, simulate key events, and assert on cell state.

**Design:**

```dart
class WidgetTester {
  final VirtualTerminal virtualTerminal;
  final Surface _surface;
  Model? _model;

  WidgetTester({int width = 80, int height = 24})
      : virtualTerminal = VirtualTerminal(width: width, height: height),
        _surface = Surface(width, height);

  void pumpWidget(Widget root) {
    // 1. Create temporary Surface
    // 2. Layout: root.layout(Constraints(maxWidth, maxHeight))
    // 3. Paint: root.paint(PaintingContext(surface))
    // 4. Render: convert surface to ANSI via renderer
    // 5. Write ANSI to virtual terminal
    // 6. Save model state if applicable
  }

  void pumpWidgetWithModel(M model, {required Surface Function() view}) {
    _model = model;
    // Same as pumpWidget but also tracks model state
  }

  void sendKeyEvent(KeyCode key, {KeyModifiers? modifiers, int? codepoint}) {
    // 1. Create KeyMsg from key event
    // 2. If model exists, call model.update(msg)
    // 3. Get new view from model
    // 4. Re-render into virtual terminal
  }

  void sendMouseEvent(MouseButton button, MouseAction action, int x, int y) {
    // Similar to sendKeyEvent for mouse
  }

  // Assertions
  void expectCell(int row, int col, {String? char, TextStyle? style}) {
    final cell = virtualTerminal.cellAt(row, col);
    if (char != null) expect(cell.char, equals(char));
    if (style != null) expect(cell.style, equals(style));
  }

  void expectPlainText(String expected) {
    expect(virtualTerminal.plainText(), equals(expected));
  }

  void expectStyledText(String expected) {
    expect(virtualTerminal.styledText(), equals(expected));
  }
}
```

**Key integration points:**
- `WidgetTester.pumpWidget()` uses the existing rendering pipeline: `Widget.layout()` → `Widget.paint()` → `Surface.toAnsiLines()` → `VirtualTerminal.write()`
- No real terminal involved — `stdout` is never accessed
- All I/O is in-memory

**Dart documentation references:**
- https://pub.dev/documentation/test/latest/ — `expect()`, `equals()`, `throwsA`
- https://dart.dev/guides/testing

**Tests (`test/testing/widget_tester_test.dart`):**
- `pumpWidget(Text('Hello'))` → expectCell(0,0, char:'H') ... expectCell(0,4, char:'o')
- `pumpWidget(Box(...))` → border characters in grid
- `sendKeyEvent(KeyCode.enter)` → model state change → re-render
- `expectPlainText('...')` matches expected layout
- Integration test with TextInput: type characters, verify display

---

## Integration Points

### Existing files that need changes

| File | Change | Story |
|------|--------|-------|
| `lib/src/ansi/term.dart` | Add `writeClipboard()`, `queryClipboard()`, enhanced `hyperlink()` with `id` param | 5.2.3, 5.2.4 |
| `lib/src/parser/events.dart` | Add `ClipboardEvent` class | 5.2.3 |
| `lib/src/parser/csi_parser.dart` | Finalize `_parseKittyKey` dispatch for `>` intermediate + `u` final; extend mouse parsing for drag/wheel | 5.2.1, 5.2.2 |
| `lib/src/parser/osc_parser.dart` | Emit `ClipboardEvent` instead of `InternalEvent` for OSC 52 | 5.2.3 |
| `lib/src/core/style.dart` | Add `TextStyle.link()` constructor | 5.2.4 |
| `lib/src/core/cell.dart` | Add `String? hyperlink` field | 5.2.4 |
| `lib/src/renderer/line_renderer.dart` | Handle hyperlink OSC 8 wrapping when emitting lines | 5.2.4 |
| `lib/src/loop/program.dart` | Enable kitty keyboard and mouse modes on start; integrate `CellRenderer` as optional renderer | 5.2.1, 5.2.2 |
| `lib/src/lifecycle/alt_screen_manager.dart` | Enable mouse when entering alt screen | 5.2.2 |
| `lib/t22e.dart` | Export new public types | All |

### `Program` renderer selection logic

The `Program` class should support runtime selection between `LineRenderer` and `CellRenderer` based on terminal capability:

```dart
class Program<M extends Model<M>> {
  final SyncRenderer _lineRenderer;
  final CellRenderer _cellRenderer;
  final bool _useCellRenderer;

  Program(this._model, {..., bool useCellRenderer = false})
    : _lineRenderer = SyncRenderer(...),
      _cellRenderer = const CellRenderer(),
      _useCellRenderer = useCellRenderer;

  void _renderFrame() {
    // ... existing frame diff logic ...
    final output = _useCellRenderer
        ? _cellRenderer.render(_previousFrame!, currentFrame)
        : _lineRenderer.render(diffResult, currentFrame);
  }
}
```

When `KeyboardProbe` confirms Kitty protocol and terminal supports sync updates, `CellRenderer` is preferred.

---

## Implementation Order

| Step | Task | Description | Depends On |
|------|------|-------------|------------|
| 1 | `ansi/term.dart` update | Add clipboard, enhanced hyperlink sequences | Nothing |
| 2 | `events.dart` update | Add `ClipboardEvent` | Nothing |
| 3 | `csi_parser.dart` update | Wire Kitty key dispatch, extend mouse drag/wheel | 1 |
| 4 | `osc_parser.dart` update | Emit `ClipboardEvent` for OSC 52 | 2 |
| 5 | `cell.dart` update | Add `hyperlink` field | 1 |
| 6 | `style.dart` update | Add `TextStyle.link()` | Nothing |
| 7 | `cell_renderer.dart` | NEW: cell-level diff renderer | 5 |
| 8 | `link.dart` widget | NEW: HyperlinkSpan widget | 5, 6 |
| 9 | `program.dart` update | Enable kitty/mouse, integrate cell renderer | 3, 4, 7 |
| 10 | `alt_screen_manager.dart` update | Enable mouse on alt screen entry | 4 |
| 11 | `line_renderer.dart` update | Hyperlink OSC 8 wrapping | 5 |
| 12 | `virtual_terminal.dart` | NEW: in-memory ANSI emulator | Nothing |
| 13 | `widget_tester.dart` | NEW: widget test harness | 12, 7 |

| 15 | Barrel export | Update `t22e.dart` | All tasks |
| 16 | Test manifest | Update `all_test.dart` | All tasks |

---

## Dart Official Documentation References

| Topic | URL |
|-------|-----|
| Generics | https://dart.dev/language/generics |
| Sealed classes | https://dart.dev/language/class-modifiers#sealed |
| Abstract classes | https://dart.dev/language/classes#abstract-classes |
| Records | https://dart.dev/language/records |
| Switch expressions | https://dart.dev/language/branches#switch-expressions |
| Collections | https://dart.dev/language/collections |
| `StringBuffer` | https://api.dart.dev/stable/dart-core/StringBuffer-class.html |
| `Stopwatch` | https://api.dart.dev/stable/dart-core/Stopwatch-class.html |
| `DateTime` | https://api.dart.dev/stable/dart-core/DateTime-class.html |
| `File` | https://api.dart.dev/stable/dart-io/File-class.html |
| `base64Encode` | https://api.dart.dev/stable/dart-convert/base64Encode.html |
| `base64Decode` | https://api.dart.dev/stable/dart-convert/base64Decode.html |
| `Completer` | https://api.dart.dev/stable/dart-async/Completer-class.html |
| `Timer` | https://api.dart.dev/stable/dart-async/Timer-class.html |
| `StreamSubscription` | https://api.dart.dev/stable/dart-async/StreamSubscription-class.html |
| `unawaited()` | https://api.dart.dev/stable/dart-async/unawaited.html |
| `Future.wait()` | https://api.dart.dev/stable/dart-async/Future/wait.html |
| `int.bitLength` | https://api.dart.dev/stable/dart-core/int/bitLength.html |
| `Stdout.write` | https://api.dart.dev/stable/dart-io/Stdout/write.html |
| `Object.hash` | https://api.dart.dev/stable/dart-core/Object/hash.html |
| `List.of` | https://api.dart.dev/stable/dart-core/List/List.of.html |
| `String.codeUnitAt` | https://api.dart.dev/stable/dart-core/String/codeUnitAt.html |
| `StringBuffer.write` | https://api.dart.dev/stable/dart-core/StringBuffer/write.html |
| Writing tests | https://dart.dev/guides/testing |
| `package:test` | https://api.dart.dev/stable/dart-test/dart-test-library.html |
| `RegExp` | https://api.dart.dev/stable/dart-core/RegExp-class.html |
| `Uri` | https://api.dart.dev/stable/dart-core/Uri-class.html |

---

## Notes

- **No 3rd party dependencies:** All functionality uses only the Dart SDK. Base64 encoding uses `dart:convert`, no `package:base64` needed.
- **Graceful degradation:** Every advanced feature detects capability. If Kitty protocol probe fails → basic keyboard. If mouse not supported → no mouse events. If clipboard not supported → `read()` returns null. If hyperlinks not supported → renders as plain underlined text.
- **Test isolation:** `VirtualTerminal` and `WidgetTester` enable all tests to run in `dart test` without a real terminal. No `dart:io` stdout/stdin access in tests.
- **Mutable `Cell.hyperlink` field:** The existing `Cell` uses `final` fields. Adding `hyperlink` changes the constructor. This is acceptable because `Cell` is internal to the core rendering layer and not user-facing.
