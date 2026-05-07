# Implementation Plan: Feature 4 — Widget Library

**Phase:** 4 | **Priority:** P1 | **Scope:** 4 stories, 13 tasks
**Depends on:** Feat-2 (Rendering Core: Surface, TextStyle, Layout), Feat-3 (TEA: Model, Msg, Cmd, Program)
**Constraint:** No 3rd party dependencies — only Dart SDK (`dart:io`, `dart:async`, `dart:collection`)

---

## 1. Existing Infrastructure Summary

### Already Implemented (Feat 1–3)

| Module | Key Classes/Types | Location |
|--------|------------------|----------|
| ANSI codes | `codes.dart`, `color.dart`, `cursor.dart`, `erase.dart`, `term.dart` | `lib/src/ansi/` |
| Raw mode | `enableRawModeIo`, `disableRawModeIo`, `enableRawModeFfi` | `lib/src/terminal/` |
| Terminal runner | `TerminalRunner` | `lib/src/terminal/runner.dart` |
| Unicode | `charWidth`, `stringWidth`, `graphemeClusters`, `GraphemeCluster`, `truncate`, `isWide` | `lib/src/unicode/` |
| Parser | `Vt500Engine`, `CsiParser`, `EscParser`, `OscParser`, `DcsParser`, `TerminalParser` | `lib/src/parser/` |
| Events | `KeyEvent`, `MouseEvent`, `WindowResizeEvent`, etc. | `lib/src/parser/events.dart` |
| Surface | `Surface` (2D cell grid with `putText`, `putChar`, `fillRect`, `clearRect`, `drawBorder`) | `lib/src/core/surface.dart` |
| Cell | `Cell` (immutable: `char`, `style`, `wideContinuation`) | `lib/src/core/cell.dart` |
| TextStyle | `TextStyle` (immutable: `foreground`, `background`, `bold`, etc. with `merge()`, `inherit()`, `resolveColor()`) | `lib/src/core/style.dart` |
| Color | `Color`, `ColorKind`, `ColorProfile` (with downgrade chain) | `lib/src/core/color.dart` |
| Geometry | `Point`, `Rect`, `Insets` | `lib/src/core/geometry.dart` |
| Layout | `Constraints`, `Size`, `LayoutItem`, `splitHorizontal`, `splitVertical` | `lib/src/core/layout.dart` |
| Frame/Diff | `Frame`, `DiffResult`, `diff()` | `lib/src/renderer/frame.dart` |
| Renderers | `LineRenderer`, `SyncRenderer` | `lib/src/renderer/` |
| TEA Model | `Model<M>` (abstract: `update(Msg)`, `view()`) | `lib/src/loop/model.dart` |
| Messages | `Msg` (sealed), `KeyMsg`, `MouseMsg`, `QuitMsg`, `WindowSizeMsg`, etc. | `lib/src/loop/msg.dart` |
| Commands | `Cmd` (sealed), `TickCmd`, `EveryCmd`, `BatchCmd`, `SequenceCmd`, `ExecCmd` | `lib/src/loop/cmd.dart` |
| Event loop | `Program<M>` (TEA loop with FPS throttle, ESC disambiguation) | `lib/src/loop/program.dart` |
| Capability probe | `Capabilities`, `Da1Probe`, `ColorProbe`, `SyncProbe`, `KeyboardProbe`, `ProbePipeline` | `lib/src/capability/` |
| Lifecycle | `TerminalGuard`, `SignalHandler`, `AltScreenManager` | `lib/src/lifecycle/` |
| Well-known | `WellKnown` (magic value constants) | `lib/src/loop/well_known.dart` |

### Critical Constraints from Existing Architecture

- `Model<M>.view()` returns `dynamic` — intentionally flexible. Widget trees will be one valid return type alongside `Surface`.
- `Program._renderFrame()` currently checks `view is! Surface` and returns early. This will be extended to handle `Widget` return values.
- All rendering primitives are pure (no `dart:io` dependency in `core/` or `renderer/`). The widget library must maintain this property.

---

## 2. Architecture Overview

### Widget Tree Rendering Pipeline

```
User's Model (stateful, TEA)
  ├── update(Msg) → (Model, Cmd?)   ← state transitions
  └── view() → Widget (root tree)    ← declarative composition
    
Widget Tree (pure data, no terminal I/O)
  ├── Widget.layout(Constraints) → Size
  ├── Widget.paint(PaintingContext) → void (writes to Surface)
  │
  └── WidgetRenderer (new)
        ├── Takes root Widget + terminal dimensions
        ├── Runs layout pass (Constraints → Size)
        ├── Runs paint pass (Widget → Surface)
        └── Returns Surface for Frame/Diff pipeline
```

### Two Widget Categories

| Category | Extends | Has State | Examples | view() returns |
|----------|---------|-----------|----------|----------------|
| **Leaf/render widgets** | `Widget` (abstract) | No (stateless) | `Text`, `Box`, `Spacer`, `Row`, `Column` | N/A (these ARE widgets) |
| **Stateful/composite widgets** | `Model<M>` | Yes (own msg handling) | `Scrollable`, `TextInput`, `List`, `ProgressBar`, `Spinner`, `Table`, `Dialog` | A `Widget` tree |

Stateful widgets use leaf widgets to build their visual representation. They compose naturally — a stateful widget's `view()` returns a `Widget` tree made of leaf widgets and/or other stateful widgets' views.

### Widget → Surface Integration

The `Program` event loop will be extended to detect when `model.view()` returns a `Widget`:

```dart
// In Program._renderFrame():
final view = _model.view();
Surface surface;
if (view is Widget) {
  surface = WidgetRenderer.render(view, _termWidth, _termHeight);
} else if (view is Surface) {
  surface = view;
} else {
  return;
}
// Continue with Frame.fromSurface → diff → LineRenderer → output
```

---

## 3. Shared Enums & Types

Before implementing any widget, define shared types needed across multiple widgets.

**File:** `lib/src/widgets/enums.dart`

```dart
enum TextAlign { left, center, right }

enum MainAxisAlignment { start, center, end, spaceBetween, spaceAround }

enum CrossAxisAlignment { start, center, end, stretch }

enum Axis { horizontal, vertical }

enum EchoMode { normal, password, noEcho }

enum BorderStyle { single, double, rounded, thick }
```

**Dart documentation references:**
- https://dart.dev/language/enum — declaring enums with `enum` keyword
- https://dart.dev/language/classes#instance-variables — instance variables

---

## 4. Story 4.1 — Basic Widgets (Text, Box, Spacer)

### Task 4.1.0 — Widget Abstract Class & PaintingContext

**File:** `lib/src/widgets/widget.dart`

