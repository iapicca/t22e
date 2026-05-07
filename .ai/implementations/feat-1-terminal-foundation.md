# Implementation Plan: Feature 1 — Terminal Foundation

**Feature:** Feat-1 Terminal Foundation  
**Phase:** 1  
**Priority:** P0 — Must have  
**Depends on:** None  
**Estimate:** 4 stories, 16 tasks

---

## Table of Contents

1. [Overview & Guiding Principles](#1-overview--guiding-principles)
2. [Package Structure](#2-package-structure)
3. [Story 1.1 — ANSI Escape Code Definitions](#3-story-11--ansi-escape-code-definitions)
4. [Story 1.2 — Raw Mode & Terminal I/O](#4-story-12--raw-mode--terminal-io)
5. [Story 1.3 — Unicode Width Tables](#5-story-13--unicode-width-tables)
6. [Story 1.4 — Input Parser (VT500)](#6-story-14--input-parser-vt500)
7. [Testing Strategy](#7-testing-strategy)
8. [Implementation Order & Dependencies](#8-implementation-order--dependencies)
9. [Official Dart Documentation References](#9-official-dart-documentation-references)

---

## 1. Overview & Guiding Principles

### Architecture Decision

Use **pure top-level functions** for ANSI sequence generation (zero-logic definitions layer), **sealed classes** for the event type hierarchy, and **enhanced enums** for state machines. No 3rd party dependencies — only `dart:io`, `dart:ffi`, `dart:typed_data`, and `package:test` / `package:lints`.

### Design Principles

| Principle | Application |
|---|---|
| **Single Responsibility** | Each file owns one concern (e.g., `cursor.dart` only has cursor sequences, `engine.dart` only has the state machine). |
| **Pure Functions Where Possible** | ANSI code generators are `String`-returning pure functions — no I/O, no mutation, no futures. |
| **Separation of Concerns** | Parser Stage 1 (byte state machine) is completely independent from Stage 2 (semantic interpretation). |
| **Sealed Type Hierarchies** | Events use `sealed class` — the compiler enforces exhaustive pattern matching. |
| **No 3rd Party Dependencies** | Everything uses only the Dart SDK (`dart:io`, `dart:ffi`, `dart:typed_data`, `dart:convert`). |
| **Testability** | Every pure function is unit-testable without mocking. I/O-bound code (raw mode, FFI) is abstracted behind injectable interfaces or uses `try`/`finally` with explicit state. |

---

## 2. Package Structure

```
lib/
  t22e.dart                              # Barrel export — re-exports all public API
  src/
    ansi/                                 # Story 1.1 — ANSI escape sequence constants
      codes.dart                          #   ESC, CSI, OSC, DCS, ST, BEL + text attribute functions
      color.dart                          #   Foreground/background color sequences (RGB, 256, ANSI 16)
      cursor.dart                         #   Cursor positioning, show/hide, save/restore, style
      erase.dart                          #   Display/line erase modes
      term.dart                           #   Terminal mode toggles (alt screen, mouse, sync, paste, etc.)
    terminal/                             # Story 1.2 — Terminal I/O
      raw_io.dart                         #   dart:io raw mode (echoMode, lineMode)
      raw_ffi.dart                        #   FFI-to-libc raw mode (tcgetattr/tcsetattr)
      runner.dart                         #   Lifecycle manager (enter/exit/run)
    unicode/                              # Story 1.3 — Unicode width tables
      tables.dart                         #   3-stage lookup tables (generated data)
      width.dart                          #   charWidth, isEmoji, isPrintable, etc.
      grapheme.dart                       #   Grapheme cluster segmentation
    parser/                               # Story 1.4 — Input parser
      engine.dart                         #   VT500 13-state state machine
      events.dart                         #   Event type hierarchy (sealed class)
      csi_parser.dart                     #   CSI semantic parser
      esc_parser.dart                     #   ESC parser
      osc_parser.dart                     #   OSC parser
      dcs_parser.dart                     #   DCS parser
      parser.dart                         #   Combined parser (wires engine → semantic parsers)
tool/
  generate_unicode_tables.dart            # Script that downloads Unicode data and generates tables.dart
test/
  ansi/
    codes_test.dart
    color_test.dart
    cursor_test.dart
    erase_test.dart
    term_test.dart
  terminal/
    raw_io_test.dart
    raw_ffi_test.dart
    runner_test.dart
  unicode/
    tables_test.dart
    width_test.dart
    grapheme_test.dart
  parser/
    engine_test.dart
    events_test.dart
    csi_parser_test.dart
    esc_parser_test.dart
    osc_parser_test.dart
    dcs_parser_test.dart
    parser_test.dart
```

---

## 3. Story 1.1 — ANSI Escape Code Definitions

**Estimate:** M  
**Depends on:** None  
**Principle:** Zero-logic definitions layer — pure `String` constants and pure `String`-returning functions.

### Task 1.1.1 — ANSI Constants (`ansi/codes.dart`)

**API:**

```dart
// https://api.dart.dev/stable/dart-core/String-class.html
// Compile-time constants via const constructor (https://dart.dev/language/classes#constant-constructors)
const esc = '\x1b';
const csi = '\x1b[';
const osc = '\x1b]';
const dcs = '\x1bP';
const st = '\x1b\\';
const bel = '\x07';
```

**Dart docs references:**
- [`String` class](https://api.dart.dev/stable/dart-core/String-class.html) — `\x1b`, `\x07` escape sequences
- [`const` keyword](https://dart.dev/language/variables#final-and-const) — compile-time constant values
- [String interpolation](https://dart.dev/language/string-interpolation) — `'${value}'`

**AC:** All 6 constants defined; unit tests verify exact byte values via `expect(constant, equals('\x1b'))`.

### Task 1.1.2 — Color Sequences (`ansi/color.dart`)

**API (pure functions):**

```dart
// https://dart.dev/language/functions — top-level functions
String setForegroundRgb(int r, int g, int b) => '\x1b[38;2;$r;$g;${b}m';
String setBackgroundRgb(int r, int g, int b) => '\x1b[48;2;$r;$g;${b}m';
String setForeground256(int index) => '\x1b[38;5;${index}m';
String setBackground256(int index) => '\x1b[48;5;${index}m';
String foregroundAnsi(int color) => '\x1b[${30 + color}m';
String backgroundAnsi(int color) => '\x1b[${40 + color}m';
String foregroundBrightAnsi(int color) => '\x1b[${90 + color}m';
String backgroundBrightAnsi(int color) => '\x1b[${100 + color}m';
String resetColor() => '\x1b[39;49m';
```

**AC:** Truecolor, 256-palette, and ANSI 16 variants for fg and bg. All pure. Tested with exact string matching.

### Task 1.1.3 — Text Attribute Sequences (`ansi/codes.dart`)

```dart
// https://api.dart.dev/stable/dart-core/String-class.html
String bold(bool on) => on ? '\x1b[1m' : '\x1b[22m';
String dim(bool on) => on ? '\x1b[2m' : '\x1b[22m';
String italic(bool on) => on ? '\x1b[3m' : '\x1b[23m';
String underline(bool on) => on ? '\x1b[4m' : '\x1b[24m';
String blink(bool on) => on ? '\x1b[5m' : '\x1b[25m';
String reverse(bool on) => on ? '\x1b[7m' : '\x1b[27m';
String strikethrough(bool on) => on ? '\x1b[9m' : '\x1b[29m';
String overLine(bool on) => on ? '\x1b[53m' : '\x1b[55m';
String resetAll() => '\x1b[0m';
```

**Note:** Bold/dim share the same reset (SGR 22); italic uses 23, underline uses 24, etc.

### Task 1.1.4 — Cursor Sequences (`ansi/cursor.dart`)

```dart
// https://dart.dev/language/enums — CursorStyle enum
enum CursorStyle {
  blinkingBlock(1),
  steadyBlock(2),
  blinkingUnderline(3),
  steadyUnderline(4),
  blinkingBar(5),
  steadyBar(6);

  final int value;
  const CursorStyle(this.value);
}

String moveTo(int row, int col) => '\x1b[${row};${col}H';
String moveUp(int n) => '\x1b[${n}A';
String moveDown(int n) => '\x1b[${n}B';
String moveRight(int n) => '\x1b[${n}C';
String moveLeft(int n) => '\x1b[${n}D';
String moveColumn(int col) => '\x1b[${col}G';
String hideCursor() => '\x1b[?25l';
String showCursor() => '\x1b[?25h';
String saveCursor() => '\x1b[s';
String restoreCursor() => '\x1b[u';
String requestPosition() => '\x1b[6n';
String setStyle(CursorStyle style) => '\x1b[${style.value} q';
```

### Task 1.1.5 — Erase Sequences (`ansi/erase.dart`)

```dart
// https://api.dart.dev/stable/dart-core/String-class.html
String eraseDisplay(int mode) => '\x1b[${mode}J';
String eraseLine(int mode) => '\x1b[${mode}K';
String eraseScreen() => '\x1b[2J';
String eraseSavedLines() => '\x1b[3J';
String eraseLineToEnd() => '\x1b[0K';
String eraseLineToStart() => '\x1b[1K';
String eraseLineAll() => '\x1b[2K';
```

### Task 1.1.6 — Terminal Mode Sequences (`ansi/term.dart`)

```dart
// https://dart.dev/language/functions — pure function pattern
String enterAltScreen() => '\x1b[?1049h';
String exitAltScreen() => '\x1b[?1049l';
String enableNormalMouse() => '\x1b[?1000h';
String disableMouse() => '\x1b[?1000l\x1b[?1002l\x1b[?1006l';
String enableButtonEvents() => '\x1b[?1002h';
String enableSgrMouse() => '\x1b[?1006h';
String startSync() => '\x1b[?2026h';
String endSync() => '\x1b[?2026l';
String enableBracketedPaste() => '\x1b[?2004h';
String disableBracketedPaste() => '\x1b[?2004l';
String enableFocusTracking() => '\x1b[?1004h';
String disableFocusTracking() => '\x1b[?1004l';
String setTitle(String title) => '\x1b]0;${title}\x07';
String hyperlink(String uri, String text) => '\x1b]8;;${uri}\x07${text}\x1b]8;;\x07';
String enableKittyKeyboard(int flags) => '\x1b[>${flags}u';
String disableKittyKeyboard() => '\x1b[<u';
String queryKittyKeyboard() => '\x1b[?u';
String queryForegroundColor() => '\x1b]10;?\x07';
String queryBackgroundColor() => '\x1b]11;?\x07';
String softReset() => '\x1b[!p';
```

### Testing Approach for Story 1.1

All tests use:
- `import 'package:test/test.dart';` — https://api.dart.dev/stable/dart-test/dart-test-library.html
- Pure string comparison with `expect(actual, equals(expected))`
- Every function tested with at least 2 calls (typical + edge case)
- No mocking, no I/O — just pure function invocation

---

## 4. Story 1.2 — Raw Mode & Terminal I/O

**Estimate:** M  
**Depends on:** None (standalone)

### Task 1.2.1 — Raw Mode via dart:io (`terminal/raw_io.dart`)

```dart
// https://api.dart.dev/stable/dart-io/Stdin-class.html — echoMode, lineMode
import 'dart:io';

void enableRawModeIo() {
  stdin.echoMode = false;
  stdin.lineMode = false;
}

void disableRawModeIo() {
  stdin.echoMode = true;
  stdin.lineMode = true;
}
```

**Dart docs references:**
- [`Stdin.echoMode`](https://api.dart.dev/stable/dart-io/Stdin-class.html#echoMode)
- [`Stdin.lineMode`](https://api.dart.dev/stable/dart-io/Stdin-class.html#lineMode)

**AC:** echoMode and lineMode toggled; works cross-platform.

### Task 1.2.2 — Raw Mode via FFI to libc (`terminal/raw_ffi.dart`)

```dart
// https://api.dart.dev/stable/dart-ffi/dart-ffi-library.html
// https://api.dart.dev/stable/dart-ffi/Struct-class.html
// https://api.dart.dev/stable/dart-io/Platform-class.html

import 'dart:ffi';
import 'dart:io';

final class Termios extends Struct {
  @Int32()
  external int cIflag;
  @Int32()
  external int cOflag;
  @Int32()
  external int cCflag;
  @Int32()
  external int cLflag;
  // c_cc array would use @Array(20) or manually sized
}

bool get _isUnix => !Platform.isWindows;
```

**Dart docs references:**
- [`dart:ffi`](https://api.dart.dev/stable/dart-ffi/dart-ffi-library.html)
- [`Struct` class](https://api.dart.dev/stable/dart-ffi/Struct-class.html) — native struct layout
- [`Int32`, `Uint8`, `Pointer` types](https://api.dart.dev/stable/dart-ffi/index.html)
- [`DynamicLibrary.open()`](https://api.dart.dev/stable/dart-ffi/DynamicLibrary-class.html)
- [`Platform.isWindows`](https://api.dart.dev/stable/dart-io/Platform-class.html)

**Key implementation details:**
- Load `libSystem.dylib` on macOS, `libc.so.6`/`libc.so.7` on Linux
- Call `tcgetattr(0, &termios)` to read current state
- Modify `c_lflag`: clear `ECHO`, `ICANON`, `ISIG`, `IEXTEN`
- Optionally modify `c_iflag`: clear `ICRNL`, `IXON`, `IXOFF`
- Set `c_cc[VMIN] = 1`, `c_cc[VTIME] = 0`
- Call `tcsetattr(0, TCSANOW, &termios)` to apply
- Save original termios for restoration
- On Windows, fall back to `dart:io` approach

**AC:** Disables ECHO, ICANON, ISIG, IEXTEN; sets VMIN=1, VTIME=0; saves original; throws on error.

### Task 1.2.3 — Terminal Lifecycle Runner (`terminal/runner.dart`)

```dart
// https://dart.dev/language/control-flow — try/finally
// https://api.dart.dev/stable/dart-async/Zone-class.html — Zone.run
// https://api.dart.dev/stable/dart-io/ProcessSignal-class.html

class TerminalRunner {
  bool _isRawMode = false;

  void enterRawMode() {
    if (_isUnix) {
      _saveAndEnableRawModeViaFfi();
    } else {
      enableRawModeIo();
    }
    _isRawMode = true;
  }

  void exitRawMode() {
    if (!_isRawMode) return;
    if (_isUnix) {
      _restoreViaFfi();
    } else {
      disableRawModeIo();
    }
    _isRawMode = false;
  }

  void runWithRawMode<T>(T Function() body) {
    enterRawMode();
    try {
      return body();
    } finally {
      exitRawMode();
    }
  }

  void installSignalHandlers() {
    ProcessSignal.sigint.watch().listen((_) => exitRawMode());
    ProcessSignal.sigterm.watch().listen((_) => exitRawMode());
    ProcessSignal.sigtstp.watch().listen((_) => exitRawMode());
  }
}
```

**Dart docs references:**
- [`ProcessSignal`](https://api.dart.dev/stable/dart-io/ProcessSignal-class.html)
- [`Stream.listen`](https://api.dart.dev/stable/dart-async/Stream-class.html#listen)
- [`try`/`finally`](https://dart.dev/language/control-flow)
- [`Zone.run`](https://api.dart.dev/stable/dart-async/Zone-class.html#run)

### Testing Approach for Story 1.2

- `raw_io_test.dart`: Integration test verifying stdin state before/after
- `raw_ffi_test.dart`: Unit test with abstracted FFI calls behind an interface
- `runner_test.dart`: Test enter/exit symmetry, exception propagation, idempotency

---

## 5. Story 1.3 — Unicode Width Tables

**Estimate:** L  
**Depends on:** None (standalone data tables)

### Task 1.3.1 — 3-Stage Lookup Tables (`unicode/tables.dart`)

**Property byte encoding (5 bits):**

| Bit(s) | Field |
|--------|-------|
| 0-1 | Width: 0=zero, 1=narrow, 2=wide, 3=ambiguous |
| 2 | Emoji flag |
| 3 | Printable flag |
| 4 | Private-use flag |

**Implementation:**

```dart
// https://api.dart.dev/stable/dart-typed_data/Uint8List-class.html
import 'dart:typed_data';

const _stage1 = Uint8List(/* ~0.8KB */);
const _stage2 = Uint8List(/* ~18KB */);
const _stage3 = Uint8List(/* ~8KB */);

int _lookup(int codepoint) {
  final high = codepoint >> 8;
  final low = codepoint & 0xFF;
  final offset = _stage1[high];
  final index = _stage2[offset + low];
  return _stage3[index];
}
```

**Dart docs references:**
- [`Uint8List`](https://api.dart.dev/stable/dart-typed_data/Uint8List-class.html)
- [`const` lists](https://dart.dev/language/collections#lists)
- [`StringBuffer`](https://api.dart.dev/stable/dart-core/StringBuffer-class.html)

**Generator script (`tool/generate_unicode_tables.dart`):**
- Downloads or reads `UnicodeData.txt` and `EastAsianWidth.txt`
- Parses codepoint ranges + properties
- Builds the 3-stage table structure
- Outputs `tables.dart` content
- Run with `dart tool/generate_unicode_tables.dart > lib/src/unicode/tables.dart`

### Task 1.3.2 — Character Width Querying (`unicode/width.dart`)

```dart
// https://dart.dev/language/functions
int charWidth(int codepoint) {
  final prop = _lookup(codepoint);
  final width = prop & 0x03;
  return switch (width) {
    0 => 0,
    1 => 1,
    2 => 2,
    3 => 1, // ambiguous default
  };
}

bool isEmoji(int codepoint) => (_lookup(codepoint) & 0x04) != 0;
bool isPrintable(int codepoint) => (_lookup(codepoint) & 0x08) != 0;
bool isPrivateUse(int codepoint) => (_lookup(codepoint) & 0x10) != 0;
bool isWide(int codepoint) => charWidth(codepoint) == 2;
bool isAmbiguousWidth(int codepoint) => (_lookup(codepoint) & 0x03) == 3;

// https://api.dart.dev/stable/dart-core/String-class.html — runes
int stringWidth(String s) {
  var w = 0;
  for (final rune in s.runes) {
    w += charWidth(rune);
  }
  return w;
}
```

**Dart docs references:**
- [`String.runes`](https://api.dart.dev/stable/dart-core/String-class.html#runes)
- [`switch` expressions](https://dart.dev/language/branches#switch-expressions)

### Task 1.3.3 — Grapheme Cluster Handling (`unicode/grapheme.dart`)

```dart
// https://dart.dev/language/records — GraphemeCluster as a Record
typedef GraphemeCluster = ({int start, int end, int columnWidth});

// https://dart.dev/language/collections#lists
List<GraphemeCluster> graphemeClusters(String text) {
  final clusters = <GraphemeCluster>[];
  // UAX #29 rules: GB1-GB12/GB999
  return clusters;
}

int stringWidth(String text) {
  var w = 0;
  final clusters = graphemeClusters(text);
  for (final c in clusters) {
    w += c.columnWidth;
  }
  return w;
}

String truncate(String text, int maxWidth) {
  final clusters = graphemeClusters(text);
  var w = 0;
  var end = 0;
  for (final c in clusters) {
    if (w + c.columnWidth > maxWidth) break;
    w += c.columnWidth;
    end = c.end;
  }
  return text.substring(0, end);
}
```

**Dart docs references:**
- [Records](https://dart.dev/language/records)
- [`String.substring`](https://api.dart.dev/stable/dart-core/String-class.html#substring)
- [`Runes` iterator](https://api.dart.dev/stable/dart-core/Runes-class.html)

### Testing Approach for Story 1.3

- `tables_test.dart`: Known codepoints (U+0041=1, U+4E00=2, U+0300=0, U+200B=0)
- `width_test.dart`: charWidth edge cases, stringWidth mixed text
- `grapheme_test.dart`: Emoji ZWJ sequences (👨‍👩‍👧‍👦, 🇺🇳, #️⃣, 👍🏻)

---

## 6. Story 1.4 — Input Parser (VT500)

**Estimate:** XL  
**Depends on:** Story 1.3 (unicode width) and events.dart (defined first)

### Task 1.4.4 (implement FIRST) — Event Type Hierarchy (`parser/events.dart`)

```dart
// https://dart.dev/language/class-modifiers#sealed
sealed class Event {
  const Event();
}

// https://dart.dev/language/enums
enum KeyCode { none, tab, enter, escape, backspace, space, up, down, left, right,
  home, end, pageUp, pageDown, insert, delete,
  f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12,
  f13, f14, f15, f16, f17, f18, f19, f20, f21, f22, f23, f24, char }

// https://api.dart.dev/stable/dart-core/Set-class.html
final class KeyModifiers {
  final bool ctrl, shift, alt, meta;
  const KeyModifiers({this.ctrl = false, this.shift = false, this.alt = false, this.meta = false});
}

enum KeyEventType { down, up, repeat }

final class KeyEvent extends Event {
  final KeyCode keyCode;
  final KeyModifiers modifiers;
  final KeyEventType type;
  final int? codepoint;
  const KeyEvent({required this.keyCode, this.modifiers = const KeyModifiers(), this.type = KeyEventType.down, this.codepoint});
}

enum MouseButton { left, middle, right, none }
enum MouseAction { press, release, move, drag }

final class MouseEvent extends Event {
  final MouseButton button;
  final MouseAction action;
  final int x, y;
  const MouseEvent({required this.button, required this.action, required this.x, required this.y});
}

final class PasteEvent extends Event {
  final String content;
  const PasteEvent(this.content);
}

// Response events
final class CursorPositionEvent extends Event {
  final int row, col;
  const CursorPositionEvent(this.row, this.col);
}

final class ColorQueryEvent extends Event {
  final int colorNumber;
  final int? r, g, b;
  const ColorQueryEvent(this.colorNumber, [this.r, this.g, this.b]);
}

final class ErrorEvent extends Event {
  final String message;
  final Object? cause;
  const ErrorEvent(this.message, [this.cause]);
}

final class InternalEvent extends Event {
  final String kind;
  const InternalEvent(this.kind);
}
```

### Task 1.4.1 — VT500 State Machine Engine (`parser/engine.dart`)

**State definitions (13 states):**

```dart
// https://dart.dev/language/enums
enum VtState { ground, escape, escapeIntermediate, csiEntry, csiParam,
  csiIntermediate, csiIgnore, oscString, dcsEntry, dcsParam,
  dcsIntermediate, dcsIgnore, dcsPassthrough }

// https://dart.dev/language/class-modifiers#sealed
sealed class SequenceData {}
final class CharData extends SequenceData { final int codepoint; const CharData(this.codepoint); }
final class CsiSequenceData extends SequenceData { final List<int> params; final List<int> intermediates; final int finalByte; const CsiSequenceData(this.params, this.intermediates, this.finalByte); }
final class EscSequenceData extends SequenceData { final List<int> intermediates; final int finalByte; const EscSequenceData(this.intermediates, this.finalByte); }
final class OscSequenceData extends SequenceData { final String content; const OscSequenceData(this.content); }
final class DcsSequenceData extends SequenceData { final List<int> params; final List<int> intermediates; final int finalByte; final String? data; const DcsSequenceData(this.params, this.intermediates, this.finalByte, [this.data]); }
```

**Engine:**

```dart
class Vt500Engine {
  VtState _state = VtState.ground;
  final _params = <int>[];
  final _intermediates = <int>[];
  final _oscBuffer = StringBuffer();
  final _dcsBuffer = StringBuffer();

  SequenceData? advance(int byte) {
    // 13-state VT500 transition table
    // Uses switch (_state) with nested pattern matching on byte class
    return null;
  }

  List<SequenceData> advanceAll(List<int> bytes) {
    final results = <SequenceData>[];
    for (final byte in bytes) {
      final result = advance(byte);
      if (result != null) results.add(result);
    }
    return results;
  }

  void reset() { /* clear all state */ }
}
```

### Task 1.4.2 — CSI Semantic Parser (`parser/csi_parser.dart`)

```dart
final class CsiParser {
  Event? parse(CsiSequenceData data) {
    return switch (data.finalByte) {
      'A' => KeyEvent(keyCode: KeyCode.up, modifiers: _modifiers(data)),
      'B' => KeyEvent(keyCode: KeyCode.down, modifiers: _modifiers(data)),
      'C' => KeyEvent(keyCode: KeyCode.right, modifiers: _modifiers(data)),
      'D' => KeyEvent(keyCode: KeyCode.left, modifiers: _modifiers(data)),
      'H' => KeyEvent(keyCode: KeyCode.home, modifiers: _modifiers(data)),
      'F' => KeyEvent(keyCode: KeyCode.end, modifiers: _modifiers(data)),
      'P' => _fKey(1, data), 'Q' => _fKey(2, data),
      'R' => _fKey(3, data), 'S' => _fKey(4, data),
      'u' => _parseKittyKey(data),
      'M' when data.params.length >= 3 => _parseSgrMouse(data),
      'R' when data.params.length == 2 => CursorPositionEvent(data.params[0], data.params[1]),
      'c' when data.intermediates.contains(62) => PrimaryDeviceAttributesEvent(data.params),
      _ => null,
    };
  }
}
```

### Task 1.4.3 — ESC/OSC/DCS Semantic Parsers

```dart
final class EscParser { Event? parse(EscSequenceData data) { ... } }
final class OscParser { Event? parse(OscSequenceData data) { ... } }
final class DcsParser { Event? parse(DcsSequenceData data) { ... } }
```

### Combined Parser (`parser/parser.dart`)

```dart
class TerminalParser {
  final _engine = Vt500Engine();
  final _csiParser = CsiParser();
  final _escParser = EscParser();
  final _oscParser = OscParser();
  final _dcsParser = DcsParser();

  List<Event> advance(List<int> bytes) {
    final events = <Event>[];
    for (final seq in _engine.advanceAll(bytes)) {
      final event = _interpret(seq);
      if (event != null) events.add(event);
    }
    return events;
  }

  Event? _interpret(SequenceData seq) {
    return switch (seq) {
      CharData() => KeyEvent(keyCode: KeyCode.char, codepoint: seq.codepoint),
      CsiSequenceData() => _csiParser.parse(seq),
      EscSequenceData() => _escParser.parse(seq),
      OscSequenceData() => _oscParser.parse(seq),
      DcsSequenceData() => _dcsParser.parse(seq),
    };
  }
}
```

### Testing Approach for Story 1.4

- `engine_test.dart`: State transitions, invalid bytes, buffer accumulation
- `csi_parser_test.dart`: Known xterm sequences (arrows, F-keys, SGR mouse, CPR)
- `esc_parser_test.dart`: SS3 F-keys
- `osc_parser_test.dart`: Color query responses, title changes
- `parser_test.dart`: End-to-end byte streams → events

---

## 7. Testing Strategy

| Layer | Approach | Mocking |
|-------|----------|---------|
| ANSI codes (Story 1.1) | Pure function → expected string | None |
| Raw mode dart:io (1.2.1) | Integration: verify stdin state | None |
| Raw mode FFI (1.2.2) | Unit: abstract DynamicLibrary | Interface |
| Runner (1.2.3) | Unit: enter/exit symmetry | Mock raw mode |
| Unicode tables (1.3.1) | Unit: known codepoint properties | None |
| Width queries (1.3.2) | Unit: known widths | None |
| Grapheme clusters (1.3.3) | Unit: known emoji/cjk clusters | None |
| Engine (1.4.1) | Unit: bytes → SequenceData | None |
| Events (1.4.4) | Unit: construct + accessors | None |
| Semantic parsers (1.4.2/3) | Unit: SequenceData → Event | None |
| Combined parser (1.4) | Integration: bytes → Events | None |

```bash
# Run all tests
dart test
# Run specific test file
dart test test/ansi/codes_test.dart
```

---

## 8. Implementation Order & Dependencies

```
Task 1.1.1 — ANSI Constants (no deps)
  │
  ├──► Tasks 1.1.2–1.1.6 — Color / Text / Cursor / Erase / Term
  │
  ├──► Task 1.4.4 — Event Type Hierarchy (do FIRST for story 1.4)
  │      │
  │      └──► Task 1.4.1 — VT500 State Machine
  │             │
  │             ├──► Task 1.4.2 — CSI Parser
  │             ├──► Task 1.4.3 — ESC/OSC/DCS Parsers
  │             └──► Combined Parser (parser.dart)
  │
  ├──► Tasks 1.2.1–1.2.3 — Raw Mode & Terminal I/O (standalone)
  │
  └──► Tasks 1.3.1–1.3.3 — Unicode Width Tables (standalone)
```

**Recommended sequence:**
1. **Task 1.1.1** — simplest, foundational
2. **Tasks 1.1.2–1.1.6** — more pure functions
3. **Task 1.4.4** — events data types (needed by all parsers)
4. **Tasks 1.3.1–1.3.3** — standalone data layer
5. **Tasks 1.2.1–1.2.3** — standalone I/O layer
6. **Task 1.4.1** — VT500 engine (hardest piece)
7. **Tasks 1.4.2–1.4.3** — semantic parsers
8. **Combined parser** (parser.dart)
9. **Barrel export** (t22e.dart)

---

## 9. Official Dart Documentation References

### Core Language

| Topic | URL |
|-------|-----|
| Functions (top-level, parameters, return types) | https://dart.dev/language/functions |
| String interpolation | https://dart.dev/language/string-interpolation |
| `const` and `final` | https://dart.dev/language/variables#final-and-const |
| Enums (enhanced) | https://dart.dev/language/enums |
| Class modifiers (`sealed`, `final`, `base`) | https://dart.dev/language/class-modifiers |
| Records (lightweight data aggregates) | https://dart.dev/language/records |
| Pattern matching | https://dart.dev/language/patterns |
| Switch expressions | https://dart.dev/language/branches#switch-expressions |
| Control flow (`try`/`finally`) | https://dart.dev/language/control-flow |
| Collections (`List`, `Set`, `Map`) | https://dart.dev/language/collections |
| Generators (`sync*`, `async*`) | https://dart.dev/language/functions#generators |
| Libraries & imports | https://dart.dev/language/libraries |
| Null safety | https://dart.dev/null-safety |
| Constructors (`const` constructors) | https://dart.dev/language/classes#constant-constructors |

### Core Libraries (`dart:`)

| Library | Key Classes / Use | URL |
|---------|------------------|-----|
| `dart:core` | `String`, `StringBuffer`, `int`, `Runes` | https://api.dart.dev/stable/dart-core/dart-core-library.html |
| `dart:io` | `Stdin` (echoMode, lineMode), `stdout`, `ProcessSignal`, `Platform` | https://api.dart.dev/stable/dart-io/dart-io-library.html |
| `dart:ffi` | `DynamicLibrary`, `Struct`, `Int32`, `Uint8`, `Pointer`, `NativeFinalizer` | https://api.dart.dev/stable/dart-ffi/dart-ffi-library.html |
| `dart:typed_data` | `Uint8List` (for lookup tables) | https://api.dart.dev/stable/dart-typed_data/dart-typed-data-library.html |
| `dart:convert` | `utf8`, `base64` (for Unicode generator script) | https://api.dart.dev/stable/dart-convert/dart-convert-library.html |
| `dart:async` | `Stream`, `Zone`, `Future` | https://api.dart.dev/stable/dart-async/dart-async-library.html |

### Testing

| Package | URL |
|---------|-----|
| `package:test` (`test()`/`expect()`) | https://api.dart.dev/stable/dart-test/dart-test-library.html |
| Writing tests | https://dart.dev/guides/testing |
| `expect()` matchers | https://api.dart.dev/stable/dart-test/expect.html |

### Linting / Analysis

| Tool | URL |
|------|-----|
| `package:lints` (recommended rules) | https://dart.dev/tools/linter-rules |
| `analysis_options.yaml` | https://dart.dev/guides/language/analysis-options |

### Tooling

| Topic | URL |
|-------|-----|
| `dart run` / `dart test` | https://dart.dev/tools/dart-run |
| `dart format` | https://dart.dev/tools/dart-format |
| Creating library packages | https://dart.dev/guides/libraries/create-library-packages |
