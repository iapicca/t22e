# Feature 2: Rendering Core — Implementation Plan

## Context Summary

**Existing (Phase 1 — already implemented):**
- `lib/src/ansi/` — ANSI escape code functions (codes, color, cursor, erase, term)
- `lib/src/unicode/` — 3-stage lookup tables, width queries, grapheme cluster handling
- `lib/src/terminal/` — Raw mode (dart:io & FFI), terminal lifecycle runner
- `lib/src/parser/` — VT500 state machine engine, semantic parsers (CSI, ESC, OSC, DCS), event types

**To build (Phase 2 — this feature):**
- `lib/src/core/` — Cell, Surface, TextStyle, Color, Layout, Constraints, Rect, Point, Insets
- `lib/src/renderer/` — Frame, DiffResult, LineRenderer, SyncRenderer

**Constraints:** No 3rd party dependencies. Only Dart SDK and `dart:io`.

---

## Architecture Overview

The rendering core follows a **pure pipeline** (no side effects):

```
Widget Tree (declarative, to come in Phase 4)
  → Surface (2D cell grid, mutable buffer)
    → toPlainLines() + toStyledLines()
      → Frame (previous + current)
        → Diff (line comparison)
          → LineRenderer (ANSI output generation)
            → SyncRenderer (optional wrapper)
```

Each stage is a pure transformation: input → output, fully testable without terminal I/O.

---

## Story 2.1: 2D Cell Grid (Surface)

**Depends on:** Story 1.3 (unicode width tables, grapheme clusters)

### Task 2.1.1 — Cell Class Definition

**File:** `lib/src/core/cell.dart`

```dart
class Cell {
  final String char;           // grapheme cluster
  final TextStyle style;       // active SGR attributes
  final bool wideContinuation; // true if second half of wide char

  const Cell({
    this.char = ' ',
    this.style = TextStyle.empty,
    this.wideContinuation = false,
  });

  Cell copyWith({String? char, TextStyle? style, bool? wideContinuation});
}
```

**Key design decisions:**
- Immutable class (all `final` fields) — ensures thread-safe snapshots for diff
- Default cell: `' '` space with empty style, not a continuation
- `copyWith()` for efficient frame snapshotting — Dart's `copyWith` pattern
- `==` and `hashCode` override based on all three fields — required for diff comparison

### Task 2.1.2 — Surface Class with Grid Operations

**File:** `lib/src/core/surface.dart`

```dart
class Surface {
  final int width;
  final int height;
  List<List<Cell>> grid;

  Surface(this.width, this.height);
  Surface.fromGrid(this.grid) : width = grid[0].length, height = grid.length;

  void putText(int x, int y, String text, TextStyle style);
  void putChar(int x, int y, String char, TextStyle style);
  void fillRect(int x, int y, int w, int h, String char, TextStyle style);
  void clearRect(int x, int y, int w, int h);
  void drawBorder(Rect rect, {String? borderChars, TextStyle? style, String? title});
  List<String> toAnsiLines();
  List<String> toPlainLines();
}
```

**Key design decisions:**
- Row-major storage: `grid[y][x]` — matches terminal coordinate convention (row, column)
- Zero-indexed: `(0,0)` = top-left
- `putText()` iterates over `graphemeClusters()`; for each cluster, calls `stringWidth()` to determine column span; marks continuation cells via `wideContinuation = true`
- All operations clip to `[0, width)` × `[0, height)` using `Rect.intersect()`
- Wide character handling: when `charWidth(rune) == 2`, next cell is `wideContinuation = true` and `char = ''`
- `toAnsiLines()`: for each row, iterate cells left-to-right, emit ANSI reset + SGR codes only when style changes
- `toPlainLines()`: join `cell.char` for each row
- `resize(int newWidth, int newHeight)`: creates new grid, copies overlapping region

### Task 2.1.3 — Geometry Types (Rect, Point, Insets)

**File:** `lib/src/core/geometry.dart`