```dart
import '../core/geometry.dart' show Rect;
import '../core/constraints.dart' show Constraints;
import '../core/surface.dart' show Surface;
import '../core/style.dart' show TextStyle;
import '../core/layout.dart' show Size;

abstract class Widget {
  Size layout(Constraints constraints);
  void paint(PaintingContext context);
}

class PaintingContext {
  final Surface surface;
  final int offsetX;
  final int offsetY;
  final TextStyle inheritedStyle;

  const PaintingContext({
    required this.surface,
    this.offsetX = 0,
    this.offsetY = 0,
    this.inheritedStyle = TextStyle.empty,
  });

  PaintingContext child(int x, int y, {TextStyle? style}) {
    return PaintingContext(
      surface: surface,
      offsetX: offsetX + x,
      offsetY: offsetY + y,
      inheritedStyle: style ?? inheritedStyle,
    );
  }
}
```

**Design decisions:**
- `offsetX`/`offsetY` accumulate parent widget offsets. A child widget at local position (2, 3) inside a parent whose context has offset (10, 5) paints at surface coordinates (12, 8).
- `inheritedStyle` flows down the widget tree. Widgets can override it via `merge()`/`inherit()`.
- `Widget` is an abstract class — Dart's `abstract class` ensures no instantiation.
- `layout()` is a pure function: given constraints, returns size. Has no side effects.
- `paint()` renders into the surface through the context. The context provides the surface-space origin and inherited style.

**Dart documentation references:**
- https://dart.dev/language/classes#abstract-classes — abstract classes
- https://dart.dev/language/constructors — `const` constructors
- https://dart.dev/language/functions — function parameters (required named parameters with `required`)

### Task 4.1.3 — Spacer Widget

**File:** `lib/src/widgets/basic/spacer.dart`

```dart
import '../widget.dart' show Widget, PaintingContext;
import '../../core/layout.dart' show Constraints, Size;

class Spacer extends Widget {
  final int flex;
  const Spacer({this.flex = 1});

  @override
  Size layout(Constraints constraints) {
    return Size(constraints.maxWidth, constraints.maxHeight);
  }

  @override
  void paint(PaintingContext context) {
    // no-op: spacer paints nothing
  }
}
```

**Design decisions:**
- `Spacer.layout()` takes the maximum allowed space. The parent `Row`/`Column` uses the flex factor to distribute remaining space proportionally.
- `paint()` is intentionally empty. Spacer creates empty space.
- `const` constructor enables widget reuse and compile-time constant trees.

**Dart documentation references:**
- https://dart.dev/language/constructors — `const` constructors
- https://api.dart.dev/stable/dart-core/Comparable/compareTo.html — default values for named parameters

### Task 4.1.1 — Text Widget

**File:** `lib/src/widgets/basic/text.dart`

```dart
import '../widget.dart' show Widget, PaintingContext;
import '../enums.dart' show TextAlign;
import '../../core/layout.dart' show Constraints, Size;
import '../../core/style.dart' show TextStyle;
import '../../unicode/width.dart' show stringWidth;
import '../../unicode/grapheme.dart' show graphemeClusters, GraphemeCluster, truncate;

class Text extends Widget {
  final String text;
  final TextStyle style;
  final TextAlign align;
  final bool wordWrap;

  const Text(
    this.text, {
    this.style = TextStyle.empty,
    this.align = TextAlign.left,
    this.wordWrap = false,
  });

  @override
  Size layout(Constraints constraints) {
    if (text.isEmpty) return Size(0, 1);
    if (wordWrap) {
      return _layoutWrapped(constraints.maxWidth);
    }
    final textWidth = stringWidth(text);
    final width = textWidth.clamp(constraints.minWidth, constraints.maxWidth);
    return Size(width, constraints.minHeight.clamp(1, constraints.maxHeight));
  }

  Size _layoutWrapped(int maxWidth) {
    final lines = _wrapText(text, maxWidth);
    final maxLineWidth = lines.fold(0, (int max, String l) => max > stringWidth(l) ? max : stringWidth(l));
    return Size(maxLineWidth, lines.length);
  }

  List<String> _wrapText(String txt, int maxWidth) {
    // Word-wrap: split on grapheme cluster boundaries
    // Break at word boundaries (spaces) when possible
    // Each line must not exceed maxWidth columns
    // Uses graphemeClusters() for CJK/emoji-aware width
  }

  @override
  void paint(PaintingContext context) {
    if (text.isEmpty) return;
    final resolvedStyle = context.inheritedStyle.merge(style);
    final rect = Rect(context.offsetX, context.offsetY, ...);
    // Determine available width from constraints (stored from layout)
    // Apply alignment: left → x=0, center → x=(availWidth-textWidth)/2, right → x=availWidth-textWidth
    // For wordWrap: iterate wrapped lines, paint each line with offset
    // Use surface.putText() with resolvedStyle
  }
}
```

**Design decisions:**
- `Text` is a positional-first parameter widget (the text string is the primary data).
- `align` is a widget property, not a `TextStyle` property — alignment is a layout concern, not a visual style concern.
- Word-wrapping uses `graphemeClusters()` for correct CJK/emoji width measurement.
- Overflow: text is clipped at the right edge of the allocated area (Surface handles clipping).
- `layout()` stores the computed size for use in `paint()`. This avoids recomputation.

**Dart documentation references:**
- https://dart.dev/language/constructors — constructors with positional + named parameters
- https://dart.dev/language/functions — function parameters
- https://api.dart.dev/stable/dart-core/String-class.html — Dart String class
- https://dart.dev/language/collections — List operations (`fold`, `map`)
- https://api.dart.dev/stable/dart-core/num/clamp.html — clamping integers

### Task 4.1.2 — Box Widget

**File:** `lib/src/widgets/basic/box.dart`

