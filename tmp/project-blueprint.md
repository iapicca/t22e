# t22e — Project Blueprint

> Complete inventory of every class, function, variable, and Riverpod provider
> across all packages, reorganized into **Framework** and **Engine**.
>
> Repo: [github.com/iapicca/t22e](https://github.com/iapicca/t22e) · Branch: `no_ffi`

---

## Table of Contents

- [Framework](#framework)
  - [widgets](#widgets) — core + widgets packages
  - [logic](#logic) — notifier + lifecycle packages
- [Engine](#engine)
  - [protocol](#protocol) — ansi + protocol + unicode packages
  - [renderer](#renderer) — capability + terminal + renderer + parser packages

---

# Framework

---

## widgets

> Merges the old **core** and **widgets** packages into a single section covering
> geometry, color, cells, layout, the MVU runtime, and all concrete widgets.

### Geometry

#### `Point` — [core/geometry.dart#L8](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/geometry.dart#L8)

**What:** A 2D coordinate on the terminal grid (column = `x`, row = `y`).
**How:** A [freezed](https://pub.dev/packages/freezed) immutable value class. Supports component-wise `+` and `-` operators for vector arithmetic.

| Member | Line | Description |
|--------|------|-------------|
| `factory Point(int x, int y)` | [L11](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/geometry.dart#L11) | Primary constructor |
| `int x` | — | Column coordinate (freezed property) |
| `int y` | — | Row coordinate (freezed property) |
| `operator +(Point other)` | [L14](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/geometry.dart#L14) | Component-wise addition |
| `operator -(Point other)` | [L17](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/geometry.dart#L17) | Component-wise subtraction |

#### `Rect` — [core/geometry.dart#L22](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/geometry.dart#L22)

**What:** An axis-aligned rectangle on the terminal grid.
**How:** A freezed value class with origin (`x`, `y`) and dimensions (`width`, `height`). Provides edge getters, containment, intersection, union, inset, and inflate operations.

| Member | Line | Description |
|--------|------|-------------|
| `factory Rect(int x, int y, int width, int height)` | [L27](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/geometry.dart#L27) | Primary constructor |
| `factory Rect.fromLTWH(int left, int top, int w, int h)` | [L29](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/geometry.dart#L29) | Named constructor from edges |
| `int get left` | [L33](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/geometry.dart#L33) | Left edge column |
| `int get top` | [L36](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/geometry.dart#L36) | Top edge row |
| `int get right` | [L39](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/geometry.dart#L39) | Right edge (exclusive) |
| `int get bottom` | [L42](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/geometry.dart#L42) | Bottom edge (exclusive) |
| `bool get isEmpty` | [L45](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/geometry.dart#L45) | True if either dimension is zero |
| `bool contains(Point p)` | [L48](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/geometry.dart#L48) | Point-in-rect test |
| `Rect intersect(Rect other)` | [L52](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/geometry.dart#L52) | Overlapping region |
| `Rect union(Rect other)` | [L62](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/geometry.dart#L62) | Bounding rect of both |
| `Rect inset(Insets insets)` | [L71](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/geometry.dart#L71) | Shrink by insets |
| `Rect inflate(int dx, int dy)` | [L81](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/geometry.dart#L81) | Expand by delta |

#### `Insets` — [core/geometry.dart#L92](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/geometry.dart#L92)

**What:** Per-edge offsets (padding/margins) for layout.
**How:** A freezed value class with `left`, `top`, `right`, `bottom`. Factory constructors for uniform, symmetric, and per-side insets.

| Member | Line | Description |
|--------|------|-------------|
| `factory Insets(int left, int top, int right, int bottom)` | [L95](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/geometry.dart#L95) | Primary constructor |
| `factory Insets.all(int value)` | [L98](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/geometry.dart#L98) | Same value on all sides |
| `factory Insets.symmetric({int horizontal, int vertical})` | [L101](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/geometry.dart#L101) | Symmetric horizontal/vertical |
| `factory Insets.only({int left, int top, int right, int bottom})` | [L105](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/geometry.dart#L105) | Individual sides |
| `factory Insets.fromLTRB(int l, int t, int r, int b)` | [L113](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/geometry.dart#L113) | From left/top/right/bottom |
| `int get horizontal` | [L116](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/geometry.dart#L116) | left + right |
| `int get vertical` | [L119](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/geometry.dart#L119) | top + bottom |
| `Insets add(Insets other)` | [L122](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/geometry.dart#L122) | Component-wise addition |

---

### Layout

#### `Constraints` — [core/layout.dart#L8](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/layout.dart#L8)

**What:** Min/max bounds for widget layout (analogous to Flutter's `BoxConstraints`).
**How:** A freezed value class. `maxWidth`/`maxHeight` default to an unbounded sentinel. Provides `isTight`, `isUnbounded`, `constrain(Size)`, and `multiply(factor)`.

| Member | Line | Description |
|--------|------|-------------|
| `factory Constraints({int minWidth, int maxWidth, int minHeight, int maxHeight})` | [L11](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/layout.dart#L11) | Primary constructor |
| `factory Constraints.tight(int width, int height)` | [L18](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/layout.dart#L18) | min == max for both axes |
| `bool get isTight` | [L28](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/layout.dart#L28) | Both axes tight |
| `bool get isUnbounded` | [L31](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/layout.dart#L31) | Either axis unbounded |
| `Size constrain(Size size)` | [L35](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/layout.dart#L35) | Clamp size to constraints |
| `Constraints multiply(double factor)` | [L43](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/layout.dart#L43) | Scale all bounds |

#### `Size` — [core/layout.dart#L55](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/layout.dart#L55)

**What:** A width x height pair.
**How:** A freezed value class. `isEmpty` checks for zero dimensions. `constrain` clamps to `Constraints`. `multiply` scales both axes.

| Member | Line | Description |
|--------|------|-------------|
| `factory Size(int width, int height)` | [L58](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/layout.dart#L58) | Primary constructor |
| `bool get isEmpty` | [L61](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/layout.dart#L61) | Either dimension zero |
| `Size constrain(Constraints constraints)` | [L64](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/layout.dart#L64) | Clamp to constraints |
| `Size multiply(double factor)` | [L72](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/layout.dart#L72) | Scale both dimensions |

#### `LayoutItem` — [core/layout.dart#L79](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/layout.dart#L79)

**What:** A flex item descriptor for space distribution in `Row`/`Column`.
**How:** A freezed value class. `fixedSize` is null for flexible items; `flex` is the proportional weight (default 1).

| Member | Line | Description |
|--------|------|-------------|
| `factory LayoutItem({int? fixedSize, int flex})` | [L82](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/layout.dart#L82) | Primary constructor |
| `bool get isFlexible` | [L86](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/layout.dart#L86) | True if `fixedSize` is null |

#### `splitHorizontal` — [core/layout.dart#L145](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/layout.dart#L145)

**What:** Distributes available horizontal space among `LayoutItem`s using flexbox rules.
**How:** Delegates to the private `_splitSpace` function ([L91](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/layout.dart#L91)) which gives fixed items their size, then distributes remaining space proportionally by flex factor, with remainder allocated round-robin.

#### `splitVertical` — [core/layout.dart#L149](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/layout.dart#L149)

**What:** Same as `splitHorizontal` but for vertical space distribution.
**How:** Identical delegation to `_splitSpace`.

---

### Color

#### `ColorProfile` — [core/color_profile.dart#L2](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color_profile.dart#L2)

**What:** Terminal color capability level.
**How:** An enum with four levels: `noColor`, `ansi16`, `indexed256`, `trueColor`. Used by `TextStyle.resolveColor` and `ColorSgr.sgrSequence` to downgrade colors to match terminal support.

#### `ColorConstants` — [core/color_constants.dart#L3](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color_constants.dart#L3)

**What:** Static integer constants for color profile metadata and palette math.
**How:** Non-instantiable final class. Constants include indexed palette offsets, ANSI thresholds, link color RGB, and `rgbComponentMax`.

| Member | Line | Value | Description |
|--------|------|-------|-------------|
| `colorProfileIndexedCount` | [L7](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color_constants.dart#L7) | 256 | Total palette entries |
| `indexedColorCubeStart` | [L10](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color_constants.dart#L10) | 16 | 6x6x6 cube start |
| `indexedColorCubeSize` | [L13](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color_constants.dart#L13) | 6 | Cube dimension |
| `indexedColorGrayStart` | [L16](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color_constants.dart#L16) | 232 | Grayscale ramp start |
| `indexedColorGrayCount` | [L19](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color_constants.dart#L19) | 24 | Grayscale entries |
| `ansiBrightOffset` | [L22](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color_constants.dart#L22) | 60 | Standard-to-bright SGR offset |
| `ansiColorMax` | [L25](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color_constants.dart#L25) | 15 | Max ANSI index |
| `ansiDarkThreshold` | [L28](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color_constants.dart#L28) | 8 | Dark ANSI threshold |
| `linkColorRed` | [L31](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color_constants.dart#L31) | 0 | Link color R |
| `linkColorGreen` | [L34](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color_constants.dart#L34) | 102 | Link color G |
| `linkColorBlue` | [L37](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color_constants.dart#L37) | 204 | Link color B |
| `rgbComponentMax` | [L40](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color_constants.dart#L40) | 255 | Max RGB component |

#### `AnsiColor` — [core/color.dart#L9](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color.dart#L9)

**What:** A validated ANSI 16-color code (0-15).
**How:** A Dart [extension type](https://dart.dev/language/extension-types) wrapping `int`. The constructor asserts the range at creation time.

| Member | Line | Description |
|--------|------|-------------|
| `AnsiColor(int code)` | [L10](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color.dart#L10) | Constructor with 0-15 assertion |
| `int get code` | [L18](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color.dart#L18) | The validated color code |

#### `IndexedColor` — [core/color.dart#L22](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color.dart#L22)

**What:** A validated 256-color palette index (0-255).
**How:** Extension type wrapping `int` with range assertion.

| Member | Line | Description |
|--------|------|-------------|
| `IndexedColor(int index)` | [L23](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color.dart#L23) | Constructor with 0-255 assertion |
| `int get index` | [L31](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color.dart#L31) | The validated palette index |

#### `Color` — [core/color.dart#L35](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color.dart#L35)

**What:** A terminal color stored as an exact RGB tuple.
**How:** Extension type wrapping `(int, int, int)`. Provides 16 named constructors for standard/bright ANSI colors and component getters.

| Member | Line | Description |
|--------|------|-------------|
| `Color({int red, int green, int blue})` | [L36](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color.dart#L36) | RGB constructor with 0-255 assertions |
| `Color.black()` ... `Color.brightWhite()` | [L53-L68](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color.dart#L53) | 16 named ANSI color constructors |
| `int get red` | [L71](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color.dart#L71) | Red component |
| `int get green` | [L74](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color.dart#L74) | Green component |
| `int get blue` | [L77](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color.dart#L77) | Blue component |

#### `AnsiToColor` (extension on `AnsiColor`) — [core/color.dart#L83](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color.dart#L83)

**What:** Converts an ANSI 16-color code to its RGB `Color` equivalent.
**How:** Looks up the code in a private `_ansiToRgb` map ([L143](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color.dart#L143)).

#### `IndexedToColor` (extension on `IndexedColor`) — [core/color.dart#L88](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color.dart#L88)

**What:** Converts a 256-color palette index to its RGB `Color`.
**How:** Delegates to `_indexToRgb` ([L163](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color.dart#L163)) which handles the 16 ANSI base colors, the 6x6x6 cube, and the 24-step grayscale ramp.

#### `ColorIndex` (extension on `Color`) — [core/color.dart#L96](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color.dart#L96)

**What:** Finds the nearest 256-color palette index for an RGB color.
**How:** Delegates to `_rgbToIndexed` ([L182](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color.dart#L182)) which uses a [red-mean](https://en.wikipedia.org/wiki/Color_difference#sRGB) perceptual distance formula over the cube and grayscale ramp.

#### `ColorAnsi` (extension on `Color`) — [core/color.dart#L101](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color.dart#L101)

**What:** Converts an RGB color to its nearest ANSI 16-color equivalent.
**How:** Delegates to `_indexedToAnsi` ([L218](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color.dart#L218)) using a fixed mapping array and brightness threshold.

#### `ColorSgr` (extension on `Color`) — [core/color.dart#L106](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color.dart#L106)

**What:** Generates [SGR](https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_(Select_Graphic_Rendition)_parameters) escape sequences for this color.
**How:** `sgrSequence({bool background, ColorProfile profile})` emits the appropriate CSI sequence based on the profile: no output for `noColor`, ANSI 16-color codes for `ansi16`, 256-color indexed for `indexed256`, or 24-bit RGB for `trueColor`.

#### Private color helpers

| Name | Line | Description |
|------|------|-------------|
| `_ansiToRgb` | [L143](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color.dart#L143) | Map of 16 ANSI codes to `Color` |
| `_indexToRgb` | [L163](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color.dart#L163) | 256-index to RGB tuple |
| `_rgbToIndexed` | [L182](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color.dart#L182) | RGB to nearest 256-index |
| `_indexedToAnsi` | [L218](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color.dart#L218) | 256-index to nearest ANSI 16 |
| `_redmeanDistance` | [L244](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color.dart#L244) | Perceptual RGB distance |
| `_cubeStep` | [L255](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color.dart#L255) | Cube step size (51) |
| `_grayStep` | [L259](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color.dart#L259) | Grayscale step (10) |
| `_grayBase` | [L262](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/color.dart#L262) | Grayscale base (8) |

---

### Cell and Grid

#### `Cell` — [core/cell.dart#L8](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/cell.dart#L8)

**What:** A single character cell on the terminal grid.
**How:** A freezed value class holding `char` (default: space), `style` (`TextStyle`), `wideContinuation` flag (marks the second cell of a wide character), and optional `hyperlink` URI.

| Member | Line | Description |
|--------|------|-------------|
| `factory Cell({String char, TextStyle style, bool wideContinuation, String? hyperlink})` | [L11](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/cell.dart#L11) | Primary constructor with defaults |

#### `CellGrid` — [core/cell_grid.dart#L4](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/cell_grid.dart#L4)

**What:** A row-major 2D grid of `Cell` objects.
**How:** Extension type wrapping `List<List<Cell>>`. Implements `List<List<Cell>>` for direct indexing. Provides safe accessors and factory constructors.

| Member | Line | Description |
|--------|------|-------------|
| `CellGrid(List<List<Cell>> _grid)` | [L4](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/cell_grid.dart#L4) | Wrap existing grid |
| `CellGrid.empty()` | [L9](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/cell_grid.dart#L9) | Empty grid |
| `CellGrid.generate(Size size)` | [L11](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/cell_grid.dart#L11) | Blank grid of given size |
| `int get height` | [L5](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/cell_grid.dart#L5) | Row count |
| `int get width` | [L6](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/cell_grid.dart#L6) | Column count |
| `bool get isEmpty` | [L7](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/cell_grid.dart#L7) | No rows |
| `List<Cell> row(int row)` | [L18](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/cell_grid.dart#L18) | Safe row accessor |
| `Cell? getCell(int row, int col)` | [L21](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/cell_grid.dart#L21) | Safe cell accessor |

---

### Style

#### `TextStyle` — [core/style.dart#L9](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/style.dart#L9)

**What:** Text styling with SGR attributes and foreground/background colors.
**How:** A freezed value class. All fields are nullable (null = inherit/unset). `TextStyle.empty` has all fields null. `resolveColor` downgrades colors per `ColorProfile`. `inherit` merges with a parent style. `TextStyle.link` creates the default hyperlink style.

| Member | Line | Description |
|--------|------|-------------|
| `factory TextStyle({Color? foreground, Color? background, bool? bold, bool? dim, bool? italic, bool? underline, bool? blink, bool? reverse, bool? strikethrough, bool? overline, int? width, int? height, bool? wordWrap})` | [L12](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/style.dart#L12) | Primary constructor |
| `static TextStyle empty` | [L29](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/style.dart#L29) | All-null style |
| `bool get isClear` | [L32](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/style.dart#L32) | All fields null |
| `TextStyle resolveColor(ColorProfile profile)` | [L48](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/style.dart#L48) | Downgrade colors to profile |
| `TextStyle inherit(TextStyle parent)` | [L58](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/style.dart#L58) | Merge with parent |
| `static TextStyle link({String? uri})` | [L78](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/style.dart#L78) | Default hyperlink style |

---

### Surface

#### `Surface` — [core/surface.dart#L16](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/surface.dart#L16)

**What:** A grid-based terminal canvas for painting text, borders, and styled regions.
**How:** Holds a `CellGrid` and a `Size`. Provides `putChar`, `putText`, `fillRect`, `clearRect`, and `drawBorder` for painting. `resize` preserves the overlapping region. `toPlainLines` exports text without escapes; `toAnsiLines` (via extension) exports styled ANSI output with diffing between adjacent cells.

| Member | Line | Description |
|--------|------|-------------|
| `Surface({required Size size, required CellGrid grid})` | [L30](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/surface.dart#L30) | Primary constructor |
| `factory Surface.genetate(Size size)` | [L33](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/surface.dart#L33) | Blank surface (note: typo in name) |
| `Surface.fromGrid(CellGrid grid)` | [L37](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/surface.dart#L37) | From existing grid |
| `Surface resize(int newWidth, int newHeight)` | [L58](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/surface.dart#L58) | Resize preserving overlap |
| `void putChar(int x, int y, String ch, TextStyle style)` | [L62](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/surface.dart#L62) | Write single char |
| `void putText(int x, int y, String text, TextStyle style)` | [L76](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/surface.dart#L76) | Write text with grapheme awareness |
| `void fillRect(int x, int y, int w, int h, String ch, TextStyle style)` | [L106](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/surface.dart#L106) | Fill region with char |
| `void clearRect(int x, int y, int w, int h)` | [L125](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/surface.dart#L125) | Clear region |
| `void drawBorder(Rect r, {String? borderChars, TextStyle? style, String? title})` | [L137](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/surface.dart#L137) | Draw border with optional title |
| `List<String> toPlainLines()` | [L205](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/surface.dart#L205) | Export as plain text |

#### `SurfaceAnsiExport` (extension on `Surface`) — [core/surface.dart#L245](https://github.com/iapicca/t22e/blob/no_ffi/packages/core/lib/src/surface.dart#L245)

**What:** Exports the surface as ANSI-escaped lines for terminal output.
**How:** `toAnsiLines()` iterates cells, diffs styles between adjacent cells to minimize escape sequences, and handles [OSC 8](https://gist.github.com/egmontkob/eb114294efbcd5adb72c2c9f1834b3e4) hyperlink sequences.

---

### MVU Architecture

> The framework uses an [Elm Architecture](https://guide.elm-lang.org/architecture/) / MVU (Model-View-Update) pattern.

#### `Model<M extends Model<M>>` — [widgets/model.dart#L5](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/model.dart#L5)

**What:** Abstract base class for all stateful models.
**How:** Subclasses implement `update(Msg)` which returns a new model + optional `Cmd`, and `view()` which returns a `Widget` or `Surface`.

| Member | Line | Description |
|--------|------|-------------|
| `(M, Cmd?) update(Msg msg)` | [L9](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/model.dart#L9) | Abstract - process message, return new state |
| `dynamic view()` | [L12](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/model.dart#L12) | Abstract - render current state |

#### `Msg` — [widgets/msg.dart#L4](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/msg.dart#L4)

**What:** Base class for all messages in the MVU architecture.
**How:** Abstract const class. All message types extend it.

| Class | Line | Description |
|-------|------|-------------|
| `QuitMsg` | [L9](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/msg.dart#L9) | Signals program termination |
| `WindowSizeMsg` | [L14](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/msg.dart#L14) | Terminal resized (`width`, `height`) |
| `ClearScreenMsg` | [L32](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/msg.dart#L32) | Requests full repaint |
| `EnterAltScreenMsg` | [L37](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/msg.dart#L37) | Enter alternate screen buffer |
| `ExitAltScreenMsg` | [L42](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/msg.dart#L42) | Exit alternate screen buffer |
| `HideCursorMsg` | [L47](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/msg.dart#L47) | Hide cursor |
| `ShowCursorMsg` | [L52](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/msg.dart#L52) | Show cursor |
| `KeyMsg` | [L57](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/msg.dart#L57) | Keyboard event (carries `KeyEvent`) |
| `MouseMsg` | [L70](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/msg.dart#L70) | Mouse event (carries `MouseEvent`) |
| `ProgressTickMsg` | [L83](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/msg.dart#L83) | Progress bar animation tick |
| `SpinnerTickMsg` | [L88](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/msg.dart#L88) | Spinner animation tick |
| `CursorBlinkMsg` | [L93](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/msg.dart#L93) | Text input cursor blink |
| `ListEnterMsg` | [L98](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/msg.dart#L98) | List item selected (`index`, `label`) |
| `DialogCloseMsg` | [L108](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/msg.dart#L108) | Dialog dismissed |
| `DialogButtonMsg` | [L113](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/msg.dart#L113) | Dialog button pressed (`index`, `label`) |

#### `Cmd` — [widgets/cmd.dart#L9](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/cmd.dart#L9)

**What:** Base sealed class for side-effect commands in the MVU runtime.
**How:** `execute(enqueue)` runs the command and optionally returns a `Msg` to enqueue. The sealed hierarchy ensures exhaustive handling.

| Class | Line | Description |
|-------|------|-------------|
| `TickCmd` | [L17](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/cmd.dart#L17) | One-shot delayed message |
| `EveryCmd` | [L31](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/cmd.dart#L31) | Periodic timer (uses `Disposable` mixin) |
| `BatchCmd` | [L58](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/cmd.dart#L58) | Run multiple commands concurrently |
| `SequenceCmd` | [L75](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/cmd.dart#L75) | Run commands sequentially |
| `ExecCmd` | [L91](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/cmd.dart#L91) | Run external process |
| `NoCmd` | [L109](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/cmd.dart#L109) | No-op |

#### Cmd factory functions — [widgets/cmd.dart](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/cmd.dart)

| Function | Line | Description |
|----------|------|-------------|
| `tick` | [L117](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/cmd.dart#L117) | Creates a `TickCmd` |
| `every` | [L121](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/cmd.dart#L121) | Creates an `EveryCmd` |
| `batch` | [L125](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/cmd.dart#L125) | Creates a `BatchCmd` |
| `sequence` | [L128](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/cmd.dart#L128) | Creates a `SequenceCmd` |
| `execProcess` | [L131](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/cmd.dart#L131) | Creates an `ExecCmd` |
| `none` | [L138](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/cmd.dart#L138) | Creates a `NoCmd` |

---

### Widget System

#### `Widget` — [widgets/widget.dart#L6](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/widget.dart#L6)

**What:** Abstract base class for all widgets.
**How:** Two-phase rendering: `layout(Constraints)` computes the widget's `Size`, then `paint(PaintingContext)` draws onto the `Surface`.

| Member | Line | Description |
|--------|------|-------------|
| `Size layout(Constraints constraints)` | [L10](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/widget.dart#L10) | Abstract - compute size |
| `void paint(PaintingContext context)` | [L13](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/widget.dart#L13) | Abstract - paint on surface |

#### `PaintingContext` — [widgets/widget.dart#L17](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/widget.dart#L17)

**What:** Carries the surface and offset/style context during painting.
**How:** Holds a `Surface`, `offsetX`/`offsetY`, and `inheritedStyle`. `child(x, y)` creates a sub-context for child widgets.

| Member | Line | Description |
|--------|------|-------------|
| `Surface surface` | [L19](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/widget.dart#L19) | Target surface |
| `int offsetX` | [L22](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/widget.dart#L22) | X offset from parent |
| `int offsetY` | [L25](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/widget.dart#L25) | Y offset from parent |
| `TextStyle inheritedStyle` | [L28](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/widget.dart#L28) | Inherited text style |
| `PaintingContext child(int x, int y, {TextStyle? style})` | [L38](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/widget.dart#L38) | Create child context |

#### `WidgetRenderer` — [widgets/renderer.dart#L6](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/renderer.dart#L6)

**What:** Renders a widget tree to a `Surface`.
**How:** Static `render(Widget root, int width, int height)` runs layout then paint, returning the resulting `Surface`.

---

### Enums — [widgets/enums.dart](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/enums.dart)

| Enum | Line | Values | Description |
|------|------|--------|-------------|
| `TextAlign` | [L2](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/enums.dart#L2) | `left`, `center`, `right` | Horizontal text alignment |
| `MainAxisAlignment` | [L5](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/enums.dart#L5) | `start`, `center`, `end`, `spaceBetween`, `spaceAround` | Main axis alignment |
| `CrossAxisAlignment` | [L8](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/enums.dart#L8) | `start`, `center`, `end`, `stretch` | Cross axis alignment |
| `Axis` | [L11](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/enums.dart#L11) | `horizontal`, `vertical` | Orientation |
| `EchoMode` | [L14](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/enums.dart#L14) | `normal`, `password`, `noEcho` | Text input echo mode |
| `BorderStyle` | [L17](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/enums.dart#L17) | `single`, `double`, `rounded`, `thick` | Border line style |

---

### Basic Widgets

#### `Text` — [widgets/basic/text.dart#L9](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/basic/text.dart#L9)

**What:** A text display widget with alignment and optional word wrapping.
**How:** `layout` measures text and optionally wraps it to fit within constraints using word-boundary-aware wrapping (`_wrapText`). `paint` writes each line to the surface with alignment and style inheritance.

| Member | Line | Description |
|--------|------|-------------|
| `Text(this.text, {style, align, wordWrap})` | [L23](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/basic/text.dart#L23) | Constructor |
| `Size layout(Constraints)` | [L36](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/basic/text.dart#L36) | Measure and wrap |
| `void paint(PaintingContext)` | [L115](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/basic/text.dart#L115) | Paint lines with alignment |

#### `Hyperlink` — [widgets/basic/link.dart#L8](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/basic/link.dart#L8)

**What:** A clickable hyperlink widget using [OSC 8](https://gist.github.com/egmontkob/eb114294efbcd5adb72c2c9f1834b3e4) terminal links.
**How:** `layout` measures text width (single line). `paint` writes each rune as a `Cell` with the hyperlink URI for OSC 8 support.

| Member | Line | Description |
|--------|------|-------------|
| `Hyperlink(this.uri, this.text, {this.style})` | [L20](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/basic/link.dart#L20) | Constructor |
| `Size layout(Constraints)` | [L23](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/basic/link.dart#L23) | Measure text |
| `void paint(PaintingContext)` | [L30](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/basic/link.dart#L30) | Paint with hyperlink URI |

#### `Box` — [widgets/basic/box.dart#L10](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/basic/box.dart#L10)

**What:** A bordered container with optional title, padding, and child.
**How:** `layout` reserves space for border (1 cell per side) + padding, then lays out the child in the remaining space. `paint` draws border characters and delegates child painting.

| Member | Line | Description |
|--------|------|-------------|
| `Box({child, borderStyle, padding, title, titleStyle, borderTextStyle})` | [L29](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/basic/box.dart#L29) | Constructor |
| `Size layout(Constraints)` | [L45](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/basic/box.dart#L45) | Layout with border + padding |
| `void paint(PaintingContext)` | [L80](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/basic/box.dart#L80) | Draw border, paint child |
| `void _drawBorder(PaintingContext, Rect)` | [L103](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/basic/box.dart#L103) | Draw border chars |
| `String _borderChars()` | [L141](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/basic/box.dart#L141) | 6-char border set for style |

#### `Spacer` — [widgets/basic/spacer.dart#L5](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/basic/spacer.dart#L5)

**What:** Expands to fill available space with a given flex factor.
**How:** `layout` returns max available size from constraints. `paint` is a no-op.

---

### Container Widgets

#### `Row` — [widgets/container/row.dart#L7](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/container/row.dart#L7)

**What:** Lays out children horizontally with flexbox-like distribution.
**How:** `layout` measures children, distributes horizontal space via `splitHorizontal`, and computes vertical sizing. `paint` positions each child at its computed x-offset with cross-axis alignment.

| Member | Line | Description |
|--------|------|-------------|
| `Row({required children, gap, mainAxisAlignment, crossAxisAlignment})` | [L20](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/container/row.dart#L20) | Constructor |
| `Size layout(Constraints)` | [L34](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/container/row.dart#L34) | Horizontal flexbox layout |
| `void paint(PaintingContext)` | [L126](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/container/row.dart#L126) | Paint children at positions |

#### `Column` — [widgets/container/column.dart#L7](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/container/column.dart#L7)

**What:** Lays out children vertically with flexbox-like distribution.
**How:** Mirror of `Row` on the vertical axis. Uses `splitVertical` for space distribution.

| Member | Line | Description |
|--------|------|-------------|
| `Column({required children, gap, mainAxisAlignment, crossAxisAlignment})` | [L20](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/container/column.dart#L20) | Constructor |
| `Size layout(Constraints)` | [L34](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/container/column.dart#L34) | Vertical flexbox layout |
| `void paint(PaintingContext)` | [L126](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/container/column.dart#L126) | Paint children at positions |

---

### Interactive Widgets

#### `TextInput` — [widgets/interactive/text_input.dart#L15](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/interactive/text_input.dart#L15)

**What:** An interactive text input with cursor, echo modes, and grapheme-aware editing.
**How:** Extends `Model<TextInput>`. `update` handles `CursorBlinkMsg` (toggles visibility, reschedules) and `KeyMsg` (dispatches to `_handleKey` for cursor movement, editing, and character input). Uses [grapheme cluster](https://unicode.org/reports/tr29/) boundaries for safe multi-byte character navigation. `view` renders as a `Row` of `Text` widgets with a visible cursor character.

| Member | Line | Description |
|--------|------|-------------|
| `const TextInput({value, cursorPosition, selectionStart, maxLength, echoMode, validator, cursorVisible, blinkInterval})` | [L40](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/interactive/text_input.dart#L40) | Constructor |
| `update(Msg msg)` | [L52](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/interactive/text_input.dart#L52) | Handle blink + key messages |
| `_handleKey(KeyEvent event)` | [L66](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/interactive/text_input.dart#L66) | Key dispatch |
| `_isPrintable(String char)` | [L146](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/interactive/text_input.dart#L146) | Printable check |
| `_insertChar(String char)` | [L153](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/interactive/text_input.dart#L153) | Insert at cursor |
| `_prevGraphemeBoundary(int pos)` | [L167](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/interactive/text_input.dart#L167) | Move left by grapheme |
| `_nextGraphemeBoundary(int pos)` | [L181](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/interactive/text_input.dart#L181) | Move right by grapheme |
| `String get _displayValue` | [L194](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/interactive/text_input.dart#L194) | Echo-mode-transformed value |
| `Widget view()` | [L226](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/interactive/text_input.dart#L226) | Render as widget |

#### `Scrollable` — [widgets/interactive/scrollable.dart#L12](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/interactive/scrollable.dart#L12)

**What:** A scrollable viewport wrapping a child widget.
**How:** Extends `Model<Scrollable>`. `update` handles `KeyMsg` (stub - scroll key handling not yet implemented). `view` returns a `_ScrollView` widget that paints the child at a negative scroll offset with a scrollbar.

| Member | Line | Description |
|--------|------|-------------|
| `const Scrollable({scrollX, scrollY, child, axis, scrollStep, viewportWidth, viewportHeight})` | [L34](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/interactive/scrollable.dart#L34) | Constructor |
| `update(Msg msg)` | [L45](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/interactive/scrollable.dart#L45) | Handle key messages |
| `Widget view()` | [L78](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/interactive/scrollable.dart#L78) | Return scroll view |

#### `_ScrollView` (private) — [widgets/interactive/scrollable.dart#L90](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/interactive/scrollable.dart#L90)

**What:** Internal widget that paints the child at a scroll offset with a scrollbar.
**How:** `layout` returns viewport size clamped to constraints. `paint` draws the child offset by negative scroll values and renders a light-shade scrollbar on the right edge.

#### `ListItem` — [widgets/interactive/list.dart#L15](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/interactive/list.dart#L15)

**What:** A single list item with a label and optional icon.

| Member | Line | Description |
|--------|------|-------------|
| `const ListItem(this.label, {this.icon})` | [L22](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/interactive/list.dart#L22) | Constructor |

#### `ListView` — [widgets/interactive/list.dart#L26](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/interactive/list.dart#L26)

**What:** A scrollable, keyboard-navigable list with optional multi-select.
**How:** Extends `Model<ListView>`. `update` handles `KeyMsg` for up/down/home/end/pageUp/pageDown navigation, enter (emits `ListEnterMsg`), and space (multi-select toggle). `view` renders items in a bordered `Box` with `Column` layout.

| Member | Line | Description |
|--------|------|-------------|
| `const ListView({items, selectedIndex, multiSelected, multiSelect, viewportHeight})` | [L42](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/interactive/list.dart#L42) | Constructor |
| `update(Msg msg)` | [L51](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/interactive/list.dart#L51) | Handle key messages |
| `_handleKey(KeyEvent event)` | [L59](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/interactive/list.dart#L59) | Navigation + selection |
| `Widget view()` | [L120](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/interactive/list.dart#L120) | Render list |
| `int get _visibleStart` | [L146](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/interactive/list.dart#L146) | Scroll window start |
| `Widget _buildItemRow(...)` | [L158](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/interactive/list.dart#L158) | Build single item row |

---

### Visual Widgets

#### `Spinner` — [widgets/visual/spinner.dart#L11](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/visual/spinner.dart#L11)

**What:** A braille-based animated spinner with optional label.
**How:** Extends `Model<Spinner>`. `update` handles `SpinnerTickMsg` to advance the frame index and schedule the next tick. `view` renders current frame + label as a `Row`.

| Member | Line | Description |
|--------|------|-------------|
| `const Spinner({frame, frames, interval, label})` | [L27](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/visual/spinner.dart#L27) | Constructor |
| `update(Msg msg)` | [L35](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/visual/spinner.dart#L35) | Advance frame |
| `Widget view()` | [L61](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/visual/spinner.dart#L61) | Render spinner |

#### `Table` — [widgets/visual/table.dart#L14](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/visual/table.dart#L14)

**What:** A data table with column headers, sort indicators, and alternating row styles.
**How:** Extends `Model<Table>`. `update` is a no-op. `view` renders headers with sort triangle indicators and data rows with alternating dim styles in a `Column` of `Row`s.

| Member | Line | Description |
|--------|------|-------------|
| `const Table({columns, rows, sortColumn, sortAscending, showRowNumbers})` | [L30](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/visual/table.dart#L30) | Constructor |
| `Widget view()` | [L61](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/visual/table.dart#L61) | Render table |

#### `ProgressBar` — [widgets/visual/progress.dart#L11](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/visual/progress.dart#L11)

**What:** A progress bar with determinate (fraction) and indeterminate (animated blob) modes.
**How:** Extends `Model<ProgressBar>`. `update` handles `ProgressTickMsg` for indeterminate mode animation. `view` builds a fill/empty bar string or a scrolling 3-cell blob for indeterminate.

| Member | Line | Description |
|--------|------|-------------|
| `const ProgressBar({fraction, label, barWidth, fillChar, emptyChar, animInterval, indeterminateOffset})` | [L33](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/visual/progress.dart#L33) | Constructor |
| `update(Msg msg)` | [L44](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/visual/progress.dart#L44) | Animate indeterminate |
| `Widget view()` | [L76](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/visual/progress.dart#L76) | Render bar |
| `String _determinateBar(double frac)` | [L89](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/visual/progress.dart#L89) | Build filled/empty string |
| `String _indeterminateBar(int offset)` | [L95](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/visual/progress.dart#L95) | Build scrolling blob |

#### `DialogButton` — [widgets/visual/dialog.dart#L17](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/visual/dialog.dart#L17)

**What:** A button in a dialog with label and focus state.

#### `Dialog` — [widgets/visual/dialog.dart#L28](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/visual/dialog.dart#L28)

**What:** A modal dialog overlay with title, content, and buttons.
**How:** Extends `Model<Dialog>`. `update` handles `KeyMsg`: Escape dismisses (emits `DialogCloseMsg`), Tab/Shift-Tab cycles button focus, Enter activates the focused button (emits `DialogButtonMsg`). `view` returns a `_DialogOverlay`.

| Member | Line | Description |
|--------|------|-------------|
| `const Dialog({title, content, buttons, dismissible, focusedButton})` | [L44](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/visual/dialog.dart#L44) | Constructor |
| `update(Msg msg)` | [L53](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/visual/dialog.dart#L53) | Handle key messages |
| `_handleKey(KeyEvent event)` | [L61](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/visual/dialog.dart#L61) | Escape/Tab/Enter |
| `Widget view()` | [L104](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/visual/dialog.dart#L104) | Return overlay widget |

#### `_DialogOverlay` (private) — [widgets/visual/dialog.dart#L115](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/visual/dialog.dart#L115)

**What:** Internal widget that dims the background and paints the dialog centered on screen.
**How:** `layout` returns full surface size. `paint` dims existing content, computes dialog dimensions from `DialogLayout` constants, and paints a double-bordered `Box` with content and button bar.

#### `SizedBox` — [widgets/visual/dialog.dart#L217](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/visual/dialog.dart#L217)

**What:** Constrains a child to a specific size.
**How:** `layout` overrides max constraints for the child. `paint` delegates to child.

---

### Constants

#### `DialogLayout` — [widgets/dialog_layout.dart#L2](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/dialog_layout.dart#L2)

**What:** Dialog sizing constants.

| Member | Line | Value |
|--------|------|-------|
| `dialogWidthRatio` | [L6](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/dialog_layout.dart#L6) | 0.6 |
| `dialogHeightRatio` | [L9](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/dialog_layout.dart#L9) | 0.4 |
| `dialogMinWidth` | [L12](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/dialog_layout.dart#L12) | 20 |
| `dialogMinHeight` | [L15](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/dialog_layout.dart#L15) | 5 |
| `dialogHMargin` | [L18](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/dialog_layout.dart#L18) | 4 |
| `dialogButtonBarHeight` | [L21](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/dialog_layout.dart#L21) | 3 |
| `dialogContentClampHigh` | [L24](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/dialog_layout.dart#L24) | 100 |

#### `TextInputDefaults` — [widgets/text_input_defaults.dart#L2](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/text_input_defaults.dart#L2)

| Member | Line | Value | Description |
|--------|------|-------|-------------|
| `textInputNoMaxLength` | [L6](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/text_input_defaults.dart#L6) | -1 | Sentinel for unlimited length |

#### `SpinnerFrames` — [widgets/spinner_frames.dart#L2](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/spinner_frames.dart#L2)

| Member | Line | Description |
|--------|------|-------------|
| `spinnerFrames` | [L6](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/spinner_frames.dart#L6) | 10 braille Unicode animation frames |

---

### Riverpod

#### `everyCmdProvider` — [widgets/providers.dart#L20](https://github.com/iapicca/t22e/blob/no_ffi/packages/widgets/lib/src/providers.dart#L20)

**What:** Factory provider that creates an `EveryCmd` managed by Riverpod.
**How:** Annotated with `@riverpod`. Creates an `EveryCmd` with the given interval that emits `ClearScreenMsg` messages. Registers `cmd.dispose` via `ref.onDispose` for automatic cleanup.

---

## logic

> Merges the old **notifier** and **lifecycle** packages.

### Disposal

#### `Disposed` — [notifier/disposed.dart#L2](https://github.com/iapicca/t22e/blob/no_ffi/packages/notifier/lib/src/disposed.dart#L2)

**What:** Immutable guard wrapping a `bool` disposed flag.
**How:** Extension type over `bool`. `check()` throws `StateError` if disposed. `safeCheck` returns the raw boolean.

| Member | Line | Description |
|--------|------|-------------|
| `Disposed({bool isDisposed})` | [L4](https://github.com/iapicca/t22e/blob/no_ffi/packages/notifier/lib/src/disposed.dart#L4) | Const constructor |
| `check({String? message})` | [L7](https://github.com/iapicca/t22e/blob/no_ffi/packages/notifier/lib/src/disposed.dart#L7) | Throw if disposed |
| `bool get safeCheck` | [L12](https://github.com/iapicca/t22e/blob/no_ffi/packages/notifier/lib/src/disposed.dart#L12) | Non-throwing check |

#### `Disposable` (mixin) — [notifier/disposable.dart#L17](https://github.com/iapicca/t22e/blob/no_ffi/packages/notifier/lib/src/disposable.dart#L17)

**What:** Provides guarded disposal lifecycle for resource-bearing classes.
**How:** Mixin that holds a `Disposed` guard. `dispose()` marks the object as disposed (idempotent on first call, throws on subsequent). Subclasses must call `super.dispose()`. The `check` getter exposes the guard's check function for use in subclass methods.

| Member | Line | Description |
|--------|------|-------------|
| `bool get isDisposed` | [L21](https://github.com/iapicca/t22e/blob/no_ffi/packages/notifier/lib/src/disposable.dart#L21) | Public read-only check |
| `CheckDisposed get check` | [L26](https://github.com/iapicca/t22e/blob/no_ffi/packages/notifier/lib/src/disposable.dart#L26) | Protected guard function |
| `dispose({String? message})` | [L30](https://github.com/iapicca/t22e/blob/no_ffi/packages/notifier/lib/src/disposable.dart#L30) | Mark as disposed |

#### `VoidCallback` — [notifier/disposable.dart#L6](https://github.com/iapicca/t22e/blob/no_ffi/packages/notifier/lib/src/disposable.dart#L6)

**What:** `typedef void Function()` - callback with no arguments.

#### `CheckDisposed` — [notifier/disposable.dart#L9](https://github.com/iapicca/t22e/blob/no_ffi/packages/notifier/lib/src/disposable.dart#L9)

**What:** `typedef void Function({String? message})` - disposed-state check signature.

---

### Initialization

#### `Initialized` — [notifier/init_mixin.dart#L7](https://github.com/iapicca/t22e/blob/no_ffi/packages/notifier/lib/src/init_mixin.dart#L7)

**What:** Immutable guard wrapping a `bool` initialized flag.
**How:** Extension type over `bool`. `check()` throws `StateError` if NOT initialized. `safeCheck` returns the raw boolean.

| Member | Line | Description |
|--------|------|-------------|
| `Initialized({bool isInitialized})` | [L8](https://github.com/iapicca/t22e/blob/no_ffi/packages/notifier/lib/src/init_mixin.dart#L8) | Const constructor |
| `check({String? message})` | [L12](https://github.com/iapicca/t22e/blob/no_ffi/packages/notifier/lib/src/init_mixin.dart#L12) | Throw if not initialized |
| `bool get safeCheck` | [L17](https://github.com/iapicca/t22e/blob/no_ffi/packages/notifier/lib/src/init_mixin.dart#L17) | Non-throwing check |

#### `CheckInitialized` — [notifier/init_mixin.dart#L4](https://github.com/iapicca/t22e/blob/no_ffi/packages/notifier/lib/src/init_mixin.dart#L4)

**What:** `typedef void Function({String? message})` - initialization-state check signature.

#### `InitMixin` (mixin) — [notifier/init_mixin.dart#L27](https://github.com/iapicca/t22e/blob/no_ffi/packages/notifier/lib/src/init_mixin.dart#L27)

**What:** Provides guarded initialization lifecycle.
**How:** Mixin holding an `Initialized` guard. `init()` marks the object as initialized (idempotent unless `throwIfExists` is true). `checkInit` exposes the guard's check function.

| Member | Line | Description |
|--------|------|-------------|
| `bool get isInitialized` | [L30](https://github.com/iapicca/t22e/blob/no_ffi/packages/notifier/lib/src/init_mixin.dart#L30) | Public read-only check |
| `CheckInitialized get checkInit` | [L33](https://github.com/iapicca/t22e/blob/no_ffi/packages/notifier/lib/src/init_mixin.dart#L33) | Protected guard function |
| `init({String? message, bool throwIfExists})` | [L36](https://github.com/iapicca/t22e/blob/no_ffi/packages/notifier/lib/src/init_mixin.dart#L36) | Mark as initialized |

---

### Notifiers

#### `ChangeNotifier` — [notifier/change_notifier.dart#L7](https://github.com/iapicca/t22e/blob/no_ffi/packages/notifier/lib/src/change_notifier.dart#L7)

**What:** Observable object managing a list of listeners (analogous to [Flutter's ChangeNotifier](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html)).
**How:** Uses the `Disposable` mixin. `addListener` registers callbacks (prevents duplicates). `removeListener` unregisters. `notifyListeners` copies the list before iteration to guard against mid-iteration mutation. `dispose` clears all listeners.

| Member | Line | Description |
|--------|------|-------------|
| `bool get hasListeners` | [L11](https://github.com/iapicca/t22e/blob/no_ffi/packages/notifier/lib/src/change_notifier.dart#L11) | Any listeners registered |
| `addListener(VoidCallback listener, {String? message})` | [L15](https://github.com/iapicca/t22e/blob/no_ffi/packages/notifier/lib/src/change_notifier.dart#L15) | Register listener |
| `removeListener(VoidCallback listener, {String? message})` | [L21](https://github.com/iapicca/t22e/blob/no_ffi/packages/notifier/lib/src/change_notifier.dart#L21) | Unregister listener |
| `notifyListeners({String? message})` | [L28](https://github.com/iapicca/t22e/blob/no_ffi/packages/notifier/lib/src/change_notifier.dart#L28) | Notify all listeners |
| `dispose({String? message})` | [L38](https://github.com/iapicca/t22e/blob/no_ffi/packages/notifier/lib/src/change_notifier.dart#L38) | Clear listeners + dispose |

#### `ValueNotifier<T>` — [notifier/value_notifier.dart#L5](https://github.com/iapicca/t22e/blob/no_ffi/packages/notifier/lib/src/value_notifier.dart#L5)

**What:** A generic `ChangeNotifier` holding a single value that notifies listeners on change.
**How:** Extends `ChangeNotifier`. The `value` setter compares against the current value and calls `notifyListeners` only when it differs.

| Member | Line | Description |
|--------|------|-------------|
| `ValueNotifier(this._value, {this._message})` | [L12](https://github.com/iapicca/t22e/blob/no_ffi/packages/notifier/lib/src/value_notifier.dart#L12) | Constructor |
| `T get value` | [L15](https://github.com/iapicca/t22e/blob/no_ffi/packages/notifier/lib/src/value_notifier.dart#L15) | Current value |
| `set value(T newValue)` | [L18](https://github.com/iapicca/t22e/blob/no_ffi/packages/notifier/lib/src/value_notifier.dart#L18) | Set + notify if changed |

---

### Signal Handling

#### `ProcessSignal` — [lifecycle/process_signal.dart#L7](https://github.com/iapicca/t22e/blob/no_ffi/packages/lifecycle/lib/src/process_signal.dart#L7)

**What:** Sealed class representing POSIX signals for pattern matching.
**How:** Freezed sealed class with two variants: `Sigint` (Ctrl+C / interrupt) and `Sigterm` (termination request). Enables exhaustive `switch` handling.

| Factory | Line | Description |
|---------|------|-------------|
| `ProcessSignal.sigint()` | [L8](https://github.com/iapicca/t22e/blob/no_ffi/packages/lifecycle/lib/src/process_signal.dart#L8) | SIGINT signal |
| `ProcessSignal.sigterm()` | [L9](https://github.com/iapicca/t22e/blob/no_ffi/packages/lifecycle/lib/src/process_signal.dart#L9) | SIGTERM signal |

#### `SignalHandler` — [lifecycle/signal_handler.dart#L18](https://github.com/iapicca/t22e/blob/no_ffi/packages/lifecycle/lib/src/signal_handler.dart#L18)

**What:** Handles POSIX signals for graceful shutdown.
**How:** Uses `Disposable` mixin. `install()` subscribes to SIGINT (calls `onInterrupt`) and SIGTERM (calls `onCleanup` then `exit(0)`) streams. `dispose()` cancels both subscriptions.

| Member | Line | Description |
|--------|------|-------------|
| `SignalHandler({onInterrupt, onCleanup, sigint, sigterm})` | [L27](https://github.com/iapicca/t22e/blob/no_ffi/packages/lifecycle/lib/src/signal_handler.dart#L27) | Constructor |
| `void install()` | [L34](https://github.com/iapicca/t22e/blob/no_ffi/packages/lifecycle/lib/src/signal_handler.dart#L34) | Subscribe to signals |
| `void dispose({String? message})` | [L47](https://github.com/iapicca/t22e/blob/no_ffi/packages/lifecycle/lib/src/signal_handler.dart#L47) | Cancel subscriptions |

---

### Terminal Guard

#### `TerminalGuard` — [lifecycle/terminal_guard.dart#L12](https://github.com/iapicca/t22e/blob/no_ffi/packages/lifecycle/lib/src/terminal_guard.dart#L12)

**What:** Manages terminal restoration ensuring it runs exactly once.
**How:** Extends `ValueNotifier<bool>` with `InitMixin`. `arm()` resets to not-restored. `restore()` calls `onRestore` once (idempotent). `disarm()` marks done without calling restore. `runGuarded(body)` wraps execution in try/finally with `restore()`. `dispose()` calls `restore()` first.

| Member | Line | Description |
|--------|------|-------------|
| `TerminalGuard({required onRestore})` | [L15](https://github.com/iapicca/t22e/blob/no_ffi/packages/lifecycle/lib/src/terminal_guard.dart#L15) | Constructor |
| `bool get isRestored` | [L17](https://github.com/iapicca/t22e/blob/no_ffi/packages/lifecycle/lib/src/terminal_guard.dart#L17) | Whether restored |
| `void arm()` | [L19](https://github.com/iapicca/t22e/blob/no_ffi/packages/lifecycle/lib/src/terminal_guard.dart#L19) | Reset to not-restored |
| `void restore()` | [L24](https://github.com/iapicca/t22e/blob/no_ffi/packages/lifecycle/lib/src/terminal_guard.dart#L24) | Restore terminal (once) |
| `void disarm()` | [L30](https://github.com/iapicca/t22e/blob/no_ffi/packages/lifecycle/lib/src/terminal_guard.dart#L30) | Mark done without restore |
| `void runGuarded<T>(T Function() body)` | [L34](https://github.com/iapicca/t22e/blob/no_ffi/packages/lifecycle/lib/src/terminal_guard.dart#L34) | Try/finally with restore |
| `void dispose({String? message})` | [L43](https://github.com/iapicca/t22e/blob/no_ffi/packages/lifecycle/lib/src/terminal_guard.dart#L43) | Restore + dispose |

---

### Process Result

#### `ProcessResult` — [lifecycle/process_result.dart#L10](https://github.com/iapicca/t22e/blob/no_ffi/packages/lifecycle/lib/src/process_result.dart#L10)

**What:** Sealed class representing process execution outcome.
**How:** Freezed sealed class with `ProcessResult.success(exitCode, stdout, stderr)` and `ProcessResult.timeout(duration)` variants.

#### `exitCodeOk` — [lifecycle/process_result.dart#L6](https://github.com/iapicca/t22e/blob/no_ffi/packages/lifecycle/lib/src/process_result.dart#L6)

**What:** `const int` = `0` - successful exit code constant.

---

### Riverpod Providers

#### `sigintStreamProvider` — [lifecycle/signal_providers.dart#L6](https://github.com/iapicca/t22e/blob/no_ffi/packages/lifecycle/lib/src/signal_providers.dart#L6)

**What:** Provides a `Stream<ProcessSignal>` of SIGINT (Ctrl+C) OS signals.
**How:** Wraps `ProcessSignal.sigint.watch()` from `dart:io`.

#### `sigtermStreamProvider` — [lifecycle/signal_providers.dart#L11](https://github.com/iapicca/t22e/blob/no_ffi/packages/lifecycle/lib/src/signal_providers.dart#L11)

**What:** Provides a `Stream<ProcessSignal>` of SIGTERM OS signals.
**How:** Wraps `ProcessSignal.sigterm.watch()` from `dart:io`.

#### `terminalGuard` — [lifecycle/providers.dart#L10](https://github.com/iapicca/t22e/blob/no_ffi/packages/lifecycle/lib/src/providers.dart#L10)

**What:** Creates and manages a `TerminalGuard` instance.
**How:** `@riverpod` annotated. Calls `guard.init()`, registers `guard.dispose` via `ref.onDispose`. Family parameter: `onRestore`.

#### `signalHandler` — [lifecycle/providers.dart#L18](https://github.com/iapicca/t22e/blob/no_ffi/packages/lifecycle/lib/src/providers.dart#L18)

**What:** Creates and manages a `SignalHandler` instance.
**How:** `@riverpod` annotated. Wires SIGINT/SIGTERM streams from the above providers. Registers `handler.dispose` via `ref.onDispose`. Family parameters: `onInterrupt`, `onCleanup`.

---

# Engine

---

## protocol

> Merges the old **ansi**, **protocol**, and **unicode** packages.

### ANSI Sequences

#### `AnsiDefaults` — [ansi/ansi_defaults.dart#L5](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/ansi_defaults.dart#L5)

**What:** Pre-built ANSI escape sequence strings for common terminal operations.
**How:** Non-instantiable final class with `static const String` members. Each constant is a ready-to-use escape sequence.

| Member | Line | Description |
|--------|------|-------------|
| `resetAll` | [L9](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/ansi_defaults.dart#L9) | SGR reset all attributes |
| `resetColor` | [L12](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/ansi_defaults.dart#L12) | Reset fg + bg colors |
| `hideCursor` | [L16](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/ansi_defaults.dart#L16) | Hide cursor |
| `showCursor` | [L20](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/ansi_defaults.dart#L20) | Show cursor |
| `saveCursor` | [L24](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/ansi_defaults.dart#L24) | Save cursor position |
| `restoreCursor` | [L27](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/ansi_defaults.dart#L27) | Restore cursor position |
| `requestPosition` | [L30](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/ansi_defaults.dart#L30) | Request cursor position |
| `eraseScreen` | [L33](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/ansi_defaults.dart#L33) | Erase display |
| `eraseSavedLines` | [L37](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/ansi_defaults.dart#L37) | Erase scrollback |
| `eraseLineToEnd` | [L41](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/ansi_defaults.dart#L41) | Erase to end of line |
| `eraseLineToStart` | [L45](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/ansi_defaults.dart#L45) | Erase to start of line |
| `eraseLineAll` | [L49](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/ansi_defaults.dart#L49) | Erase entire line |
| `enterAltScreen` | [L53](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/ansi_defaults.dart#L53) | Enter alt buffer |
| `exitAltScreen` | [L57](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/ansi_defaults.dart#L57) | Exit alt buffer |
| `enableNormalMouse` | [L61](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/ansi_defaults.dart#L61) | X10 mouse tracking |
| `disableMouse` | [L65](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/ansi_defaults.dart#L65) | Disable mouse modes |
| `enableButtonEvents` | [L71](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/ansi_defaults.dart#L71) | Button-event tracking |
| `enableSgrMouse` | [L75](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/ansi_defaults.dart#L75) | SGR mouse reporting |
| `startSync` | [L79](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/ansi_defaults.dart#L79) | Start synchronized update |
| `endSync` | [L83](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/ansi_defaults.dart#L83) | End synchronized update |
| `enableBracketedPaste` | [L86](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/ansi_defaults.dart#L86) | Enable bracketed paste |
| `disableBracketedPaste` | [L90](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/ansi_defaults.dart#L90) | Disable bracketed paste |
| `enableFocusTracking` | [L94](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/ansi_defaults.dart#L94) | Enable focus tracking |
| `disableFocusTracking` | [L98](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/ansi_defaults.dart#L98) | Disable focus tracking |
| `disableKittyKeyboard` | [L102](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/ansi_defaults.dart#L102) | Disable Kitty keyboard |
| `queryKittyKeyboard` | [L105](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/ansi_defaults.dart#L105) | Query Kitty keyboard |
| `queryForegroundColor` | [L108](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/ansi_defaults.dart#L108) | Query default fg color |
| `queryBackgroundColor` | [L112](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/ansi_defaults.dart#L112) | Query default bg color |
| `queryDa1` | [L116](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/ansi_defaults.dart#L116) | Request DA1 |
| `querySyncUpdate` | [L119](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/ansi_defaults.dart#L119) | Query sync support |
| `softReset` | [L123](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/ansi_defaults.dart#L123) | Soft reset terminal |
| `enableMouse` | [L126](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/ansi_defaults.dart#L126) | Enable all mouse modes |

#### `CursorStyle` — [ansi/cursor.dart#L4](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/cursor.dart#L4)

**What:** Cursor shape styles for [DECSCUSR](https://vt100.net/docs/vt510-rm/DECSCUSR.html).
**How:** Enum with `value` property mapping to the numeric cursor style code.

| Value | Line | Code |
|-------|------|------|
| `blinkingBlock` | [L6](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/cursor.dart#L6) | 1 |
| `steadyBlock` | [L9](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/cursor.dart#L9) | 2 |
| `blinkingUnderline` | [L12](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/cursor.dart#L12) | 3 |
| `steadyUnderline` | [L15](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/cursor.dart#L15) | 4 |
| `blinkingBar` | [L18](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/cursor.dart#L18) | 5 |
| `steadyBar` | [L21](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/cursor.dart#L21) | 6 |

#### ANSI cursor functions — [ansi/cursor.dart](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/cursor.dart)

| Function | Line | Description |
|----------|------|-------------|
| `moveTo(int row, int col)` | [L29](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/cursor.dart#L29) | CUP - move to position (1-based) |
| `moveUp(int n)` | [L32](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/cursor.dart#L32) | CUU - cursor up |
| `moveDown(int n)` | [L35](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/cursor.dart#L35) | CUD - cursor down |
| `moveRight(int n)` | [L38](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/cursor.dart#L38) | CUF - cursor forward |
| `moveLeft(int n)` | [L41](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/cursor.dart#L41) | CUB - cursor back |
| `moveColumn(int col)` | [L44](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/cursor.dart#L44) | CHA - cursor horizontal absolute |
| `setStyle(CursorStyle style)` | [L47](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/cursor.dart#L47) | DECSCUSR - set cursor shape |

#### ANSI color functions — [ansi/color.dart](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/color.dart)

| Function | Line | Description |
|----------|------|-------------|
| `setForegroundRgb(int r, int g, int b)` | [L4](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/color.dart#L4) | CSI 38;2;r;g;b - truecolor fg |
| `setBackgroundRgb(int r, int g, int b)` | [L8](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/color.dart#L8) | CSI 48;2;r;g;b - truecolor bg |
| `setForeground256(int index)` | [L12](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/color.dart#L12) | CSI 38;5;n - 256-color fg |
| `setBackground256(int index)` | [L16](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/color.dart#L16) | CSI 48;5;n - 256-color bg |
| `foregroundAnsi(int color)` | [L20](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/color.dart#L20) | CSI 30+n - ANSI fg |
| `backgroundAnsi(int color)` | [L24](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/color.dart#L24) | CSI 40+n - ANSI bg |
| `foregroundBrightAnsi(int color)` | [L28](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/color.dart#L28) | CSI 90+n - bright ANSI fg |
| `backgroundBrightAnsi(int color)` | [L32](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/color.dart#L32) | CSI 100+n - bright ANSI bg |

#### ANSI SGR attribute functions — [ansi/codes.dart](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/codes.dart)

| Function | Line | Description |
|----------|------|-------------|
| `bold(bool on)` | [L4](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/codes.dart#L4) | SGR 1/22 |
| `dim(bool on)` | [L9](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/codes.dart#L9) | SGR 2/22 |
| `italic(bool on)` | [L14](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/codes.dart#L14) | SGR 3/23 |
| `underline(bool on)` | [L19](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/codes.dart#L19) | SGR 4/24 |
| `blink(bool on)` | [L24](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/codes.dart#L24) | SGR 5/25 |
| `reverse(bool on)` | [L29](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/codes.dart#L29) | SGR 7/27 |
| `strikethrough(bool on)` | [L34](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/codes.dart#L34) | SGR 9/29 |
| `overLine(bool on)` | [L39](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/codes.dart#L39) | SGR 53/55 |

#### ANSI erase functions — [ansi/erase.dart](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/erase.dart)

| Function | Line | Description |
|----------|------|-------------|
| `eraseDisplay(int mode)` | [L4](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/erase.dart#L4) | ED - erase display |
| `eraseLine(int mode)` | [L7](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/erase.dart#L7) | EL - erase line |

#### ANSI terminal functions — [ansi/term.dart](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/term.dart)

| Function | Line | Description |
|----------|------|-------------|
| `setTitle(String title)` | [L4](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/term.dart#L4) | OSC 0 - set window title |
| `hyperlink(String uri, String text, {String? id})` | [L8](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/term.dart#L8) | OSC 8 - wrap in hyperlink |
| `enableKittyKeyboard(int flags)` | [L14](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/term.dart#L14) | [Kitty keyboard](https://sw.kovidgoyal.net/kitty/keyboard-protocol/) enable |
| `writeClipboard(String base64Data, {String clipboard})` | [L17](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/term.dart#L17) | OSC 52 - write clipboard |
| `queryClipboard({String clipboard})` | [L21](https://github.com/iapicca/t22e/blob/no_ffi/packages/ansi/lib/src/term.dart#L21) | OSC 52 - read clipboard |

---

### Protocol Constants

#### `ControlBytes` — [protocol/control_bytes.dart#L3](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/control_bytes.dart#L3)

**What:** Terminal control bytes: C0/C1 controls, escape sequence introducers, and delimiters.
**How:** Non-instantiable final class. Holds `int` byte values and `String` sequence prefixes for ESC, CSI, OSC, DCS, ST, BEL, SS3, and DEC private mode prefix.

| Member | Line | Value | Description |
|--------|------|-------|-------------|
| `escapeByte` | [L7](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/control_bytes.dart#L7) | `0x1B` | ESC byte |
| `bellByte` | [L10](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/control_bytes.dart#L10) | `0x07` | BEL byte |
| `lineFeedByte` | [L13](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/control_bytes.dart#L13) | `0x0A` | LF byte |
| `carriageReturnByte` | [L16](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/control_bytes.dart#L16) | `0x0D` | CR byte |
| `stringTerminatorByte` | [L19](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/control_bytes.dart#L19) | `0x9C` | ST byte |
| `csiIntroducerByte` | [L22](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/control_bytes.dart#L22) | `0x9B` | CSI 8-bit form |
| `oscIntroducerByte` | [L25](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/control_bytes.dart#L25) | `0x9D` | OSC 8-bit form |
| `dcsIntroducerByte` | [L28](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/control_bytes.dart#L28) | `0x90` | DCS 8-bit form |
| `esc` | [L31](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/control_bytes.dart#L31) | `'\x1b'` | ESC string |
| `csi` | [L34](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/control_bytes.dart#L34) | `'\x1b['` | CSI prefix |
| `osc` | [L37](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/control_bytes.dart#L37) | `'\x1b]'` | OSC prefix |
| `dcs` | [L40](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/control_bytes.dart#L40) | `'\x1bP'` | DCS prefix |
| `st` | [L43](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/control_bytes.dart#L43) | `'\x1b\\'` | ST string |
| `bel` | [L46](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/control_bytes.dart#L46) | `'\x07'` | BEL string |
| `csiEntryByte` | [L49](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/control_bytes.dart#L49) | `0x5B` | '[' CSI start |
| `oscEntryByte` | [L52](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/control_bytes.dart#L52) | `0x5D` | ']' OSC start |
| `dcsEntryByte` | [L55](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/control_bytes.dart#L55) | `0x50` | 'P' DCS start |
| `dcsStByte` | [L58](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/control_bytes.dart#L58) | `0x5C` | '\\' DCS end |
| `ss3Byte` | [L61](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/control_bytes.dart#L61) | `0x4F` | 'O' SS3 start |
| `decPrivatePrefix` | [L64](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/control_bytes.dart#L64) | `0x3F` | '?' DEC private |
| `semicolonByte` | [L67](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/control_bytes.dart#L67) | `0x3B` | ';' separator |
| `intermediatePrefixByte` | [L70](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/control_bytes.dart#L70) | `0x3C` | '<' extended CSI |
| `bitShift8` | [L73](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/control_bytes.dart#L73) | `8` | 8-bit shift |
| `bitShift16` | [L76](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/control_bytes.dart#L76) | `16` | 16-bit shift |
| `bitShift24` | [L79](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/control_bytes.dart#L79) | `24` | 24-bit shift |
| `byteMask` | [L82](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/control_bytes.dart#L82) | `0xFF` | Byte mask |

#### `SgrCodes` — [protocol/sgr_codes.dart#L3](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/sgr_codes.dart#L3)

**What:** [SGR](https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_(Select_Graphic_Rendition)_parameters) attribute codes, color base indices, and extended color selectors.
**How:** Non-instantiable final class with 26 static constants covering attribute on/off codes, ANSI color bases, bright bases, extended color prefixes, and reset codes.

| Member | Line | Value | Description |
|--------|------|-------|-------------|
| `sgrReset` | [L7](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/sgr_codes.dart#L7) | 0 | Reset all |
| `sgrBold` | [L10](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/sgr_codes.dart#L10) | 1 | Bold on |
| `sgrFaint` | [L13](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/sgr_codes.dart#L13) | 2 | Faint on |
| `sgrItalic` | [L16](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/sgr_codes.dart#L16) | 3 | Italic on |
| `sgrUnderline` | [L19](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/sgr_codes.dart#L19) | 4 | Underline on |
| `sgrBlink` | [L22](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/sgr_codes.dart#L22) | 5 | Blink on |
| `sgrReverse` | [L25](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/sgr_codes.dart#L25) | 7 | Reverse on |
| `sgrStrikethrough` | [L28](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/sgr_codes.dart#L28) | 9 | Strikethrough on |
| `sgrOverline` | [L31](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/sgr_codes.dart#L31) | 53 | Overline on |
| `sgrNoBoldFaint` | [L34](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/sgr_codes.dart#L34) | 22 | Bold+faint off |
| `sgrNoItalic` | [L37](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/sgr_codes.dart#L37) | 23 | Italic off |
| `sgrNoUnderline` | [L40](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/sgr_codes.dart#L40) | 24 | Underline off |
| `sgrNoBlink` | [L43](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/sgr_codes.dart#L43) | 25 | Blink off |
| `sgrNoReverse` | [L46](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/sgr_codes.dart#L46) | 27 | Reverse off |
| `sgrNoStrikethrough` | [L49](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/sgr_codes.dart#L49) | 29 | Strikethrough off |
| `sgrNoOverline` | [L52](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/sgr_codes.dart#L52) | 55 | Overline off |
| `sgrFgAnsiBase` | [L55](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/sgr_codes.dart#L55) | 30 | Fg ANSI base |
| `sgrBgAnsiBase` | [L58](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/sgr_codes.dart#L58) | 40 | Bg ANSI base |
| `sgrFgBrightBase` | [L61](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/sgr_codes.dart#L61) | 90 | Fg bright base |
| `sgrBgBrightBase` | [L64](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/sgr_codes.dart#L64) | 100 | Bg bright base |
| `sgrFgExtended` | [L67](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/sgr_codes.dart#L67) | 38 | Extended fg prefix |
| `sgrBgExtended` | [L70](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/sgr_codes.dart#L70) | 48 | Extended bg prefix |
| `sgrFgReset` | [L73](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/sgr_codes.dart#L73) | 39 | Reset fg |
| `sgrBgReset` | [L76](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/sgr_codes.dart#L76) | 49 | Reset bg |
| `sgrColor256` | [L79](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/sgr_codes.dart#L79) | 5 | 256-color selector |
| `sgrColorRgb` | [L82](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/sgr_codes.dart#L82) | 2 | RGB selector |

#### `OscCodes` — [protocol/osc_codes.dart#L2](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/osc_codes.dart#L2)

**What:** [OSC](https://en.wikipedia.org/wiki/ANSI_escape_code#OSC_(Operating_System_Command)_sequences) PSN code constants.

| Member | Line | Value | Description |
|--------|------|-------|-------------|
| `oscTitle` | [L6](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/osc_codes.dart#L6) | 0 | Window title |
| `oscHyperlink` | [L9](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/osc_codes.dart#L9) | 8 | Hyperlink spec |
| `oscFgQuery` | [L12](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/osc_codes.dart#L12) | 10 | Fg color query |
| `oscBgQuery` | [L15](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/osc_codes.dart#L15) | 11 | Bg color query |
| `oscClipboard` | [L18](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/osc_codes.dart#L18) | 52 | Clipboard R/W |

#### `DecModes` — [protocol/dec_modes.dart#L2](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/dec_modes.dart#L2)

**What:** [DEC private modes](https://vt100.net/docs/vt510-rm/DECSET.html), cursor styles, and erase modes.

| Member | Line | Value | Description |
|--------|------|-------|-------------|
| `decModeMouseNormal` | [L6](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/dec_modes.dart#L6) | 1000 | X10 mouse |
| `decModeMouseButton` | [L9](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/dec_modes.dart#L9) | 1002 | Button-event |
| `decModeMouseSgr` | [L12](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/dec_modes.dart#L12) | 1006 | SGR mouse |
| `decModeFocus` | [L15](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/dec_modes.dart#L15) | 1004 | Focus tracking |
| `decModeBracketedPaste` | [L18](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/dec_modes.dart#L18) | 2004 | Bracketed paste |
| `decModeSync` | [L21](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/dec_modes.dart#L21) | 2026 | Sync updates |
| `decModeAltScreen` | [L24](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/dec_modes.dart#L24) | 1049 | Alt screen |
| `decModeCursorVisible` | [L27](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/dec_modes.dart#L27) | 25 | Cursor visible |
| `cursorStyleBlinkingBlock` | [L30](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/dec_modes.dart#L30) | 1 | Blinking block |
| `cursorStyleSteadyBlock` | [L33](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/dec_modes.dart#L33) | 2 | Steady block |
| `cursorStyleBlinkingUnderline` | [L36](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/dec_modes.dart#L36) | 3 | Blinking underline |
| `cursorStyleSteadyUnderline` | [L39](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/dec_modes.dart#L39) | 4 | Steady underline |
| `cursorStyleBlinkingBar` | [L42](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/dec_modes.dart#L42) | 5 | Blinking bar |
| `cursorStyleSteadyBar` | [L45](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/dec_modes.dart#L45) | 6 | Steady bar |
| `eraseDisplayBelow` | [L48](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/dec_modes.dart#L48) | 0 | Erase below |
| `eraseDisplayAbove` | [L51](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/dec_modes.dart#L51) | 1 | Erase above |
| `eraseDisplayAll` | [L54](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/dec_modes.dart#L54) | 2 | Erase all |
| `eraseDisplaySaved` | [L57](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/dec_modes.dart#L57) | 3 | Erase scrollback |
| `eraseLineRight` | [L60](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/dec_modes.dart#L60) | 0 | Erase right |
| `eraseLineLeft` | [L63](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/dec_modes.dart#L63) | 1 | Erase left |
| `eraseLineAll` | [L66](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/dec_modes.dart#L66) | 2 | Erase line |

#### `KittyCodes` — [protocol/kitty_codes.dart#L2](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/kitty_codes.dart#L2)

**What:** [Kitty keyboard protocol](https://sw.kovidgoyal.net/kitty/keyboard-protocol/) constants and key code mappings.

| Member | Line | Value | Description |
|--------|------|-------|-------------|
| `kittyDisambiguate` | [L6](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/kitty_codes.dart#L6) | 1 | Disambiguate flag |
| `kittyKeyEscape` | [L9](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/kitty_codes.dart#L9) | `0x1B` | Escape |
| `kittyKeyTab` | [L12](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/kitty_codes.dart#L12) | `0x09` | Tab |
| `kittyKeyEnter` | [L15](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/kitty_codes.dart#L15) | `0x0D` | Enter |
| `kittyKeyBackspace` | [L18](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/kitty_codes.dart#L18) | `0x08` | Backspace |
| `kittyKeyBackspaceAlt` | [L21](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/kitty_codes.dart#L21) | `0x7F` | Alt backspace |
| `kittyKeyHome` | [L24](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/kitty_codes.dart#L24) | `0x01` | Home |
| `kittyKeyEnd` | [L27](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/kitty_codes.dart#L27) | `0x04` | End |
| `kittyKeyPageUp` | [L30](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/kitty_codes.dart#L30) | `0x05` | Page Up |
| `kittyKeyPageDown` | [L33](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/kitty_codes.dart#L33) | `0x06` | Page Down |
| `kittyKeyInsert` | [L36](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/kitty_codes.dart#L36) | `0x02` | Insert |
| `kittyKeyDelete` | [L39](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/kitty_codes.dart#L39) | `0x03` | Delete |
| `kittyKeyDeleteAlt` | [L42](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/kitty_codes.dart#L42) | `0x1A` | Alt delete |
| `csiFinalKittyKey` | [L45](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/kitty_codes.dart#L45) | `0x75` | 'u' final byte |

#### `WidgetChars` — [protocol/widget_chars.dart#L2](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/widget_chars.dart#L2)

**What:** Box-drawing glyphs, border sets, and UI character constants.

| Member | Line | Description |
|--------|------|-------------|
| `charFullBlock` | [L6](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/widget_chars.dart#L6) | Full block solid fill |
| `charLightShade` | [L9](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/widget_chars.dart#L9) | Light shade partial fill |
| `charBullet` | [L12](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/widget_chars.dart#L12) | Bullet |
| `charCheckMark` | [L15](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/widget_chars.dart#L15) | Check mark |
| `charRightTriangle` | [L18](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/widget_chars.dart#L18) | Right triangle sort indicator |
| `charUpTriangle` | [L21](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/widget_chars.dart#L21) | Up triangle sort indicator |
| `charDownTriangle` | [L24](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/widget_chars.dart#L24) | Down triangle sort indicator |
| `borderSingle` | [L27](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/widget_chars.dart#L27) | Single-line border chars |
| `borderDouble` | [L30](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/widget_chars.dart#L30) | Double-line border chars |
| `borderRounded` | [L33](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/widget_chars.dart#L33) | Rounded-corner border chars |
| `borderThick` | [L36](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/widget_chars.dart#L36) | Heavy/thick border chars |

#### `GraphemeProperties` — [protocol/grapheme_properties.dart#L3](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/grapheme_properties.dart#L3)

**What:** [Grapheme break](https://unicode.org/reports/tr29/) property constants and character width sentinels.

| Member | Line | Value | Description |
|--------|------|-------|-------------|
| `graphemePropZwj` | [L7](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/grapheme_properties.dart#L7) | 1 | Zero-width joiner |
| `graphemePropVariationSelector` | [L10](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/grapheme_properties.dart#L10) | 2 | Variation selector |
| `graphemePropRegionalIndicator` | [L13](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/grapheme_properties.dart#L13) | 3 | Regional indicator |
| `graphemePropCombiningMark` | [L16](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/grapheme_properties.dart#L16) | 4 | Combining mark |
| `graphemePropEmojiModifier` | [L19](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/grapheme_properties.dart#L19) | 5 | Emoji modifier |
| `graphemePropTag` | [L22](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/grapheme_properties.dart#L22) | 6 | Tag sequence |
| `graphemePropHangulLeading` | [L25](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/grapheme_properties.dart#L25) | 7 | Hangul choseong |
| `graphemePropHangulVowel` | [L28](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/grapheme_properties.dart#L28) | 8 | Hangul jungseong |
| `graphemePropHangulTrailing` | [L31](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/grapheme_properties.dart#L31) | 9 | Hangul jongseong |
| `graphemePropExtendedPictographic` | [L34](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/grapheme_properties.dart#L34) | 10 | Extended pictographic |
| `graphemePropInvisible` | [L37](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/grapheme_properties.dart#L37) | 11 | Invisible character |
| `wideCharWidth` | [L40](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/grapheme_properties.dart#L40) | 2 | Wide char sentinel |
| `zeroCharWidth` | [L43](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/grapheme_properties.dart#L43) | 0 | Zero-width sentinel |

#### `TimingDefaults` — [protocol/timing_defaults.dart#L2](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/timing_defaults.dart#L2)

| Member | Line | Value | Description |
|--------|------|-------|-------------|
| `defaultProbeTimeout` | [L6](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/timing_defaults.dart#L6) | 1s | Capability probe timeout |
| `spinnerAnimInterval` | [L9](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/timing_defaults.dart#L9) | 80ms | Spinner frame rate |
| `progressAnimInterval` | [L12](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/timing_defaults.dart#L12) | 100ms | Progress frame rate |
| `cursorBlinkInterval` | [L15](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/timing_defaults.dart#L15) | 500ms | Cursor blink rate |

#### `SizeDefaults` — [protocol/size_defaults.dart#L2](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/size_defaults.dart#L2)

| Member | Line | Value | Description |
|--------|------|-------|-------------|
| `defaultTerminalWidth` | [L6](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/size_defaults.dart#L6) | 80 | Default columns |
| `defaultTerminalHeight` | [L9](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/size_defaults.dart#L9) | 24 | Default rows |
| `defaultViewportHeight` | [L12](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/size_defaults.dart#L12) | 10 | Scrollable viewport |
| `defaultScrollStep` | [L15](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/size_defaults.dart#L15) | 3 | Lines per scroll |
| `defaultProgressBarWidth` | [L18](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/size_defaults.dart#L18) | 20 | Progress bar cells |
| `scrollbarMinViewportHeight` | [L21](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/size_defaults.dart#L21) | 2 | Min scrollbar height |
| `unbounded` | [L24](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/size_defaults.dart#L24) | `0x7FFFFFFF` | Unbounded sentinel |

#### `UnicodeCodepoints` — [protocol/unicode_codepoints.dart#L3](https://github.com/iapicca/t22e/blob/no_ffi/packages/protocol/lib/src/unicode_codepoints.dart#L3)

**What:** Individual Unicode codepoint constants for control characters, whitespace, bidi formatting, and formatting marks.
**How:** Non-instantiable final class with 21 static constants covering space, DEL, ideographic space, ZWJ, soft hyphen, Arabic format char, Mongolian vowel separator, en-quad range, line/paragraph separators, bidi overrides, word joiners, bidi isolates, and BOM/ZWNBSP.

---

### Unicode

#### `UnicodeRanges` — [unicode/unicode_ranges.dart#L2](https://github.com/iapicca/t22e/blob/no_ffi/packages/unicode/lib/src/unicode_ranges.dart#L2)

**What:** Unicode codepoint range boundary constants for grapheme break classification.
**How:** Non-instantiable final class with 28 static constants defining start/end boundaries for variation selectors, regional indicators, combining diacritical marks, emoji modifiers, tag codepoints, Hangul Jamo, and extended pictographics.

#### `UnicodeTable` — [unicode/tables.dart#L14](https://github.com/iapicca/t22e/blob/no_ffi/packages/unicode/lib/src/tables.dart#L14)

**What:** Defines the Unicode lookup table structure: bit masks, flag values, and well-known codepoint ranges.
**How:** Non-instantiable final class. `wellKnownCodepointRanges` is a `List<UnicodeWidthProperty>` that maps codepoint ranges to property bytes encoding width, emoji, printable, and private-use flags.

| Member | Line | Description |
|--------|------|-------------|
| `maxCodepoint` | [L17](https://github.com/iapicca/t22e/blob/no_ffi/packages/unicode/lib/src/tables.dart#L17) | `0x10FFFF` |
| `tableLength` | [L18](https://github.com/iapicca/t22e/blob/no_ffi/packages/unicode/lib/src/tables.dart#L18) | `maxCodepoint + 1` |
| `widthMask` | [L20](https://github.com/iapicca/t22e/blob/no_ffi/packages/unicode/lib/src/tables.dart#L20) | `0x03` - width bits |
| `emojiFlag` | [L21](https://github.com/iapicca/t22e/blob/no_ffi/packages/unicode/lib/src/tables.dart#L21) | `0x04` |
| `printableFlag` | [L22](https://github.com/iapicca/t22e/blob/no_ffi/packages/unicode/lib/src/tables.dart#L22) | `0x08` |
| `privateUseFlag` | [L23](https://github.com/iapicca/t22e/blob/no_ffi/packages/unicode/lib/src/tables.dart#L23) | `0x10` |
| `width0NotPrintable` | [L25](https://github.com/iapicca/t22e/blob/no_ffi/packages/unicode/lib/src/tables.dart#L25) | `0x00` |
| `width1Printable` | [L26](https://github.com/iapicca/t22e/blob/no_ffi/packages/unicode/lib/src/tables.dart#L26) | `0x09` |
| `width2Printable` | [L27](https://github.com/iapicca/t22e/blob/no_ffi/packages/unicode/lib/src/tables.dart#L27) | `0x0A` |
| `width2PrintableEmoji` | [L28](https://github.com/iapicca/t22e/blob/no_ffi/packages/unicode/lib/src/tables.dart#L28) | `0x0E` |
| `width1PrintablePrivateUse` | [L29](https://github.com/iapicca/t22e/blob/no_ffi/packages/unicode/lib/src/tables.dart#L29) | `0x19` |
| `wellKnownCodepointRanges` | [L31](https://github.com/iapicca/t22e/blob/no_ffi/packages/unicode/lib/src/tables.dart#L31) | Full range list |

#### `UnicodeWidthProperty` — [unicode/tables.dart#L3](https://github.com/iapicca/t22e/blob/no_ffi/packages/unicode/lib/src/tables.dart#L3)

**What:** Extension type wrapping a `(int start, int end, int width)` record for Unicode range entries.
**How:** Provides `start`, `end`, `width` getters over the underlying record.

#### `UnicodeLookup` — [unicode/tables.dart#L258](https://github.com/iapicca/t22e/blob/no_ffi/packages/unicode/lib/src/tables.dart#L258)

**What:** O(1) lookup table for character width, emoji, printability, and private-use status.
**How:** Builds a flat `Uint8List` of size `tableLength` at initialization from `wellKnownCodepointRanges`. Each codepoint's property byte is stamped into the array. Queries mask/flag the byte.

| Member | Line | Description |
|--------|------|-------------|
| `charWidth(int codepoint)` | [L285](https://github.com/iapicca/t22e/blob/no_ffi/packages/unicode/lib/src/tables.dart#L285) | Display width |
| `isEmoji(int codepoint)` | [L288](https://github.com/iapicca/t22e/blob/no_ffi/packages/unicode/lib/src/tables.dart#L288) | Emoji check |
| `isPrintable(int codepoint)` | [L291](https://github.com/iapicca/t22e/blob/no_ffi/packages/unicode/lib/src/tables.dart#L291) | Printable check |
| `isPrivateUse(int codepoint)` | [L294](https://github.com/iapicca/t22e/blob/no_ffi/packages/unicode/lib/src/tables.dart#L294) | PUA check |
| `isAmbiguousWidth(int codepoint)` | [L297](https://github.com/iapicca/t22e/blob/no_ffi/packages/unicode/lib/src/tables.dart#L297) | Ambiguous width check |

#### Unicode public functions — [unicode/width.dart](https://github.com/iapicca/t22e/blob/no_ffi/packages/unicode/lib/src/width.dart) and [unicode/grapheme.dart](https://github.com/iapicca/t22e/blob/no_ffi/packages/unicode/lib/src/grapheme.dart)

| Function | Line | Description |
|----------|------|-------------|
| `charWidth` | [width.dart#L5](https://github.com/iapicca/t22e/blob/no_ffi/packages/unicode/lib/src/width.dart#L5) | Display column width of a codepoint |
| `isWide` | [width.dart#L8](https://github.com/iapicca/t22e/blob/no_ffi/packages/unicode/lib/src/width.dart#L8) | CJK wide character check |
| `isZeroWidth` | [width.dart#L12](https://github.com/iapicca/t22e/blob/no_ffi/packages/unicode/lib/src/width.dart#L12) | Zero-width check |
| `isEmoji` | [width.dart#L16](https://github.com/iapicca/t22e/blob/no_ffi/packages/unicode/lib/src/width.dart#L16) | Emoji classification |
| `isPrintable` | [width.dart#L19](https://github.com/iapicca/t22e/blob/no_ffi/packages/unicode/lib/src/width.dart#L19) | Printability check |
| `isPrivateUse` | [width.dart#L22](https://github.com/iapicca/t22e/blob/no_ffi/packages/unicode/lib/src/width.dart#L22) | PUA check |
| `isAmbiguousWidth` | [width.dart#L25](https://github.com/iapicca/t22e/blob/no_ffi/packages/unicode/lib/src/width.dart#L25) | Ambiguous width check |
| `stringWidth` | [width.dart#L28](https://github.com/iapicca/t22e/blob/no_ffi/packages/unicode/lib/src/width.dart#L28) | Total display width of a string |
| `graphemeClusters` | [grapheme.dart#L84](https://github.com/iapicca/t22e/blob/no_ffi/packages/unicode/lib/src/grapheme.dart#L84) | Segment string into [grapheme clusters](https://unicode.org/reports/tr29/) |
| `stringWidthGrapheme` | [grapheme.dart#L123](https://github.com/iapicca/t22e/blob/no_ffi/packages/unicode/lib/src/grapheme.dart#L123) | Total width via grapheme clusters |
| `truncate` | [grapheme.dart#L129](https://github.com/iapicca/t22e/blob/no_ffi/packages/unicode/lib/src/grapheme.dart#L129) | Truncate string to max display width |

#### `GraphemeCluster` (typedef) — [unicode/grapheme.dart#L7](https://github.com/iapicca/t22e/blob/no_ffi/packages/unicode/lib/src/grapheme.dart#L7)

**What:** A record typedef `({int start, int end, int columnWidth})` describing a grapheme cluster as a rune index range and its display column width.

---

## renderer

> Merges the old **capability**, **terminal**, **renderer**, and **parser** packages.

### Capabilities

#### `KeyboardProtocol` — [capability/capabilities.dart#L11](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/capabilities.dart#L11)

**What:** Enum representing keyboard protocol support level.
**How:** Two values: `basic` (standard terminal keyboard) and `kitty` ([Kitty keyboard protocol](https://sw.kovidgoyal.net/kitty/keyboard-protocol/) support).

#### `Capabilities` — [capability/capabilities.dart#L15](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/capabilities.dart#L15)

**What:** Freezed data class holding the complete set of terminal capabilities gathered by the probing pipeline.
**How:** Aggregates DA1 query result, color profile, sync support, keyboard protocol, and terminal dimensions. `Capabilities.defaults()` provides safe fallback values.

| Member | Line | Description |
|--------|------|-------------|
| `factory Capabilities({da1, colorProfile, syncSupported, keyboardProtocol, rows, cols})` | [L18](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/capabilities.dart#L18) | Primary constructor |
| `factory Capabilities.defaults()` | [L28](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/capabilities.dart#L28) | Safe default values |

#### `Da1Query` — [capability/da1_query.dart#L2](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/da1_query.dart#L2)

**What:** Sealed class representing the result of a DA1 (primary device attributes) capability query.
**How:** Two variants: `Da1Value` (terminal responded with ID and attributes) and `Da1QueryUnsupported` (no response or unsupported). Provides a `when` method for exhaustive pattern matching.

| Factory | Line | Description |
|---------|------|-------------|
| `Da1Query.supported(int terminalId, List<int> attributes)` | [L5](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/da1_query.dart#L5) | Successful DA1 response |
| `Da1Query.unsupported()` | [L7](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/da1_query.dart#L7) | No response / unsupported |

#### `Da1Value` — [capability/da1_query.dart#L24](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/da1_query.dart#L24)

**What:** Concrete class representing a successful DA1 response.
**How:** Holds `terminalId` (int) and `attributes` (List<int>). Custom equality compares both fields structurally.

| Member | Line | Description |
|--------|------|-------------|
| `Da1Value(this.terminalId, this.attributes)` | [L25](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/da1_query.dart#L25) | Constructor |
| `int terminalId` | [L27](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/da1_query.dart#L27) | Terminal ID code |
| `List<int> attributes` | [L28](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/da1_query.dart#L28) | Feature attribute codes |

#### `Da1QueryUnsupported` — [capability/da1_query.dart#L42](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/da1_query.dart#L42)

**What:** Concrete class representing an unsupported DA1 query.
**How:** Empty class with identity-based equality.

#### `Da1Codes` — [capability/da1_codes.dart#L2](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/da1_codes.dart#L2)

**What:** DA1 terminal identification and feature attribute constants.

| Member | Line | Value | Description |
|--------|------|-------|-------------|
| `da1TerminalIdDefault` | [L6](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/da1_codes.dart#L6) | 0 | Default terminal ID |
| `da1AttrIndexed256` | [L9](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/da1_codes.dart#L9) | 22 | 256-color support |
| `da1AttrTrueColor` | [L12](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/da1_codes.dart#L12) | 28 | Truecolor support |

#### `Environment` — [capability/environment.dart#L3](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/environment.dart#L3)

**What:** Environment variable keys and recognized value constants for terminal capability detection.

| Member | Line | Value | Description |
|--------|------|-------|-------------|
| `envColortermTruecolor` | [L7](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/environment.dart#L7) | `'truecolor'` | COLORTERM truecolor |
| `envColorterm24bit` | [L10](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/environment.dart#L10) | `'24bit'` | COLORTERM 24-bit |
| `envTermSuffix256Color` | [L13](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/environment.dart#L13) | `'-256color'` | TERM suffix |
| `envTermSuffixTrueColor` | [L16](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/environment.dart#L16) | `'-truecolor'` | TERM suffix |
| `envTermSuffixDirect` | [L19](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/environment.dart#L19) | `'-direct'` | TERM suffix |
| `envKeyColorterm` | [L22](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/environment.dart#L22) | `'COLORTERM'` | Env key |
| `envKeyTerm` | [L25](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/environment.dart#L25) | `'TERM'` | Env key |

#### `SystemIoProbeExtension` — [capability/system_io_probe_extension.dart#L12](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/system_io_probe_extension.dart#L12)

**What:** Extension on `SystemIo` providing a generic terminal capability probing method.
**How:** `probeTerminal<T, R>(...)` sends a query string, waits for a matching parser event of type `T` within a timeout, and returns the result transformed by `onEvent`. Falls back to `onTimeout()` on `TimeoutException`. An optional `where` predicate filters events.

---

### Probes

#### `detectColorFromEnv` — [capability/color_probe.dart#L14](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/color_probe.dart#L14)

**What:** Detects color profile from `COLORTERM` and `TERM` environment variables.
**How:** Returns `trueColor` if COLORTERM is "truecolor"/"24bit" or TERM ends with "-truecolor"/"-direct"; `indexed256` if TERM ends with "-256color"; otherwise `ansi16`. Marked `@internal`.

#### `detectColorFromDa1` — [capability/color_probe.dart#L34](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/color_probe.dart#L34)

**What:** Detects color profile from a DA1 response's attribute list.
**How:** Returns `trueColor` if attribute 28 is present, `indexed256` if attribute 22 is present, otherwise `ansi16`. Marked `@internal`.

#### `probeColor` — [capability/color_probe.dart#L49](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/color_probe.dart#L49)

**What:** Full color probe pipeline.
**How:** First checks env (short-circuits if trueColor), then sends an OSC foreground-color query to the terminal, and falls back to DA1-based detection on timeout. Marked `@internal`.

#### `probeSync` — [capability/sync_probe.dart#L11](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/sync_probe.dart#L11)

**What:** Probes for synchronized update support (DECRPM / DEC 2026).
**How:** Sends the query and checks for a `QuerySyncUpdateEvent`. Returns `true` if supported, `false` on timeout. Marked `@internal`.

#### `probeKeyboard` — [capability/keyboard_probe.dart#L12](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/keyboard_probe.dart#L12)

**What:** Probes for Kitty keyboard protocol support.
**How:** Sends an enable+query sequence. Returns `KeyboardProtocol.kitty` if the terminal responds with enhancement flags, or `KeyboardProtocol.basic` on timeout (and sends a disable sequence). Marked `@internal`.

#### `probeDa1` — [capability/da1_probe.dart#L13](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/da1_probe.dart#L13)

**What:** Probes for primary device attributes (DA1).
**How:** Sends `CSI c`. Parses the `PrimaryDeviceAttributesEvent` into a `Da1Query.supported(id, attributes)` or returns `Da1Query.unsupported()` on timeout. Marked `@internal`.

#### Probe typedefs — [capability/probe_definitions.dart](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/probe_definitions.dart)

| Typedef | Line | Description |
|---------|------|-------------|
| `SyncProbe` | [L6](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/probe_definitions.dart#L6) | `Future<bool>` |
| `KeyboardProbe` | [L8](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/probe_definitions.dart#L8) | `Future<KeyboardProtocol>` |
| `Da1Probe` | [L10](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/probe_definitions.dart#L10) | `Future<Da1Query>` |
| `ColorProbe` | [L12](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/probe_definitions.dart#L12) | `Future<ColorProfile>` |

---

### Terminal I/O

#### `OperatingSystem` — [terminal/operating_system.dart#L2](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/operating_system.dart#L2)

**What:** Platform identifiers for terminal capability selection.
**How:** Enum with values: `macOS`, `linux`.

#### `SystemContext` — [terminal/system_context.dart#L10](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/system_context.dart#L10)

**What:** Freezed data class capturing terminal environment and dimensions at initialization time.
**How:** Holds `width`, `height`, `hasTerminal`, `operatingSystem`, and `environment` map. Exposed through `ValueNotifier` for live resize detection.

#### `SystemIo` (mixin) — [terminal/system_io.dart#L11](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/system_io.dart#L11)

**What:** Core I/O abstraction with access to terminal context.
**How:** Defines `inputStream` (raw byte stream), `write(String)`, `flush()`, and `context` (live-updated `ValueNotifier<SystemContext>`). Designed to be mixed into classes that provide terminal I/O.

| Member | Line | Description |
|--------|------|-------------|
| `Stream<List<int>> get inputStream` | [L13](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/system_io.dart#L13) | Raw input byte stream |
| `void write(String data)` | [L16](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/system_io.dart#L16) | Write to stdout |
| `Future<void> flush()` | [L19](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/system_io.dart#L19) | Flush stdout |
| `ValueNotifier<SystemContext> get context` | [L22](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/system_io.dart#L22) | Live terminal context |

#### `TerminalIo` — [terminal/terminal_io.dart#L16](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/terminal_io.dart#L16)

**What:** Concrete implementation of `SystemIo` using libc FFI for writing and native signal handling for SIGWINCH resize detection.
**How:** Uses `InitMixin` and `Disposable`. `init()` initializes FFI lookups, creates `SystemContext`, sets up SIGWINCH handler via `sigaction`, and creates a broadcast stdin controller. `write()` UTF-8 encodes data, allocates a native buffer, copies bytes, calls libc `write`, then frees the buffer. `dispose()` tears down SIGWINCH handler, cancels stdin subscription, and closes stream controller.

| Member | Line | Description |
|--------|------|-------------|
| `TerminalIo({required _libc})` | [L29](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/terminal_io.dart#L29) | Constructor |
| `init({String? message, bool throwIfExists})` | [L32](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/terminal_io.dart#L32) | Initialize FFI + SIGWINCH + stdin |
| `void write(String data)` | [L75](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/terminal_io.dart#L75) | FFI write |
| `Future<void> flush()` | [L86](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/terminal_io.dart#L86) | No-op flush |
| `void dispose({String? message})` | [L130](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/terminal_io.dart#L130) | Tear down everything |

---

### Raw Mode

#### `RawModeState` — [terminal/raw_mode_state.dart#L9](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/raw_mode_state.dart#L9)

**What:** Freezed data class capturing saved termios state before entering raw mode.
**How:** Holds the termios buffer pointer and all four flag field snapshots (input, output, control, local).

#### `RawModeInterface` — [terminal/raw_mode.dart#L10](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/raw_mode.dart#L10)

**What:** Abstract base for raw mode lifecycle management.
**How:** Extends `ValueNotifier<RawModeState?>` with `InitMixin`. Consumers can listen to state changes.

#### `RawMode` — [terminal/raw_mode.dart#L20](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/raw_mode.dart#L20)

**What:** Concrete `RawModeInterface` implementation using libc FFI.
**How:** `init()` enters raw mode: allocates buffer, reads current termios, saves state, clears ECHO/ICANON/ISIG/IEXTEN flags, sets VMIN=1/VTIME=0, applies changes. `dispose()` restores saved termios state and frees the buffer. Marked `@internal`.

#### `Termios` — [terminal/termios.dart#L4](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/termios.dart#L4)

**What:** Abstract base class defining termios structure flags, offsets, and raw mode configuration constants.
**How:** Platform-specific subclasses (`LinuxTermios`, `MacosTermios`) supply actual byte offsets and struct sizes. Defines flag constants (ECHO, ICANON, ISIG, IEXTEN), VMIN/VTIME values, and abstract getters for struct layout.

| Member | Line | Description |
|--------|------|-------------|
| `termiosEcho` | [L8](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/termios.dart#L8) | `0x00000008` |
| `termiosICanon` | [L11](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/termios.dart#L11) | `0x00000002` |
| `termiosISig` | [L14](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/termios.dart#L14) | `0x00000001` |
| `termiosIExten` | [L17](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/termios.dart#L17) | `0x00008000` |
| `termiosVminRaw` | [L20](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/termios.dart#L20) | `1` |
| `termiosVtimeRaw` | [L23](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/termios.dart#L23) | `0` |
| `tcsaNow` | [L26](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/termios.dart#L26) | `0` |
| `stdinFd` | [L29](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/termios.dart#L29) | `0` |

#### `LinuxTermios` — [terminal/termios_linux.dart#L7](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/termios_linux.dart#L7)

**What:** Linux termios layout implementation (tcflag_t = 4 bytes, struct = 60 bytes).
**How:** Final class extending `Termios`. Overrides struct size, flag offsets, and read/write methods for 32-bit values.

#### `MacosTermios` — [terminal/termios_macos.dart#L7](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/termios_macos.dart#L7)

**What:** macOS termios layout implementation (tcflag_t = 8 bytes, struct = 72 bytes).
**How:** Final class extending `Termios`. Overrides struct size, flag offsets, and read/write methods for 64-bit values.

---

### FFI

#### `TermiosBindings` — [terminal/termios_bindings.dart#L10](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/termios_bindings.dart#L10)

**What:** Abstract interface for libc FFI calls used to manage terminal raw mode.
**How:** Factory constructor redirects to `_TermiosBindings` which looks up `tcgetattr`, `tcsetattr`, `malloc`, and `free` from a `DynamicLibrary`. Marked `@internal`.

| Member | Line | Description |
|--------|------|-------------|
| `TcGetAttr get tcGetAttr` | [L14](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/termios_bindings.dart#L14) | POSIX tcgetattr |
| `TcSetAttr get tcSetAttr` | [L17](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/termios_bindings.dart#L17) | POSIX tcsetattr |
| `Pointer<Uint8> malloc(int size)` | [L20](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/termios_bindings.dart#L20) | C malloc |
| `void free(Pointer<Uint8> ptr)` | [L23](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/termios_bindings.dart#L23) | C free |

#### `SymbolsFFI` — [terminal/symbols_ffi.dart#L2](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/symbols_ffi.dart#L2)

**What:** Central repository of FFI symbol name constants.

| Member | Line | Description |
|--------|------|-------------|
| `tcGetAttrName` | [L8](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/symbols_ffi.dart#L8) | `'tcgetattr'` |
| `tcSetAttrName` | [L11](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/symbols_ffi.dart#L11) | `'tcsetattr'` |
| `mallocName` | [L14](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/symbols_ffi.dart#L14) | `'malloc'` |
| `freeName` | [L17](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/symbols_ffi.dart#L17) | `'free'` |
| `libcMacOS` | [L22](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/symbols_ffi.dart#L22) | `'libSystem.dylib'` |
| `libcLinux6` | [L25](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/symbols_ffi.dart#L25) | `'libc.so.6'` |
| `libcMuslX86` | [L28](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/symbols_ffi.dart#L28) | musl x86_64 |
| `libcMuslAarch64` | [L31](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/symbols_ffi.dart#L31) | musl aarch64 |

#### `PointerUint8Ops` (extension on `Pointer<Uint8>`) — [terminal/pointer_extensions.dart#L8](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/pointer_extensions.dart#L8)

**What:** Byte-level read/write helpers for FFI `Pointer<Uint8>`.
**How:** Provides `read32`, `write32`, `read64`, `write64`, and `write8` methods for little-endian integer operations at arbitrary offsets. Marked `@internal`.

#### `DynamicLibraryFfi` (extension on `DynamicLibrary`) — [terminal/libc_provider.dart#L14](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/libc_provider.dart#L14)

**What:** Extension on `DynamicLibrary` providing FFI memory helpers.
**How:** `freePointer(Pointer<Void> ptr)` releases memory via libc `free`. Marked `@internal`.

#### `openLibc()` — [terminal/libc_provider.dart#L23](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/libc_provider.dart#L23)

**What:** Opens the appropriate libc `DynamicLibrary` for the current platform.
**How:** Returns `libSystem.dylib` on macOS, tries `libc.so.6`, musl x86, musl aarch64 on Linux. Throws `UnsupportedError` on other platforms.

#### FFI typedefs — [terminal/libc_signatures.dart](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/libc_signatures.dart) and [terminal/signal_bindings.dart](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/signal_bindings.dart)

| Typedef | Line | Description |
|---------|------|-------------|
| `NativeTcGetAttr` | [libc_signatures.dart#L9](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/libc_signatures.dart#L9) | Native C FFI signature for tcgetattr |
| `TcGetAttr` | [libc_signatures.dart#L14](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/libc_signatures.dart#L14) | Dart callable signature for tcgetattr |
| `NativeTcSetAttr` | [libc_signatures.dart#L19](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/libc_signatures.dart#L19) | Native C FFI signature for tcsetattr |
| `TcSetAttr` | [libc_signatures.dart#L28](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/libc_signatures.dart#L28) | Dart callable signature for tcsetattr |
| `NativeMalloc` | [libc_signatures.dart#L37](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/libc_signatures.dart#L37) | Native C FFI signature for malloc |
| `Malloc` | [libc_signatures.dart#L41](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/libc_signatures.dart#L41) | Dart callable signature for malloc |
| `NativeWrite` | [libc_signatures.dart#L45](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/libc_signatures.dart#L45) | Native C FFI signature for write |
| `DartWrite` | [libc_signatures.dart#L50](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/libc_signatures.dart#L50) | Dart callable signature for write |
| `NativeFree` | [libc_signatures.dart#L54](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/libc_signatures.dart#L54) | Native C FFI signature for free |
| `Free` | [libc_signatures.dart#L58](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/libc_signatures.dart#L58) | Dart callable signature for free |
| `NativeSigaction` | [signal_bindings.dart#L4](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/signal_bindings.dart#L4) | Native C FFI signature for sigaction |
| `DartSigaction` | [signal_bindings.dart#L8](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/signal_bindings.dart#L8) | Dart-facing signature for sigaction |

---

### Rendering

#### `Frame` — [renderer/frame.dart#L8](https://github.com/iapicca/t22e/blob/no_ffi/packages/renderer/lib/src/frame.dart#L8)

**What:** Freezed data class representing a rendered frame with plain lines, styled ANSI lines, and an optional cell grid.
**How:** `Frame.fromSurface(Surface)` extracts plain and ANSI lines from a surface. `height` returns the row count.

| Member | Line | Description |
|--------|------|-------------|
| `Frame(List<String> plainLines, List<String> styledLines, {CellGrid cells})` | [L11](https://github.com/iapicca/t22e/blob/no_ffi/packages/renderer/lib/src/frame.dart#L11) | Primary constructor |
| `Frame.fromSurface(Surface surface, {bool includeCells})` | [L18](https://github.com/iapicca/t22e/blob/no_ffi/packages/renderer/lib/src/frame.dart#L18) | From surface |
| `int get height` | [L26](https://github.com/iapicca/t22e/blob/no_ffi/packages/renderer/lib/src/frame.dart#L26) | Row count |

#### `FrameLine` — [renderer/frame.dart#L29](https://github.com/iapicca/t22e/blob/no_ffi/packages/renderer/lib/src/frame.dart#L29)

**What:** Extension type wrapping a `({String plain, String styled})` record for a single frame line.
**How:** Provides `plain` and `styled` getters.

#### `FrameLineFromRow` (extension on `Frame`) — [renderer/frame.dart#L34](https://github.com/iapicca/t22e/blob/no_ffi/packages/renderer/lib/src/frame.dart#L34)

**What:** Convenience method to extract a `FrameLine` at a given row index.
**How:** `frameLine(int row)` returns a `FrameLine` for the given row, or empty strings if out of bounds.

#### `DiffResult` — [renderer/diff_result.dart#L6](https://github.com/iapicca/t22e/blob/no_ffi/packages/renderer/lib/src/diff_result.dart#L6)

**What:** Extension type on `List<int>` representing changed row indices between two frames.
**How:** `DiffResult.fromFrames(previous, current)` compares frames row-by-row and returns indices of differing rows. `hasChanges` checks if any rows changed.

#### `SyncRenderer` — [renderer/sync_renderer.dart#L7](https://github.com/iapicca/t22e/blob/no_ffi/packages/renderer/lib/src/sync_renderer.dart#L7)

**What:** Wraps line-based rendering with DEC synchronized update markers when supported.
**How:** `render(DiffResult diff, Frame currentFrame)` renders changed lines via `LineRenderer`, then wraps output with ANSI sync start/end markers if `syncSupported` is true.

#### `LineRenderer` — [renderer/line_renderer.dart#L6](https://github.com/iapicca/t22e/blob/no_ffi/packages/renderer/lib/src/line_renderer.dart#L6)

**What:** Renders changed lines using cursor-positioned ANSI output.
**How:** `render(DiffResult diff, Frame currentFrame)` iterates over changed row indices, emits ANSI cursor-move followed by the styled line for each changed row.

#### `cellRrender` — [renderer/cell_renderer.dart#L10](https://github.com/iapicca/t22e/blob/no_ffi/packages/renderer/lib/src/cell_renderer.dart#L10)

**What:** Per-cell diff renderer producing minimal ANSI output.
**How:** Diffs individual cells between previous and current frames. Skips unchanged and wide-continuation cells. Emits SGR style sequences and cursor-positioned character output for changed cells only. (Note: function name contains a typo - double "r".)

---

### Parser Engine

#### `VtState` — [parser/vt_state.dart#L2](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/vt_state.dart#L2)

**What:** [VT500](https://vt100.net/docs/vt510-rm/chapter4.html) state machine states for byte-level parsing.
**How:** Enum with 13 values: `ground`, `escape`, `escapeIntermediate`, `csiEntry`, `csiParam`, `csiIntermediate`, `csiIgnore`, `oscString`, `dcsEntry`, `dcsParam`, `dcsIntermediate`, `dcsIgnore`, `dcsPassthrough`.

#### `Vt500Engine` — [parser/engine.dart#L9](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/engine.dart#L9)

**What:** VT500-compatible byte-level state machine engine.
**How:** Extends `ValueNotifier<VtState>` with `InitMixin`. Processes raw bytes via `advance(int b)` which returns parsed `SequenceData` or null. `advanceAll(List<int> bytes)` feeds multiple bytes and collects all parsed data. `reset()` returns to initial state. Internal state includes parameter accumulators, intermediate buffers, OSC/DCS string buffers, and waiting flags.

| Member | Line | Description |
|--------|------|-------------|
| `Vt500Engine()` | [L20](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/engine.dart#L20) | Constructor (ground state) |
| `SequenceData? advance(int b)` | [L23](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/engine.dart#L23) | Feed single byte |
| `List<SequenceData> advanceAll(List<int> bytes)` | [L44](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/engine.dart#L44) | Feed multiple bytes |
| `void reset()` | [L49](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/engine.dart#L49) | Reset to initial state |

#### `TerminalParser` — [parser/terminal_parser.dart#L8](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/terminal_parser.dart#L8)

**What:** VT500-compatible terminal input parser.
**How:** Orchestrates the engine and sub-parsers (CSI, ESC, OSC, DCS) to produce events from raw bytes. `advance(List<int> bytes)` feeds bytes through the engine and interprets each sequence. `reset()` resets the underlying engine.

| Member | Line | Description |
|--------|------|-------------|
| `TerminalParser({_engine, csiParser, escParser, oscParser, dcsParser})` | [L15](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/terminal_parser.dart#L15) | Constructor |
| `List<Event> advance(List<int> bytes)` | [L23](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/terminal_parser.dart#L23) | Parse bytes to events |
| `void reset()` | [L37](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/terminal_parser.dart#L37) | Reset engine |

---

### Parser Events

#### `Event` (sealed) — [parser/events.dart#L9](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/events.dart#L9)

**What:** Base sealed class for all events emitted by the terminal parser.

| Event Class | Line | Description |
|-------------|------|-------------|
| `KeyEvent` | [key_event.dart#L53](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/key_event.dart#L53) | Keyboard input (keyCode, modifiers, type, codepoint) |
| `MouseEvent` | [events.dart#L26](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/events.dart#L26) | Mouse input (button, action, x, y) - freezed |
| `PasteEvent` | [events.dart#L39](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/events.dart#L39) | Bracketed paste (content) |
| `CursorPositionEvent` | [events.dart#L58](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/events.dart#L58) | Cursor position report (row, col) |
| `ColorQueryEvent` | [events.dart#L80](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/events.dart#L80) | Color query response (colorNumber, r, g, b) |
| `PrimaryDeviceAttributesEvent` | [events.dart#L112](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/events.dart#L112) | DA1 response (params) |
| `KeyboardEnhancementFlagsEvent` | [events.dart#L132](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/events.dart#L132) | Kitty keyboard flags |
| `FocusEvent` | [events.dart#L151](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/events.dart#L151) | Focus gained/lost |
| `QuerySyncUpdateEvent` | [events.dart#L170](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/events.dart#L170) | Sync update capability |
| `ClipboardEvent` | [events.dart#L189](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/events.dart#L189) | Clipboard read/write |
| `ErrorEvent` | [events.dart#L214](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/events.dart#L214) | Malformed sequence error |
| `InternalEvent` | [events.dart#L229](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/events.dart#L229) | Internal plumbing event |

#### `KeyModifiers` — [parser/events.dart#L15](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/events.dart#L15)

**What:** Freezed data class with keyboard modifier flags (ctrl, shift, alt, meta).

#### `KeyCode` — [parser/key_event.dart#L4](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/key_event.dart#L4)

**What:** Enum identifying logical keys (arrows, function keys, home, end, etc.).
**How:** 25 values: `none`, `tab`, `enter`, `escape`, `backspace`, `space`, `up`, `down`, `left`, `right`, `home`, `end`, `pageUp`, `pageDown`, `insert`, `delete`, `f1`-`f24`, `char`.

#### `KeyEventType` — [parser/key_event.dart#L49](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/key_event.dart#L49)

**What:** Key event type: `down`, `up`, `repeat`.

#### `MouseButton` — [parser/mouse_event.dart#L4](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/mouse_event.dart#L4)

**What:** Mouse button identifiers: `left`, `middle`, `right`, `none`, `wheelUp`, `wheelDown`.

#### `MouseAction` — [parser/mouse_event.dart#L7](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/mouse_event.dart#L7)

**What:** Mouse action type: `press`, `release`, `move`, `drag`.

---

### Sequence Data

#### `SequenceData` (sealed, freezed) — [parser/sequence_data.dart#L12](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/sequence_data.dart#L12)

**What:** Byte-level parsed sequence data emitted by the VT500 state machine.
**How:** Discriminated union of char, CSI, ESC, OSC, and DCS data.

| Factory | Line | Description |
|---------|------|-------------|
| `SequenceData.char(int codepoint)` | [L13](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/sequence_data.dart#L13) | Single printable character |
| `SequenceData.csi({params, intermediates, finalByte})` | [L14](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/sequence_data.dart#L14) | CSI sequence |
| `SequenceData.esc({intermediates, finalByte})` | [L19](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/sequence_data.dart#L19) | ESC sequence |
| `SequenceData.osc(String content)` | [L23](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/sequence_data.dart#L23) | OSC string |
| `SequenceData.dcs({params, intermediates, finalByte, data})` | [L24](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/sequence_data.dart#L24) | DCS sequence |

#### `Parser` (typedef) — [parser/sequence_data.dart#L8](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/sequence_data.dart#L8)

**What:** `typedef Event? Function(SequenceData)` - function type that converts sequence data into an event.

---

### Sub-parsers

#### `parseCsi` — [parser/csi_parser.dart#L10](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/csi_parser.dart#L10)

**What:** Main CSI sequence parser.
**How:** Dispatches to extended (SGR mouse), Kitty keyboard, or standard CSI handlers based on intermediates and final byte. Handles cursor keys, function keys, tilde-terminated keys, mouse events, and Kitty keyboard protocol sequences.

#### `parseEsc` — [parser/esc_parser.dart#L8](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/esc_parser.dart#L8)

**What:** Parses ESC sequences into events.
**How:** Handles SS3 function keys (F1-F4), terminal reset, cursor save/restore, and scroll reverse.

#### `parseOsc` — [parser/osc_parser.dart#L5](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/osc_parser.dart#L5)

**What:** Parses OSC sequences.
**How:** Handles title changes (OSC 0/1/2), hyperlinks (OSC 8), foreground/background color queries (OSC 10/11), and clipboard (OSC 52).

#### `parseDcs` — [parser/dcs_parser.dart#L8](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/dcs_parser.dart#L8)

**What:** Parses DCS sequences into events.
**How:** Currently handles Kitty graphics transmission ('p') and query ('q') sequences.

---

### Parser Constants

#### `ByteRanges` — [parser/byte_ranges.dart#L2](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/byte_ranges.dart#L2)

**What:** Byte classification range boundaries for the terminal parser.
**How:** Non-instantiable final class with static constants defining C0 control, printable, graphic/intermediate, parameter, digit, uppercase/final, and C1 control byte ranges.

#### `CsiFinals` — [parser/csi_finals.dart#L2](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/csi_finals.dart#L2)

**What:** CSI sequence final bytes for cursor, display, mode, and input events.
**How:** Non-instantiable final class with 19 static constants covering cursor movement (A/B/C/D/H/F/G), erase (J/K), device attributes (c), function keys (P/Q/R/S/~), mouse (M), and extended intermediates.

#### `EscFinals` — [parser/esc_finals.dart#L2](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/esc_finals.dart#L2)

**What:** ESC and SS3 sequence final bytes.
**How:** Non-instantiable final class with 8 static constants for reset, cursor save/restore, scroll reverse, and SS3 function keys.

#### `Modifiers` — [parser/modifiers.dart#L2](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/modifiers.dart#L2)

**What:** Key modifier bitmasks for input events.
**How:** Non-instantiable final class with 4 static constants: `modShift` (1), `modAlt` (2), `modCtrl` (4), `modMeta` (8).

#### `MouseCodes` — [parser/mouse_codes.dart#L2](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/mouse_codes.dart#L2)

**What:** Mouse event parsing constants.
**How:** Non-instantiable final class with 4 static constants: `mouseWheelUpCode` (64), `mouseWheelDownCode` (65), `mouseDragBit` (32), `mouseButtonMask` (3).

#### `DcsCodes` — [parser/dcs_codes.dart#L2](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/dcs_codes.dart#L2)

**What:** DCS (Device Control String) final and intermediate bytes.
**How:** Non-instantiable final class with 3 static constants for Kitty graphics.

#### `InternalEvents` — [parser/internal_events.dart#L2](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/internal_events.dart#L2)

**What:** Internal event kind string constants.
**How:** Non-instantiable final class with 5 static constants: `reset`, `screen_save`, `screen_restore`, `scroll_reverse`, `kitty_graphics`.

---

### Riverpod Providers

#### Terminal package providers

| Provider | Line | Description |
|----------|------|-------------|
| `libc` | [terminal/libc_provider.dart#L52](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/libc_provider.dart#L52) | Returns platform libc `DynamicLibrary` |
| `termiosBindings` | [terminal/termios_bindings_provider.dart#L9](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/termios_bindings_provider.dart#L9) | Creates `TermiosBindings` from libc |
| `termios` | [terminal/termios_provider.dart#L12](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/termios_provider.dart#L12) | Returns platform-appropriate `Termios` |
| `systemIo` | [terminal/system_io_provider.dart#L10](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/system_io_provider.dart#L10) | Creates and manages `TerminalIo` |
| `rawMode` | [terminal/raw_mode_provider.dart#L10](https://github.com/iapicca/t22e/blob/no_ffi/packages/terminal/lib/src/raw_mode_provider.dart#L10) | Creates and manages `RawMode` |

#### Parser package providers

| Provider | Line | Description |
|----------|------|-------------|
| `csiParser` | [parser/csi_parser_provider.dart#L9](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/csi_parser_provider.dart#L9) | Exposes `parseCsi` function |
| `escParser` | [parser/esc_parser_provider.dart#L9](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/esc_parser_provider.dart#L9) | Exposes `parseEsc` function |
| `oscParser` | [parser/osc_parser_provider.dart#L9](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/osc_parser_provider.dart#L9) | Exposes `parseOsc` function |
| `dcsParser` | [parser/dcs_parser_provider.dart#L9](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/dcs_parser_provider.dart#L9) | Exposes `parseDcs` function |
| `vt500Engine` | [parser/engine_provider.dart#L8](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/engine_provider.dart#L8) | Creates `Vt500Engine` |
| `terminalParser` | [parser/terminal_parser_provider.dart#L12](https://github.com/iapicca/t22e/blob/no_ffi/packages/parser/lib/src/terminal_parser_provider.dart#L12) | Assembles `TerminalParser` from sub-providers |

#### Capability package providers

| Provider | Line | Description |
|----------|------|-------------|
| `probeTimeout` | [capability/probe_timeout_provider.dart#L7](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/probe_timeout_provider.dart#L7) | Default probe timeout duration |
| `da1Probe` | [capability/da1_probe_provider.dart#L14](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/da1_probe_provider.dart#L14) | DA1 probe future (keepAlive) |
| `colorProbe` | [capability/color_probe_provider.dart#L15](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/color_probe_provider.dart#L15) | Full color probe future |
| `colorFromEnv` | [capability/color_probe_provider.dart#L25](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/color_probe_provider.dart#L25) | Color from environment only |
| `syncProbe` | [capability/sync_probe_provider.dart#L14](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/sync_probe_provider.dart#L14) | Sync update probe future |
| `keyboardProbe` | [capability/keyboard_probe_provider.dart#L14](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/keyboard_probe_provider.dart#L14) | Kitty keyboard probe future |
| `capabilities` | [capability/capabilities_provider.dart#L14](https://github.com/iapicca/t22e/blob/no_ffi/packages/capability/lib/src/capabilities_provider.dart#L14) | Aggregates all probes into `Capabilities` |

---

## Summary Statistics

| Category | Count |
|----------|-------|
| **Packages** | 11 (core, widgets, notifier, lifecycle, ansi, protocol, unicode, capability, terminal, renderer, parser) |
| **Classes** | ~60 |
| **Enums** | ~12 |
| **Mixins** | 4 (Disposable, InitMixin, SystemIo, + ValueNotifier usage) |
| **Extensions** | ~8 |
| **Extension types** | ~8 |
| **Typedefs** | ~20 |
| **Top-level functions** | ~50 |
| **Riverpod providers** | ~22 |
| **Static constants** | ~200+ |

---

*Generated from branch `no_ffi` of [github.com/iapicca/t22e](https://github.com/iapicca/t22e)*
