import 'cell.dart';
import 'cell_grid.dart' show CellGrid;
import 'color.dart';
import 'geometry.dart';
import 'layout.dart';
import 'style.dart';
import 'package:unicode/unicode.dart' show graphemeClusters;
import 'package:unicode/unicode.dart' show charWidth, stringWidth;
import 'package:protocol/protocol.dart'
    show ControlBytes, GraphemeProperties, WidgetChars;
import 'package:ansi/ansi.dart'
    show bold, dim, italic, underline, blink, reverse, strikethrough, overLine;
import 'package:ansi/ansi.dart' show hyperlink, AnsiDefaults;

/// A grid-based terminal surface for painting text and borders.
class Surface {
  /// Surface dimensions.
  final Size size;

  /// TODO there is no reason to expose size and width direcly can just access Surface.size.width!
  /// Total width in columns.
  int get width => size.width;

  /// Total height in rows.
  int get height => size.height;

  /// Row-major grid of Cell objects.
  final CellGrid grid;

  Surface({required this.size, required this.grid});

  /// Creates a blank surface of the given dimensions.
  factory Surface.genetate(Size size) =>
      Surface(size: size, grid: CellGrid.generate(size));

  /// Creates a surface from an existing grid.
  Surface.fromGrid(this.grid)
    : size = Size(grid.isEmpty ? 0 : grid[0].length, grid.length);

  /// Creates a resized copy, preserving overlapping region.
  Surface._resized(Surface source, int newWidth, int newHeight)
    : size = Size(newWidth, newHeight),
      grid = CellGrid(
        List.generate(
          newHeight,
          (y) => List<Cell>.generate(
            newWidth,
            (x) => y < source.height && x < source.width
                ? source.grid[y][x]
                : const Cell(),
            growable: false,
          ),
          growable: false,
        ),
      );

  /// Returns a new surface with the given dimensions.
  Surface resize(int newWidth, int newHeight) =>
      Surface._resized(this, newWidth, newHeight);

  /// Writes a single character at the given position with style.
  void putChar(int x, int y, String ch, TextStyle style) {
    if (x < 0 || x >= width || y < 0 || y >= height) return;

    grid[y] = List<Cell>.of(grid[y]);

    final cw = ch.runes.isEmpty ? 1 : charWidth(ch.runes.first);
    grid[y][x] = Cell(char: ch, style: style);

    if (cw == GraphemeProperties.wideCharWidth && x + 1 < width) {
      grid[y][x + 1] = const Cell(char: '', wideContinuation: true);
    }
  }

  /// Writes text at the given position, respecting grapheme clusters.
  void putText(int x, int y, String text, TextStyle style) {
    if (x >= width || y >= height || y < 0 || text.isEmpty) return;

    final clusters = graphemeClusters(text);
    var col = x;

    grid[y] = List<Cell>.of(grid[y]);

    for (final cluster in clusters) {
      if (col >= width) break;

      final sub = _substringByCodeUnits(text, cluster.start, cluster.end);

      if (cluster.columnWidth == GraphemeProperties.wideCharWidth) {
        if (col + 1 < width) {
          grid[y][col] = Cell(char: sub, style: style);
          grid[y][col + 1] = const Cell(char: '', wideContinuation: true);
          col += 2;
        } else if (col < width) {
          grid[y][col] = Cell(char: sub, style: style);
          col += 1;
        }
      } else if (cluster.columnWidth > 0) {
        grid[y][col] = Cell(char: sub, style: style);
        col += 1;
      }
    }
  }

  /// Fills a rectangular region with a repeating character.
  void fillRect(int x, int y, int w, int h, String ch, TextStyle style) {
    final rect = Rect(x, y, w, h).intersect(Rect(0, 0, width, height));
    if (rect.isEmpty) return;

    final cw = ch.runes.isEmpty ? 1 : charWidth(ch.runes.first);

    for (var row = rect.top; row < rect.bottom; row++) {
      grid[row] = List<Cell>.of(grid[row]);
      for (var col = rect.left; col < rect.right; col++) {
        grid[row][col] = Cell(char: ch, style: style);
        if (cw == GraphemeProperties.wideCharWidth && col + 1 < rect.right) {
          grid[row][col + 1] = const Cell(char: '', wideContinuation: true);
          col++;
        }
      }
    }
  }

  /// Clears a rectangular region to default blank cells.
  void clearRect(int x, int y, int w, int h) {
    final rect = Rect(x, y, w, h).intersect(Rect(0, 0, width, height));
    if (rect.isEmpty) return;
    for (var row = rect.top; row < rect.bottom; row++) {
      grid[row] = List<Cell>.of(grid[row]);
      for (var col = rect.left; col < rect.right; col++) {
        grid[row][col] = const Cell();
      }
    }
  }