```dart
import '../widget.dart' show Widget, PaintingContext;
import '../enums.dart' show BorderStyle;
import '../../core/geometry.dart' show Insets, Rect;
import '../../core/layout.dart' show Constraints, Size;
import '../../core/style.dart' show TextStyle;
import '../../core/surface.dart' show Surface;

class Box extends Widget {
  final Widget? child;
  final BorderStyle borderStyle;
  final Insets padding;
  final String? title;
  final TextStyle? titleStyle;
  final EdgeInsets? margin;
  final TextStyle? borderTextStyle;

  const Box({
    this.child,
    this.borderStyle = BorderStyle.single,
    this.padding = EdgeInsets.zero,
    this.title,
    this.titleStyle,
    this.borderTextStyle,
    this.margin,
  });

  int get _borderWidth => borderStyle != BorderStyle.none ? 1 : 0;
  int get _horizontalBorder => _borderWidth * 2;
  int get _verticalBorder => _borderWidth * 2;

  @override
  Size layout(Constraints constraints) {
    var w = 0;
    var h = 0;
    if (child != null) {
      // Subtract border + padding from available space
      final availW = (constraints.maxWidth - _horizontalBorder - padding.horizontal)
          .clamp(constraints.minWidth, constraints.maxWidth);
      final availH = (constraints.maxHeight - _verticalBorder - padding.vertical)
          .clamp(constraints.minHeight, constraints.maxHeight);
      final childConstraints = Constraints(
        minWidth: constraints.minWidth,
        maxWidth: availW,
        minHeight: constraints.minHeight,
        maxHeight: availH,
      );
      final childSize = child!.layout(childConstraints);
      w = childSize.width + _horizontalBorder + padding.horizontal;
      h = childSize.height + _verticalBorder + padding.vertical;
    } else {
      w = constraints.minWidth;
      h = constraints.minHeight;
    }
    return Size(
      w.clamp(constraints.minWidth, constraints.maxWidth),
      h.clamp(constraints.minHeight, constraints.maxHeight),
    );
  }

  @override
  void paint(PaintingContext context) {
    final x = context.offsetX;
    final y = context.offsetY;
    // Draw border using Surface.drawBorder() or direct putText calls
    // Border chars by style: single (┌┐└┘│─), double (╔╗╚╝║═), rounded (╭╮╰╯│─), thick (┏┓┗┛┃━)
    // Draw title centered/left-aligned in top border
    // Fill background (if any)
    // Paint child in content area (inset by border + padding)
    if (child != null) {
      final childContext = context.child(
        _borderWidth + padding.left,
        _borderWidth + padding.top,
      );
      child!.paint(childContext);
    }
  }
}
```

**Border style to character mapping:**

| Style | TL | TR | BL | BR | H | V |
|-------|----|----|----|----|----|----|
| single | ┌ | ┐ | └ | ┘ | ─ | │ |
| double | ╔ | ╗ | ╚ | ╝ | ═ | ║ |
| rounded | ╭ | ╮ | ╰ | ╯ | ─ | │ |
| thick | ┏ | ┓ | ┗ | ┛ | ━ | ┃ |

Uses `Surface.drawBorder()` with a constructed `borderChars` string based on the selected style.

**Dart documentation references:**
- https://dart.dev/language/enum — `BorderStyle` enum
- https://dart.dev/language/classes#instance-variables — instance variables with initializers
- https://dart.dev/language/constructors — `const` constructors with named parameters
- https://api.dart.dev/stable/dart-core/String-class.html — string indexing and manipulation

---

## 5. Story 4.2 — Container Widgets (Row, Column)

### Task 4.2.1 — Row Widget

**File:** `lib/src/widgets/container/row.dart`

```dart
import '../widget.dart' show Widget, PaintingContext;
import '../enums.dart' show MainAxisAlignment, CrossAxisAlignment;
import '../../core/layout.dart' show Constraints, Size, LayoutItem, splitHorizontal;

class Row extends Widget {
  final List<Widget> children;
  final int gap;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const Row({
    required this.children,
    this.gap = 0,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Size layout(Constraints constraints) {
    _childSizes = [];
    _childPositions = [];

    // Step 1: Measure each child to determine fixed vs flexible
    final items = <LayoutItem>[];
    final measured = <Size>[];

    for (final child in children) {
      // Give child unbounded height (cross axis) to measure intrinsic size
      final childSize = child.layout(
        Constraints(
          maxWidth: constraints.maxWidth,
          maxHeight: constraints.maxHeight,
        ),
      );
      measured.add(childSize);
      items.add(LayoutItem(fixedSize: childSize.width, flex: 1));
    }

    // Step 2: Distribute horizontal space using splitHorizontal
    final widths = splitHorizontal(constraints.maxWidth, items, gap);

    // Step 3: Give each child its tight width constraint, re-layout
    var xOffset = _computeMainAxisOffset(widths, constraints.maxWidth);
    for (var i = 0; i < children.length; i++) {
      final tightW = widths[i];
      final childConstraints = Constraints.tight(tightW, constraints.maxHeight);
      final finalSize = children[i].layout(childConstraints);
      _childSizes!.add(finalSize);
      _childPositions!.add(xOffset);
      xOffset += tightW + gap;
    }

    // Step 4: Return total size
    final totalWidth = widths.fold(0, (a, b) => a + b) + gap * (children.length - 1);
    final maxHeight = _childSizes!.fold(0, (int a, Size s) => a > s.height ? a : s.height);
    return Size(totalWidth, maxHeight.clamp(constraints.minHeight, constraints.maxHeight));
  }

  int _computeMainAxisOffset(List<int> widths, int parentWidth) {
    final total = widths.fold(0, (a, b) => a + b) + gap * (children.length - 1);
    return switch (mainAxisAlignment) {
      MainAxisAlignment.start => 0,
      MainAxisAlignment.center => (parentWidth - total) ~/ 2,
      MainAxisAlignment.end => parentWidth - total,
      MainAxisAlignment.spaceBetween => 0, // handled via gaps
      MainAxisAlignment.spaceAround => 0,  // handled via gaps
    };
  }

  @override
  void paint(PaintingContext context) {
    for (var i = 0; i < children.length; i++) {
      final x = _childPositions![i];
      final size = _childSizes![i];
      // Apply crossAxisAlignment offset
      final y = _computeCrossAxisOffset(size.height, context, ...);
      children[i].paint(context.child(x, y));
    }
  }

  int _computeCrossAxisOffset(int childHeight, PaintingContext context, int parentHeight) {
    return switch (crossAxisAlignment) {
      CrossAxisAlignment.start => 0,
      CrossAxisAlignment.center => (parentHeight - childHeight) ~/ 2,
      CrossAxisAlignment.end => parentHeight - childHeight,
      CrossAxisAlignment.stretch => 0, // handled via layout
    };
  }
}
```

**Design decisions:**
- Layout state (`_childSizes`, `_childPositions`) is stored as mutable instance variables between `layout()` and `paint()` calls. This is the same pattern Flutter uses with `RenderObject`.
- Each child is laid out twice: first to measure intrinsic size, then again with tight constraints. This matches Flutter's layout protocol.
- `mainAxisAlignment` controls spacing along the main (horizontal) axis.
- `crossAxisAlignment` controls alignment along the cross (vertical) axis.
- `spaceBetween` and `spaceAround` require additional gap computation beyond `splitHorizontal`.
- `stretch` expands the child to fill the parent's cross-axis size by passing tight cross-axis constraints.

**Dart documentation references:**
- https://dart.dev/language/classes — instance variables
- https://dart.dev/language/control-flow — `for` loops, `switch` expressions
- https://dart.dev/language/functions — closures (`fold`, etc.)
- https://dart.dev/language/collections — `List<T>`
- https://dart.dev/language/patterns — switch expressions with exhaustiveness checking

### Task 4.2.2 — Column Widget

**File:** `lib/src/widgets/container/column.dart`