```dart
class Point {
  final int x, y;
  const Point(this.x, this.y);
  Point operator +(Point other) => Point(x + other.x, y + other.y);
  Point operator -(Point other) => Point(x - other.x, y - other.y);
}

class Rect {
  final int x, y, width, height;
  const Rect(this.x, this.y, this.width, this.height);

  int get left => x;
  int get top => y;
  int get right => x + width;
  int get bottom => y + height;

  bool contains(Point p);
  Rect intersect(Rect other);
  Rect union(Rect other);
  Rect inset(Insets i);
  Rect inflate(int dx, int dy);
}

class Insets {
  final int left, top, right, bottom;
  const Insets(this.left, this.top, this.right, this.bottom);
  const Insets.all(int value);
  const Insets.symmetric({int horizontal = 0, int vertical = 0});
  const Insets.only({int left = 0, int top = 0, int right = 0, int bottom = 0});
}
```

**Key design decisions:**
- All classes are immutable with `const` constructors
- No negative width/height in Rect — clamp to 0
- `contains()`: half-open interval `[left, right)` × `[top, bottom)`
- `intersect()`: returns `Rect.zero` if no overlap
- `==` and `hashCode` for all types

---

## Story 2.2: TextStyle & Color Resolution

**Depends on:** Story 1.1 (ANSI color sequences)

### Task 2.2.2 — Color Model with Downgrade Chain

**File:** `lib/src/core/color.dart`

```dart
enum ColorKind { noColor, ansi, indexed, rgb }
enum ColorProfile { noColor, ansi16, indexed256, trueColor }

class Color {
  final ColorKind kind;
  final int value;

  const Color.noColor() : kind = ColorKind.noColor, value = 0;
  const Color.ansi(int color) : kind = ColorKind.ansi, value = color;
  const Color.indexed(int index) : kind = ColorKind.indexed, value = index;
  const Color.rgb(int r, int g, int b)
      : kind = ColorKind.rgb, value = (r << 16) | (g << 8) | b;

  Color convert(ColorKind target);
  String sgrSequence({bool background = false});
  ColorProfile get profile;
}
```

**Key design decisions:**
- `convert()` NEVER upgrades: if current kind is lower fidelity than target, returns `this`
- `convert()` rgb → indexed: 6×6×6 cube + grayscale ramp, nearest by redmean distance
- `convert()` indexed → ansi: fixed palette mapping
- `sgrSequence()` produces correct ANSI for each kind
- `==` and `hashCode` based on `kind` + `value`

### Task 2.2.1 — TextStyle Definition

**File:** `lib/src/core/style.dart`

```dart
class TextStyle {
  final Color? foreground;
  final Color? background;
  final bool bold;
  final bool dim;
  final bool italic;
  final bool underline;
  final bool blink;
  final bool reverse;
  final bool strikethrough;
  final bool overline;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Border? border;
  final int? width;
  final int? height;
  final TextAlign? align;
  final bool? wordWrap;

  const TextStyle({...});
  static const empty = TextStyle();
  TextStyle merge(TextStyle other);
  TextStyle resolveColor(ColorProfile profile);
}
```

**Key design decisions:**
- All fields nullable except booleans — `null` means "no change / inherit"
- `TextStyle.empty` static const
- `merge()`: non-null fields in other override this
- `resolveColor()`: returns new TextStyle with downgraded colors
- `==` and `hashCode` on all fields

### Task 2.2.3 — Style Inheritance

**File:** `lib/src/core/style.dart`

```dart
extension TextStyleInherit on TextStyle {
  TextStyle inherit(TextStyle parent) {
    return TextStyle(
      foreground: foreground ?? parent.foreground,
      background: background ?? parent.background,
      bold: bold ?? parent.bold,
      italic: italic ?? parent.italic,
      // ... etc for all fields
    );
  }
}
```

**Key design decisions:**
- Uses Dart's `extension` feature
- Null-propagating via `??` operator
- Deep nesting works: `child.inherit(parent).inherit(grandparent)`
- `TextStyle.empty.inherit(parent)` → parent; `child.inherit(TextStyle.empty)` → child

---

## Story 2.3: Layout Algorithm

**Depends on:** Task 2.1.3 (geometry types)

### Task 2.3.3 — Constraints and Measuring

**File:** `lib/src/core/layout.dart`