  /// Draws a styled border with optional title on the top edge.
  void drawBorder(
    Rect r, {
    String? borderChars,
    TextStyle? style,
    String? title,
  }) {
    final rect = r.intersect(Rect(0, 0, width, height));
    if (rect.isEmpty || rect.width < 2 || rect.height < 2) return;
    final s = style ?? TextStyle.empty;

    final defaultChars = borderChars ?? WidgetChars.borderSingle;
    final vChar = defaultChars.isNotEmpty
        ? defaultChars[0]
        : WidgetChars.borderSingle[0];
    final hChar = defaultChars.length >= 2
        ? defaultChars[1]
        : WidgetChars.borderSingle[1];
    final tl = defaultChars.length >= 3
        ? defaultChars[2]
        : WidgetChars.borderSingle[2];
    final tr = defaultChars.length >= 4
        ? defaultChars[3]
        : WidgetChars.borderSingle[3];
    final bl = defaultChars.length >= 5
        ? defaultChars[4]
        : WidgetChars.borderSingle[4];
    final br = defaultChars.length >= 6
        ? defaultChars[5]
        : WidgetChars.borderSingle[5];

    final left = rect.left;
    final top = rect.top;
    final right = left + rect.width - 1;
    final bottom = top + rect.height - 1;

    for (var row = top; row <= bottom && row < height; row++) {
      grid[row] = List<Cell>.of(grid[row]);
    }

    grid[top][left] = Cell(char: _s(tl), style: s);
    for (var col = left + 1; col < right && col < width; col++) {
      grid[top][col] = Cell(char: _s(hChar), style: s);
    }
    if (right < width) grid[top][right] = Cell(char: _s(tr), style: s);

    if (bottom < height && bottom > top) {
      grid[bottom][left] = Cell(char: _s(bl), style: s);
      for (var col = left + 1; col < right && col < width; col++) {
        grid[bottom][col] = Cell(char: _s(hChar), style: s);
      }
      if (right < width) grid[bottom][right] = Cell(char: _s(br), style: s);
    }

    for (var row = top + 1; row < bottom && row < height; row++) {
      if (left < width) grid[row][left] = Cell(char: _s(vChar), style: s);
      if (right < width) grid[row][right] = Cell(char: _s(vChar), style: s);
    }

    if (title != null && title.isNotEmpty && rect.width > 2) {
      final titleWidth = stringWidth(title);
      final titleX = left + 1 + ((rect.width - 2) - titleWidth) ~/ 2;
      if (titleX + titleWidth <= right && titleX > left) {
        putText(titleX, top, title, s);
      }
    }
  }

  /// Exports the surface as plain text lines (no escape sequences).
  List<String> toPlainLines() {
    return grid
        .map((row) {
          return row
              .map((cell) => cell.wideContinuation ? '' : cell.char)
              .join();
        })
        .toList(growable: false);
  }

  /// Converts a TextStyle to ANSI SGR escape sequences.
  static String _styleToAnsi(TextStyle s) {
    final buf = StringBuffer();
    if (s.bold == true) buf.write(bold(true));
    if (s.dim == true) buf.write(dim(true));
    if (s.italic == true) buf.write(italic(true));
    if (s.underline == true) buf.write(underline(true));
    if (s.blink == true) buf.write(blink(true));
    if (s.reverse == true) buf.write(reverse(true));
    if (s.strikethrough == true) buf.write(strikethrough(true));
    if (s.overline == true) buf.write(overLine(true));
    if (s.foreground != null) {
      buf.write(s.foreground!.sgrSequence());
    }
    if (s.background != null) {
      buf.write(s.background!.sgrSequence(background: true));
    }
    return buf.toString();
  }

  /// Extracts a substring by rune index range (not code unit range).
  static String _substringByCodeUnits(String text, int start, int end) {
    final runes = text.runes.toList();
    return String.fromCharCodes(runes.sublist(start, end));
  }

  /// Re-wraps a string through rune conversion for safety.
  static String _s(String ch) => String.fromCharCodes(ch.runes);
}

extension SurfaceAnsiExport on Surface {
  /// Exports the surface as ANSI-escaped lines ready for terminal output.
  List<String> toAnsiLines() {
    return grid
        .map((row) {
          final buf = StringBuffer();
          TextStyle? lastStyle;
          String? lastHyperlink;
          for (final cell in row) {
            if (cell.wideContinuation) continue;
            if (cell.style != lastStyle || cell.hyperlink != lastHyperlink) {
              if (lastHyperlink != null && cell.hyperlink == null) {
                buf.write(ControlBytes.st);
              }
              buf.write(Surface._styleToAnsi(cell.style));
              lastStyle = cell.style;
              if (cell.hyperlink != null && cell.hyperlink != lastHyperlink) {
                buf.write(hyperlink(cell.hyperlink!, ''));
                lastHyperlink = cell.hyperlink;
              } else if (cell.hyperlink == null) {
                lastHyperlink = null;
              }
            }
            buf.write(cell.char);
          }
          if (lastHyperlink != null) {
            buf.write(ControlBytes.st);
          }
          if (lastStyle != null && !lastStyle.isClear) {
            buf.write(AnsiDefaults.resetAll);
          }
          return buf.toString();
        })
        .toList(growable: false);
  }
}