Mirror of Row, operating on the vertical axis:
- Uses `splitVertical` instead of `splitHorizontal`
- `mainAxisAlignment` operates on the vertical axis
- `crossAxisAlignment` operates on the horizontal axis
- Same `_computeMainAxisOffset` and `_computeCrossAxisOffset` logic, transposed.

**DRY principle:** Extract shared layout logic into a mixin or static helper to avoid duplication between Row and Column.

```dart
// Shared layout helper (in layout.dart or a new file):
typedef _AxisDelegate = ({List<int> Function(int, List<LayoutItem>, int) split, });

class FlexLayout {
  static List<int> computeMainAxisOffset(
    int totalUsed, int parentSize, MainAxisAlignment alignment, int gap,
  ) {
    return // ... the offset logic
  }
}
```

**Dart documentation references:**
- https://dart.dev/language/extension-methods — potential extension for reuse
- https://dart.dev/language/mixins — mixin for shared layout logic

---

## 6. Story 4.3 — Interactive Widgets (Scrollable, TextInput, List)

All interactive widgets are `Model<M>` subclasses. Their `view()` returns a `Widget` tree composed of basic widgets (Text, Box, Row, Column).

**Important:** To create custom `Msg` types for interactive widgets (e.g., `CursorBlinkMsg`, `TextChangedMsg`, `ListSelectedMsg`), define them in each widget's file. Extend the `Msg` sealed class:

```dart
// In text_input.dart:
final class CursorBlinkMsg extends Msg {
  const CursorBlinkMsg();
}
```

### Task 4.3.1 — Scrollable Viewport

**File:** `lib/src/widgets/interactive/scrollable.dart`

```dart
class Scrollable extends Model<Scrollable> {
  int scrollX;
  int scrollY;
  final Widget child;
  final Axis axis;
  final int scrollStep;
  final int viewportWidth;
  final int viewportHeight;

  Scrollable({
    this.scrollX = 0,
    this.scrollY = 0,
    required this.child,
    this.axis = Axis.vertical,
    this.scrollStep = 3,
    this.viewportWidth = 80,
    this.viewportHeight = 24,
  });

  @override
  (Scrollable, Cmd?) update(Msg msg) {
    return switch (msg) {
      KeyMsg(:final event) => _handleKey(event),
      _ => (this, null),
    };
  }

  (Scrollable, Cmd?) _handleKey(KeyEvent event) {
    return switch (event.keyCode) {
      KeyCode.up => (copyWith(scrollY: (scrollY - 1).clamp(0, _maxScrollY)), null),
      KeyCode.down => (copyWith(scrollY: (scrollY + 1).clamp(0, _maxScrollY)), null),
      KeyCode.pageUp => (copyWith(scrollY: (scrollY - viewportHeight).clamp(0, _maxScrollY)), null),
      KeyCode.pageDown => (copyWith(scrollY: (scrollY + viewportHeight).clamp(0, _maxScrollY)), null),
      KeyCode.home => (copyWith(scrollY: 0), null),
      KeyCode.end => (copyWith(scrollY: _maxScrollY), null),
      _ => (this, null),
    };
  }

  int get _maxScrollY => (_childHeight - viewportHeight).clamp(0, 0x7FFFFFFF);

  @override
  Widget view() {
    // 1. Create a clipped rendering of the child at negative scroll offset
    // 2. Show scrollbar indicator on right edge
    // 3. Return composed widget tree (Box + child clip)
    return _ScrollView(
      child: child,
      scrollX: scrollX,
      scrollY: scrollY,
      viewportWidth: viewportWidth,
      viewportHeight: viewportHeight,
      contentHeight: _childHeight,
    );
  }
}
```

The `_ScrollView` is a private `Widget` subclass that:
- Creates a `PaintingContext` with the viewport rect
- Paints the child at offset `(-scrollX, -scrollY)` relative to the viewport origin
- Draws a scrollbar indicator on the right edge

**Scrollbar rendering:**
- Track: thin vertical strip (1 cell wide) on right edge
- Thumb: position proportional to `scrollY / maxScrollY`, height proportional to `viewportHeight / contentHeight`
- Uses box-drawing characters `█` or `░` for the thumb

**Dart documentation references:**
- https://dart.dev/language/classes — copyWith pattern for immutable state
- https://dart.dev/language/constructors — named constructors
- https://api.dart.dev/stable/dart-core/num/clamp.html — clamping scroll offsets
- https://dart.dev/language/class-modifiers#sealed — sealed Msg classes

### Task 4.3.2 — TextInput Widget

**File:** `lib/src/widgets/interactive/text_input.dart`

```dart
class TextInput extends Model<TextInput> {
  final String value;
  final int cursorPosition;
  final int? selectionStart;
  final int maxLength;
  final EchoMode echoMode;
  final String? Function(String)? validator;
  final bool _cursorVisible;

  const TextInput({
    this.value = '',
    this.cursorPosition = 0,
    this.selectionStart,
    this.maxLength = -1,
    this.echoMode = EchoMode.normal,
    this.validator,
    this._cursorVisible = true,
  });

  @override
  (TextInput, Cmd?) update(Msg msg) {
    return switch (msg) {
      KeyMsg(:final event) => _handleKey(event),
      CursorBlinkMsg() => (copyWith(_cursorVisible: !_cursorVisible),
          tick(blinkInterval, (_) => const CursorBlinkMsg())),
      _ => (this, null),
    };
  }

  (TextInput, Cmd?) _handleKey(KeyEvent event) {
    return switch (event.keyCode) {
      KeyCode.enter => (this, null),
      KeyCode.backspace when cursorPosition > 0 =>
        (_deleteBefore(), null),
      KeyCode.delete when cursorPosition < value.length =>
        (_deleteAfter(), null),
      KeyCode.left when cursorPosition > 0 =>
        (copyWith(cursorPosition: cursorPosition - 1), null),
      KeyCode.right when cursorPosition < value.length =>
        (copyWith(cursorPosition: cursorPosition + 1), null),
      KeyCode.home => (copyWith(cursorPosition: 0), null),
      KeyCode.end => (copyWith(cursorPosition: value.length), null),
      _ when _isPrintable(event) => _insertChar(event),
      _ => (this, null),
    };
  }

  bool _isPrintable(KeyEvent event) {
    return event.keyCode == KeyCode.char && event.char != null;
  }

  // Character insertion, grapheme-cluster-aware deletion
  // Password masking via echoMode
  // Validator callback on value change

  @override
  Widget view() {
    final displayText = _displayValue;
    final text = Text(
      displayText,
      style: TextStyle(...)
    );
    // Render cursor: either block cursor (reverse video) at cursorPosition
    // or underline cursor with blinking
    // For selection: render selected region with highlight background

    return Row(children: [
      text,
      _renderCursor(),
      // ... scrollable wrapper for overflow
    ]);
  }
}
```