```dart
class Constraints {
  final int minWidth;
  final int maxWidth;
  final int minHeight;
  final int maxHeight;

  const Constraints({
    this.minWidth = 0,
    this.maxWidth = 0x7FFFFFFF,
    this.minHeight = 0,
    this.maxHeight = 0x7FFFFFFF,
  });

  const Constraints.tight(int width, int height);
  bool get isTight => minWidth == maxWidth && minHeight == maxHeight;
  bool get isUnbounded => maxWidth == 0x7FFFFFFF || maxHeight == 0x7FFFFFFF;
  Size constrain(Size size);
}

class Size {
  final int width;
  final int height;
  const Size(this.width, this.height);
}
```

### Tasks 2.3.1 & 2.3.2 — SplitHorizontal and SplitVertical

**File:** `lib/src/core/layout.dart`

```dart
class LayoutItem {
  final int? fixedSize;
  final int flex;
  const LayoutItem({this.fixedSize, this.flex = 1});
}

List<int> _splitSpace(int total, List<LayoutItem> items, int gap);
List<int> splitHorizontal(int total, List<LayoutItem> items, int gap);
List<int> splitVertical(int total, List<LayoutItem> items, int gap);
```

**Algorithm:**
1. Sum fixed sizes, sum gaps
2. `remaining = total - sumFixed - sumGaps`
3. Sum flex factors, distribute remaining proportionally
4. Floor sizes, distribute remainder pixels to handle rounding
5. If remaining < 0, flexible items get minimum 1

**Key design decisions:**
- Single `_splitSpace` function shared between horizontal/vertical — DRY
- Edge cases: all-fixed, all-flexible, single item, zero remaining

---

## Story 2.4: Diff Engine & Output

**Depends on:** Story 2.1 (Surface), Story 2.2 (TextStyle)

### Task 2.4.1 — Frame Comparison (Line-Level Diff)

**File:** `lib/src/renderer/frame.dart`

```dart
class Frame {
  final List<String> plainLines;
  final List<String> styledLines;
  Frame(this.plainLines, this.styledLines);
  factory Frame.fromSurface(Surface surface);
  int get height => plainLines.length;
}

class DiffResult {
  final List<int> changedRows;
  const DiffResult(this.changedRows);
}

DiffResult diff(Frame previous, Frame current);
```

**Algorithm:** Compare each row index up to max height of both frames; if plain OR styled differs, mark as changed. Handle frames of different heights.

### Task 2.4.2 — Line-Level Renderer

**File:** `lib/src/renderer/line_renderer.dart`

```dart
class LineRenderer {
  String render(DiffResult diff, Frame currentFrame) {
    final buf = StringBuffer();
    for (final row in diff.changedRows) {
      if (row < currentFrame.height) {
        buf.write('\x1b[${row + 1};0H');
        buf.write(currentFrame.styledLines[row]);
      }
    }
    return buf.toString();
  }
}
```

### Task 2.4.3 — Synchronized Update Support

**File:** `lib/src/renderer/sync_renderer.dart`

```dart
class SyncRenderer {
  final bool syncSupported;
  final LineRenderer _lineRenderer = LineRenderer();
  const SyncRenderer({this.syncSupported = false});

  String render(DiffResult diff, Frame currentFrame);
}
```

---

## File & Directory Structure

```
lib/
├── t22e.dart                    # UPDATE: add new exports
├── src/
│   ├── core/                    # NEW
│   │   ├── cell.dart
│   │   ├── surface.dart
│   │   ├── geometry.dart
│   │   ├── color.dart
│   │   ├── style.dart
│   │   └── layout.dart
│   └── renderer/                # NEW
│       ├── frame.dart
│       ├── line_renderer.dart
│       └── sync_renderer.dart

test/
├── all_test.dart                # UPDATE: import core + renderer tests
├── core/                        # NEW
│   ├── cell_test.dart
│   ├── surface_test.dart
│   ├── geometry_test.dart
│   ├── color_test.dart
│   ├── style_test.dart
│   └── layout_test.dart
└── renderer/                    # NEW
    ├── frame_test.dart
    ├── line_renderer_test.dart
    └── sync_renderer_test.dart
```

---

## Implementation Order