**Design decisions:**
- `TextInput` is immutable — `copyWith()` produces new state on each update.
- Cursor blink uses `tick()` Cmd with configurable interval (~500ms).
- Grapheme-cluster-aware cursor movement: use `graphemeClusters()` to move by visual character, not by code unit.
- Password mode: replace each character with `*` in `_displayValue`.
- Selection: `selectionStart` + `cursorPosition` define the range. Highlighted via reverse text style.
- Validator: called on value change. Error state rendered as styled text.

**Key message for cursor blink:**
```dart
final class CursorBlinkMsg extends Msg {
  const CursorBlinkMsg();
}
```

**Dart documentation references:**
- https://dart.dev/language/class-modifiers#sealed — sealed class for Msg subclasses
- https://api.dart.dev/stable/dart-core/String-class.html — string operations (substring, interpolation)
- https://dart.dev/language/functions — closures for validator callback
- https://api.dart.dev/stable/dart-async/Timer-class.html — timer-based cursor blink via Cmd

### Task 4.3.3 — List Widget

**File:** `lib/src/widgets/interactive/list.dart`

```dart
class List extends Model<List> {
  final List<Item> items;
  final int selectedIndex;
  final Set<int> multiSelected;
  final bool multiSelect;
  final int viewportHeight;

  const List({
    this.items = const [],
    this.selectedIndex = 0,
    this.multiSelected = const {},
    this.multiSelect = false,
    this.viewportHeight = 10,
  });

  @override
  (List, Cmd?) update(Msg msg) {
    return switch (msg) {
      KeyMsg(:final event) => _handleKey(event),
      _ => (this, null),
    };
  }

  (List, Cmd?) _handleKey(KeyEvent event) {
    return switch (event.keyCode) {
      KeyCode.up when selectedIndex > 0 =>
        (copyWith(selectedIndex: selectedIndex - 1), null),
      KeyCode.down when selectedIndex < items.length - 1 =>
        (copyWith(selectedIndex: selectedIndex + 1), null),
      KeyCode.space when multiSelect =>
        _toggleMultiSelect(selectedIndex),
      KeyCode.enter => _confirm(),
      _ => (this, null),
    };
  }

  @override
  Widget view() {
    final visibleItems = _visibleRange.map((i) {
      final isSelected = i == selectedIndex;
      final isMulti = multiSelected.contains(i);
      return _buildItemRow(items[i], isSelected, isMulti);
    }).toList();

    return Box(
      borderStyle: BorderStyle.single,
      child: Column(children: visibleItems),
    );
  }

  Widget _buildItemRow(Item item, bool isSelected, bool isMultiSelected) {
    final style = isSelected
        ? const TextStyle(reverse: true)
        : TextStyle.empty;
    final prefix = isMultiSelected ? '[✓] ' : '[ ] ';
    return Text('$prefix${item.label}', style: style);
  }
}
```

**Design decisions:**
- Single-select: `selectedIndex` tracks current selection. Up/Down moves it.
- Multi-select: Space toggles current item. `multiSelected` is a `Set<int>`.
- View renders visible items only (capped by `viewportHeight`), with scroll offset to keep selection visible.
- Selected item uses reverse video (`TextStyle(reverse: true)`).
- Filtering (optional): prefix-match on typed characters reduces `items` to a filtered subset.
- For long lists: wraps in `Scrollable` to support scrolling.

**Dart documentation references:**
- https://dart.dev/language/collections — `List`, `Set`, list slicing (`sublist`)
- https://dart.dev/language/control-flow — `for` loops for item iteration
- https://dart.dev/language/classes — immutable data classes with `copyWith`

---

## 7. Story 4.4 — Visual & Composite Widgets (Progress, Spinner, Table, Dialog)

### Task 4.4.1 — ProgressBar Widget

**File:** `lib/src/widgets/visual/progress.dart`

```dart
class ProgressBar extends Model<ProgressBar> {
  final double? fraction; // null = indeterminate, 0.0–1.0 = determinate
  final String? label;
  final int width;
  final String fillChar;
  final String emptyChar;
  final TextStyle? fillStyle;
  final TextStyle? emptyStyle;
  final int _indeterminateOffset;

  const ProgressBar({
    this.fraction,
    this.label,
    this.width = 20,
    this.fillChar = '█',
    this.emptyChar = '░',
    this.fillStyle,
    this.emptyStyle,
    this._indeterminateOffset = 0,
  });

  @override
  (ProgressBar, Cmd?) update(Msg msg) {
    return switch (msg) {
      TickMsg() when fraction == null =>
        (copyWith(_indeterminateOffset: _indeterminateOffset + 1),
         tick(indeterminateInterval, (_) => const TickMsg())),
      _ => (this, null),
    };
  }

  @override
  Widget view() {
    final filled = fraction != null
        ? (width * fraction!).round()
        : _indeterminateOffset % width;
    // Build bar: filled chars + empty chars
    final bar = StringBuffer();
    for (var i = 0; i < width; i++) {
      bar.write(i < filled ? fillChar : emptyChar);
    }
    final pct = fraction != null ? ' ${(fraction! * 100).round()}%' : '';
    return Row(children: [
      if (label != null) Text('$label '),
      Text(bar.toString()),
      Text(pct),
    ]);
  }
}
```

**Design decisions:**
- Determinate mode: `fraction` 0.0–1.0. Filled portion = `(width * fraction).round()`.
- Indeterminate mode: `fraction == null`. A moving pulse/sweep animation via `TickMsg`.
- `indeterminateOffset` cycles through the bar width, creating a moving highlight.
- Composes from `Text` widgets in a `Row` — stateless rendering.
- TickMsg is returned from `update()` to continue the animation loop.

**Dart documentation references:**
- https://api.dart.dev/stable/dart-math/double-class.html — double arithmetic
- https://dart.dev/language/control-flow — `for` loops
- https://dart.dev/language/classes — copyWith for immutable state

### Task 4.4.2 — Spinner Widget

**File:** `lib/src/widgets/visual/spinner.dart`

```dart
class Spinner extends Model<Spinner> {
  final int _frame;
  final List<String> frames;
  final Duration interval;
  final String? label;

  static const List<String> defaultFrames = [
    '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏',
  ];

  const Spinner({
    this._frame = 0,
    this.frames = defaultFrames,
    this.interval = Duration(milliseconds: 80),
    this.label,
  });

  @override
  (Spinner, Cmd?) update(Msg msg) {
    return switch (msg) {
      TickMsg() => (copyWith(_frame: (_frame + 1) % frames.length),
          tick(interval, (_) => const TickMsg())),
      _ => (this, null),
    };
  }

  @override
  Widget view() {
    final spinnerText = frames[_frame];
    return Row(children: [
      Text(spinnerText),
      if (label != null) Text(' $label'),
    ]);
  }
}
```

**Design decisions:**
- Frame advancement via `TickMsg` from event loop.
- Default frame set: braille dots spinner (10 frames, 80ms each).
- `frames` is user-configurable. Presets can be provided as static constants.
- Automatically starts animation by returning `TickMsg` from `update()`.

**Dart documentation references:**
- https://api.dart.dev/stable/dart-async/Duration-class.html — Duration constants
- https://dart.dev/language/classes — static const members
- https://dart.dev/language/control-flow — modulo operator for frame cycling

### Task 4.4.3 — Table Widget

**File:** `lib/src/widgets/visual/table.dart`

```dart
class Table extends Model<Table> {
  final List<String> columns;
  final List<List<Widget>> rows; // or List<List<String>> for simpler data
  final int? sortColumn;
  final bool sortAscending;
  final List<int> columnWidths;

  const Table({
    this.columns = const [],
    this.rows = const [],
    this.sortColumn,
    this.sortAscending = true,
    this.columnWidths = const [],
  });

  @override
  (Table, Cmd?) update(Msg msg) {
    return switch (msg) {
      MouseMsg(:final event) => _handleHeaderClick(event),
      _ => (this, null),
    };
  }

  (Table, Cmd?) _handleHeaderClick(MouseEvent event) { /* toggle sort */ }

  @override
  Widget view() {
    final widths = _computeColumnWidths();
    final headerWidgets = columns.asMap().entries.map((e) {
      final sortIndicator = e.key == sortColumn
          ? (sortAscending ? ' ▲' : ' ▼')
          : '';
      return Text('${e.value}$sortIndicator');
    }).toList();

    final headerRow = Row(children: headerWidgets);

    final dataRows = rows.map((row) {
      return Row(children: row.asMap().entries.map((e) {
        return Text(row[e.key].toString());
      }).toList());
    }).toList();

    return Column(children: [
      headerRow,
      ...dataRows,
    ]);
  }

  List<int> _computeColumnWidths() {
    // Auto-size columns:
    // 1. For each column, measure header width + max content width
    // 2. Apply explicit columnWidths if provided
    // 3. Clamp to available space
  }
}
```

**Design decisions:**
- Column widths auto-size to content (max of header width and cell content widths).
- Sort indicator: `▲` (ascending) or `▼` (descending) next to sorted column header.
- Alternating row colors: even/odd index → different background style.
- Horizontal scrolling: wrap in `Scrollable` if total table width exceeds viewport.
- Column separator: optional `│` between columns.
- Empty state: centered "No data" text if rows are empty.

**Dart documentation references:**
- https://dart.dev/language/collections — `List` operations (`map`, `fold`, `asMap`)
- https://dart.dev/language/control-flow — `for` loops, spread (`...`)
- https://dart.dev/language/classes — immutable data classes

### Task 4.4.4 — Dialog/Overlay Widget

**File:** `lib/src/widgets/visual/dialog.dart`

```dart
class Dialog extends Model<Dialog> {
  final String title;
  final Widget content;
  final List<DialogButton> buttons;
  final bool dismissible;
  final int focusedButton;

  const Dialog({
    this.title = '',
    required this.content,
    this.buttons = const [],
    this.dismissible = true,
    this.focusedButton = 0,
  });

  @override
  (Dialog, Cmd?) update(Msg msg) {
    return switch (msg) {
      KeyMsg(:final event) => _handleKey(event),
      _ => (this, null),
    };
  }

  (Dialog, Cmd?) _handleKey(KeyEvent event) {
    return switch (event.keyCode) {
      KeyCode.escape when dismissible => (this, some(CloseDialogMsg())),
      KeyCode.tab => (copyWith(
          focusedButton: (focusedButton + 1) % buttons.length
        ), null),
      KeyCode.enter => _activateButton(focusedButton),
      _ => (this, null),
    };
  }

  @override
  Widget view() {
    // 1. Backdrop: fill entire screen with dimmed background
    // 2. Dialog box: centered horizontally, ~1/3 from top
    //    → Box with border, title, content area, button bar
    // 3. Button bar: Row of buttons, focused button highlighted
    return _DialogOverlay(
      backdrop: true,
      child: Box(
        borderStyle: BorderStyle.double,
        title: title,
        child: Column(children: [
          content,
          _buildButtonBar(),
        ]),
      ),
    );
  }
}
```

**Design decisions:**
- `_DialogOverlay` is a private `Widget` that paints a backdrop (clears surface with dimmed styling) and then paints the dialog box on top.
- Backdrop: `Surface.clearRect()` + fill with dim/transparent style for the entire screen area outside the dialog.
- Dialog positioned at center horizontally, 1/3 from top vertically.
- Button bar: `Row` of `DialogButton` widgets. Focused button gets highlighted style (reverse or colored).
- Enter activates focused button, Escape dismisses (if `dismissible`).
- `CloseDialogMsg` is a custom Msg that signals the parent model to remove the dialog.

**Dart documentation references:**
- https://dart.dev/language/class-modifiers#sealed — sealed Msg for dialog events
- https://dart.dev/language/control-flow — switch expressions for key handling
- https://dart.dev/language/collections — list indexing

---

## 8. Widget Renderer (Widget → Surface)

**File:** `lib/src/widgets/renderer.dart`

```dart
import '../core/surface.dart' show Surface;
import '../core/layout.dart' show Constraints;
import 'widget.dart' show Widget, PaintingContext;

class WidgetRenderer {
  static Surface render(Widget root, int width, int height) {
    final surface = Surface(width, height);
    final constraints = Constraints.tight(width, height);
    root.layout(constraints);
    final context = PaintingContext(surface: surface);
    root.paint(context);
    return surface;
  }
}
```

### Integration with Program

In `lib/src/loop/program.dart`, modify `_renderFrame()`:

```dart
void _renderFrame() {
  final view = _model.view();
  late final Surface surface;

  if (view is Widget) {
    final width = 80; // or _termWidth from latest WindowSizeMsg
    final height = 24; // or _termHeight
    surface = WidgetRenderer.render(view, width, height);
  } else if (view is Surface) {
    surface = view;
  } else {
    return;
  }

  final currentFrame = Frame.fromSurface(surface);
  // ... rest unchanged
}
```

**Dart documentation references:**
- https://dart.dev/language/type-system — type checking (`is`)
- https://dart.dev/language/classes — static methods

---

## 9. Complete File & Directory Structure