| Step | Task | Depends On | Reason |
|------|------|-----------|--------|
| 1 | 2.1.3 Geometry types | None | Needed by all other stories |
| 2 | 2.2.2 Color model | ansi/color.dart | Needed by TextStyle |
| 3 | 2.1.1 Cell class | TextStyle, but can start with placeholder | Minimal dep |
| 4 | 2.2.1 TextStyle | Color (2.2.2) | Color field |
| 5 | 2.2.3 Style inheritance | TextStyle (2.2.1) | Extension on TextStyle |
| 6 | 2.1.2 Surface | Cell, Geometry, grapheme/width | Text placement needs all |
| 7 | 2.3.3 Constraints | None | Standalone |
| 8 | 2.3.1 SplitHorizontal | Constraints (2.3.3) | Uses Constraints |
| 9 | 2.3.2 SplitVertical | SplitHorizontal (2.3.1) | Shares algorithm |
| 10 | 2.4.1 Frame/Diff | Surface (2.1.2) | Needs toAnsiLines/toPlainLines |
| 11 | 2.4.2 LineRenderer | Frame (2.4.1) | Renders diff results |
| 12 | 2.4.3 SyncRenderer | LineRenderer (2.4.2) | Wraps render output |

**Practical build order:** 2.1.3 → 2.2.2 → 2.1.1 → 2.2.1 → 2.2.3 → 2.1.2 → 2.3.3 → 2.3.1 → 2.3.2 → 2.4.1 → 2.4.2 → 2.4.3

---

## Testing Strategy

| Task | Tests |
|------|-------|
| 2.1.1 Cell | Default cell, custom cell, copyWith, equality, hashCode |
| 2.1.2 Surface | putText with ASCII/CJK/emoji, wide char marking, fillRect, clearRect, drawBorder, clipping, toAnsiLines, toPlainLines, resize |
| 2.1.3 Geometry | Point +/-, Rect contains/intersect/union/inset/inflate, Insets constructors, equality, negative clamp |
| 2.2.1 TextStyle | merge, empty singleton, equality, attribute combinations, resolveColor |
| 2.2.2 Color | All named constructors, each downgrade path, no upgrade, sgrSequence output |
| 2.2.3 Inheritance | Null filling, child overrides, deep nesting, empty parent/child |
| 2.3.1/2 Layout | All-fixed, all-flexible, mixed, flex factors, gaps, zero remaining, single item |
| 2.3.3 Constraints | Tight, loose, unbounded, constrain clamping |
| 2.4.1 Frame/Diff | Content change, style-only change, resize, no change |
| 2.4.2 LineRenderer | Single change, multiple changes, full frame, empty frame |
| 2.4.3 SyncRenderer | With sync, without sync, empty content |

---

## Key Design Principles

1. **Single Responsibility:** Each class has one job
2. **DRY:** `_splitSpace` shared between horizontal/vertical; Color logic centralized
3. **Pure functions:** All core rendering code is stateless
4. **Testability:** No `dart:io` dependency in core/renderer
5. **Zero 3rd-party dependencies:** Only Dart SDK

---

## Dart Official Documentation References

| Topic | URL |
|-------|-----|
| Classes & constructors | https://dart.dev/language/constructors |
| Collections (Lists) | https://dart.dev/language/collections |
| Enums | https://dart.dev/language/enum |
| Extension methods | https://dart.dev/language/extension-methods |
| Equality operators | https://dart.dev/language/operators |
| Records | https://dart.dev/language/records |
| StringBuffer | https://api.dart.dev/stable/dart-core/StringBuffer-class.html |
| Object.== | https://api.dart.dev/stable/dart-core/Object/operator_equals.html |
| Object.hashCode | https://api.dart.dev/stable/dart-core/Object/hashCode.html |
| num.clamp | https://api.dart.dev/stable/dart-math/num/clamp.html |
| sqrt (dart:math) | https://api.dart.dev/stable/dart-math/sqrt.html |
| RangeError | https://api.dart.dev/stable/dart-core/RangeError-class.html |
| Testing guide | https://dart.dev/guides/testing |
| Analysis options | https://dart.dev/guides/language/analysis-options |