```
lib/
├── t22e.dart                              # UPDATE: add widget exports
├── src/
│   ├── widgets/                           # NEW — Widget Library
│   │   ├── enums.dart                     # TextAlign, MainAxisAlignment, etc.
│   │   ├── widget.dart                    # Widget (abstract) + PaintingContext
│   │   ├── renderer.dart                  # WidgetRenderer
│   │   ├── basic/
│   │   │   ├── text.dart                  # Text widget
│   │   │   ├── box.dart                   # Box widget
│   │   │   └── spacer.dart                # Spacer widget
│   │   ├── container/
│   │   │   ├── row.dart                   # Row widget
│   │   │   └── column.dart                # Column widget
│   │   ├── interactive/
│   │   │   ├── scrollable.dart            # Scrollable model
│   │   │   ├── text_input.dart            # TextInput model
│   │   │   └── list.dart                  # List model
│   │   └── visual/
│   │       ├── progress.dart              # ProgressBar model
│   │       ├── spinner.dart               # Spinner model
│   │       ├── table.dart                 # Table model
│   │       └── dialog.dart                # Dialog model
│   └── ... (existing files unchanged)

test/
├── all_test.dart                          # UPDATE: add widget tests
└── widgets/                               # NEW
    ├── basic/
    │   ├── text_test.dart
    │   ├── box_test.dart
    │   └── spacer_test.dart
    ├── container/
    │   ├── row_test.dart
    │   └── column_test.dart
    ├── interactive/
    │   ├── scrollable_test.dart
    │   ├── text_input_test.dart
    │   └── list_test.dart
    ├── visual/
    │   ├── progress_test.dart
    │   ├── spinner_test.dart
    │   ├── table_test.dart
    │   └── dialog_test.dart
    └── renderer_test.dart
```

---

## 10. Implementation Order

| Step | Task | File | Depends On | Story |
|------|------|------|-----------|-------|
| 1 | `PaintContext`, `Widget` abstract class | `widget.dart` | `core/geometry.dart`, `core/surface.dart`, `core/layout.dart` | 4.1 |
| 2 | `TextAlign`, `MainAxisAlignment`, `CrossAxisAlignment`, `Axis`, `EchoMode`, `BorderStyle` enums | `enums.dart` | Nothing | 4.1 |
| 3 | `Spacer` widget | `basic/spacer.dart` | Steps 1–2 | 4.1 |
| 4 | `Text` widget | `basic/text.dart` | Steps 1–2, unicode | 4.1 |
| 5 | `Box` widget | `basic/box.dart` | Steps 1–2, 4 | 4.1 |
| 6 | `Row` widget | `container/row.dart` | Steps 1–2, 4, `splitHorizontal` | 4.2 |
| 7 | `Column` widget | `container/column.dart` | Steps 1–2, 4, `splitVertical` | 4.2 |
| 8 | `WidgetRenderer` | `renderer.dart` | Steps 1, `core/surface.dart` | — |
| 9 | Update `Program._renderFrame()` | `loop/program.dart` | Step 8 | — |
| 10 | `ProgressBar` model | `visual/progress.dart` | Steps 1–2, 4, 6–7 | 4.4 |
| 11 | `Spinner` model | `visual/spinner.dart` | Steps 1–2, 4, 6–7 | 4.4 |
| 12 | `Scrollable` model | `interactive/scrollable.dart` | Steps 1–2, 4–7 | 4.3 |
| 13 | `List` model | `interactive/list.dart` | Steps 1–2, 4–7, 12 | 4.3 |
| 14 | `TextInput` model | `interactive/text_input.dart` | Steps 1–2, 4–7, 12 | 4.3 |
| 15 | `Table` model | `visual/table.dart` | Steps 1–2, 4, 6–7 | 4.4 |
| 16 | `Dialog` model | `visual/dialog.dart` | Steps 1–2, 4–7 | 4.4 |
| 17 | Barrel export update | `t22e.dart` | All tasks | — |
| 18 | Test manifest update | `test/all_test.dart` | All tasks | — |

### Rationale for Order

1. **Foundation first** (steps 1–3): Widget abstract class, PaintingContext, and enums are prerequisites for everything.
2. **Basic widgets** (steps 3–5): Spacer → Text → Box. Simplest first, building complexity.
3. **Container widgets** (steps 6–7): Row → Column. Depend on basic widgets for their children.
4. **Renderer integration** (steps 8–9): WidgetRenderer + Program update enables end-to-end rendering of widget trees.
5. **Simple visual models** (steps 10–11): ProgressBar → Spinner. Simple state, easy to test.
6. **Complex interactive models** (steps 12–14): Scrollable → List → TextInput. Increasing state complexity.
7. **Composite models** (steps 15–16): Table → Dialog. Build on all the above.

---

## 11. Testing Strategy

### Testing Principles

- Every widget has a corresponding test file in `test/widgets/`.
- Widgets are unit-testable without terminal I/O.
- `WidgetRenderer` converts a widget tree → `Surface`, which can be inspected via `Surface.grid`, `toPlainLines()`, `toAnsiLines()`.
- Model widgets are tested by sending Msgs and asserting state changes + returned Cmd.

### Test Categories

| Category | What to Test |
|----------|-------------|
| **Widget.layout()** | Returns correct size given constraints. Edge cases: empty text, zero constraints, max constraints. |
| **Widget.paint()** | Correctly modifies Surface cells. Verify via `surface.grid[y][x].char` and `surface.grid[y][x].style`. |
| **Widget composition** | Row/Column properly positions children. Box accounts for border + padding. |
| **Stateful widgets** | `update(Msg)` produces correct new state. Cursor movement, text insertion/deletion, selection, navigation. |
| **WidgetRenderer** | End-to-end: widget tree → Surface with correct dimensions and content. |
| **Edge cases** | Empty children, single child, overflow, zero-size constraints, wide characters, emoji sequences, negative scroll. |

### Per-Task Test Matrix

| Task | Tests |
|------|-------|
| **Widget** | Abstract class cannot be instantiated. PaintingContext creates child contexts with accumulated offset. `inheritedStyle` flows correctly. |
| **Spacer** | `layout()` returns max constraints. `paint()` is no-op (surface unchanged). |
| **Text** | Layout: empty text, short text, long text, word wrap boundaries. Paint: alignment (left/center/right), style application, CJK/emoji width, overflow clipping, grapheme clusters. |
| **Box** | Each border style renders correct chars. Title appears in top border. Padding correctly insets child. Layout accounts for border (2 cells) + padding + child. Background fill. |
| **Row** | Fixed + flexible children. Gap spacing. MainAxisAlignment (start/center/end). CrossAxisAlignment (start/center/end/stretch). Empty children. Single child. Overflow handling. |
| **Column** | Same as Row but vertical axis. |
| **ProgressBar** | Determinate: correct fill ratio. Indeterminate: offset advances on TickMsg. |
| **Spinner** | Frame advances modulo frames.length. Default frames correct. Label display. |
| **Scrollable** | Arrow keys scroll by 1. PageUp/PageDown by viewport size. Clamping at bounds. Scrollbar position/height. Home/End. |
| **List** | Up/Down navigation. Space toggles multi-select. Enter fires confirm. Selected item highlighted. Scroll follows selection. Filtering. |
| **TextInput** | Character insertion at cursor. Backspace/delete (grapheme cluster aware). Home/End. Arrow navigation. Selection with Shift+arrows. Password masking. Cursor blink toggle. Validator callback. Max length. |
| **Table** | Column auto-width. Sort indicator. Header row + data rows. Alternating colors. Empty state. |
| **Dialog** | Backdrop clears. Dialog box centered. Title in border. Button bar with focus cycling. Enter activates, Escape dismisses. Tab/Shift+Tab cycles focus. |
| **WidgetRenderer** | Widget → Surface conversion. Correct dimensions. Content fidelity. |

**Dart documentation references:**
- https://dart.dev/guides/testing — official Dart testing guide
- https://api.dart.dev/stable/dart-test/dart-test-library.html — `package:test` API
- https://dart.dev/guides/language/analysis-options — analysis options for linting

---

## 12. Dart Official Documentation References

### Language Fundamentals

| Topic | URL | Usage in Feat-4 |
|-------|-----|------------------|
| Abstract classes | https://dart.dev/language/classes#abstract-classes | `Widget` abstract class |
| Constructors | https://dart.dev/language/constructors | `const` constructors for all widget classes |
| Sealed classes | https://dart.dev/language/class-modifiers#sealed | `final class CursorBlinkMsg extends Msg` |
| Enums | https://dart.dev/language/enum | `TextAlign`, `MainAxisAlignment`, `BorderStyle`, etc. |
| Generics | https://dart.dev/language/generics | `Model<M>` for stateful widgets |
| Records | https://dart.dev/language/records | Return type `(M, Cmd?)` from `update()` |
| Extensions | https://dart.dev/language/extension-methods | Potential helper extensions on Widget |
| Mixins | https://dart.dev/language/mixins | Shared layout logic between Row/Column |
| Type system | https://dart.dev/language/type-system | `is` checks, `dynamic` return from `view()` |

### Control Flow & Patterns

| Topic | URL | Usage in Feat-4 |
|-------|-----|------------------|
| Switch expressions | https://dart.dev/language/branches#switch-expressions | Exhaustive Msg handling in `update()` |
| Patterns | https://dart.dev/language/patterns | Destructuring `KeyMsg(:final event)` |
| Control flow | https://dart.dev/language/control-flow | `for` loops for children, collections |
| Functions | https://dart.dev/language/functions | Closures for callbacks, `fold`, `map` |

### Core Libraries (dart:core)

| Topic | URL | Usage in Feat-4 |
|-------|-----|------------------|
| Object equality | https://api.dart.dev/stable/dart-core/Object/operator_equals.html | Widget equality for diff optimization |
| Object.hashCode | https://api.dart.dev/stable/dart-core/Object/hashCode.html | Consistent hashing |
| Object.hash() | https://api.dart.dev/stable/dart-core/Object/hash.html | `Object.hash(field1, field2, ...)` |
| StringBuffer | https://api.dart.dev/stable/dart-core/StringBuffer-class.html | Efficient string building in Box/Text painting |
| String class | https://api.dart.dev/stable/dart-core/String-class.html | `isEmpty`, `runes`, `substring`, `split` |
| Iterable | https://api.dart.dev/stable/dart-core/Iterable-class.html | `fold`, `map`, `where`, `toList` |
| List | https://dart.dev/language/collections | Children lists, grid rows |
| Set | https://dart.dev/language/collections | `Set<int>` for multi-select |
| num.clamp | https://api.dart.dev/stable/dart-math/num/clamp.html | Clamping scroll, cursor, sizes |
| Comparable | https://api.dart.dev/stable/dart-core/Comparable-class.html | Sorting in Table |

### Async (dart:async)

| Topic | URL | Usage in Feat-4 |
|-------|-----|------------------|
| Timer | https://api.dart.dev/stable/dart-async/Timer-class.html | Cursor blink, spinner animation |
| Future | https://api.dart.dev/stable/dart-async/Future-class.html | `Future.delayed` for TickCmd |
| Duration | https://api.dart.dev/stable/dart-async/Duration-class.html | Animation intervals |

### Testing

| Topic | URL | Usage in Feat-4 |
|-------|-----|------------------|
| Testing guide | https://dart.dev/guides/testing | Test structure, assertions |
| Test library | https://api.dart.dev/stable/dart-test/dart-test-library.html | `group`, `test`, `expect`, matchers |

### Tooling

| Topic | URL | Usage in Feat-4 |
|-------|-----|------------------|
| Analysis options | https://dart.dev/guides/language/analysis-options | Lint rules for code quality |
| Lints package | https://dart.dev/tools/linter-rules | Recommended lint rules |

---

## 13. Guiding Principles

| Principle | Application |
|-----------|-------------|
| **Single Responsibility** | Each file owns one widget type. `widget.dart` owns only the abstract class + context. `enums.dart` owns only shared types. |
| **DRY** | Row and Column share layout logic via a static helper. Border-style-to-char mapping is in one place. Alignment computations are extracted. |
| **Pure functions** | `Widget.layout()` is pure (constraints → size). `Widget.paint()` has side effects only on the provided Surface. `Model.update()` is pure (msg → new state + optional cmd). |
| **Testability** | Zero `dart:io` dependency in widgets. All rendering tested via Surface inspection. All state transitions tested via update() assertions. |
| **Immutability** | All widget configuration objects (`TextStyle`, `Cell`, `Point`, `Rect`, `Insets`) are immutable with `const` constructors. Model state uses `copyWith` pattern. |
| **Composition over inheritance** | Stateful widgets compose stateless widgets for rendering. Row/Column compose children. Box wraps a child. No deep widget inheritance hierarchy. |
| **Zero 3rd-party dependencies** | Only `dart:core`, `dart:async`, `dart:io` (in Program only), `dart:collection`, `dart:math`. The `path` package in pubspec.yaml is a Dart SDK package, not third-party. |

---

## 14. Barrel Export Update

**File:** `lib/t22e.dart`

Add the following exports:

```dart
// Widget Library
export 'src/widgets/enums.dart';
export 'src/widgets/widget.dart';
export 'src/widgets/renderer.dart';
export 'src/widgets/basic/text.dart';
export 'src/widgets/basic/box.dart';
export 'src/widgets/basic/spacer.dart';
export 'src/widgets/container/row.dart';
export 'src/widgets/container/column.dart';
export 'src/widgets/interactive/scrollable.dart';
export 'src/widgets/interactive/text_input.dart';
export 'src/widgets/interactive/list.dart';
export 'src/widgets/visual/progress.dart';
export 'src/widgets/visual/spinner.dart';
export 'src/widgets/visual/table.dart';
export 'src/widgets/visual/dialog.dart';
```

---

## 15. Test Manifest Update

**File:** `test/all_test.dart`

Add imports and main() calls for all widget test files.
