import 'cell.dart';
import 'geometry.dart';
import 'style.dart';
import '../unicode/grapheme.dart' show graphemeClusters;
import '../unicode/width.dart' show charWidth, stringWidth;
import '../ansi/codes.dart' show bold, dim, italic, underline, blink, reverse, strikethrough, overLine, resetAll;

class Surface {
  final int width;
  final int height;
  final List<List<Cell>> grid;

  Surface(this.width, this.height)
      : grid = List.generate(
          height,
          (_) => List.filled(width, const Cell()),
          growable: false,
        );

  Surface.fromGrid(this.grid)
      : width = grid.isEmpty ? 0 : grid[0].length,
        height = grid.length;

  Surface._resized(Surface source, int newWidth, int newHeight)
      : width = newWidth,
        height = newHeight,
        grid = List.generate(
          newHeight,
          (y) => List<Cell>.generate(
            newWidth,
            (x) =>
                y < source.height && x < source.width ? source.grid[y][x] : const Cell(),
            growable: false,
          ),
          growable: false,
        );

  Surface resize(int newWidth, int newHeight) =>
      Surface._resized(this, newWidth, newHeight);

  void putChar(int x, int y, String ch, TextStyle style) {
    if (x < 0 || x >= width || y < 0 || y >= height) return;

    grid[y] = List<Cell>.of(grid[y]);

    final cw = ch.runes.isEmpty ? 1 : charWidth(ch.runes.first);
    grid[y][x] = Cell(char: ch, style: style);

    if (cw == 2 && x + 1 < width) {
      grid[y][x + 1] = const Cell(char: '', wideContinuation: true);
    }
  }

  void putText(int x, int y, String text, TextStyle style) {
    if (x >= width || y >= height || y < 0 || text.isEmpty) return;

    final clusters = graphemeClusters(text);
    var col = x;

    grid[y] = List<Cell>.of(grid[y]);

    for (final cluster in clusters) {
      if (col >= width) break;

      final sub = _substringByCodeUnits(text, cluster.start, cluster.end);

      if (cluster.columnWidth == 2) {
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

  void fillRect(int x, int y, int w, int h, String ch, TextStyle style) {
    final rect = Rect(x, y, w, h).intersect(Rect(0, 0, width, height));
    if (rect.isEmpty) return;

    final cw = ch.runes.isEmpty ? 1 : charWidth(ch.runes.first);

    for (var row = rect.top; row < rect.bottom; row++) {
      grid[row] = List<Cell>.of(grid[row]);
      for (var col = rect.left; col < rect.right; col++) {
        grid[row][col] = Cell(char: ch, style: style);
        if (cw == 2 && col + 1 < rect.right) {
          grid[row][col + 1] = const Cell(char: '', wideContinuation: true);
          col++;
        }
      }
    }
  }

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

  void drawBorder(Rect r, {String? borderChars, TextStyle? style, String? title}) {
    final rect = r.intersect(Rect(0, 0, width, height));
    if (rect.isEmpty || rect.width < 2 || rect.height < 2) return;
    final s = style ?? TextStyle.empty;

    final hChar = borderChars != null && borderChars.length >= 2 ? borderChars[1] : '─';
    final vChar = borderChars != null && borderChars.isNotEmpty ? borderChars[0] : '│';
    final tl = borderChars != null && borderChars.length >= 4 ? borderChars[3] : '┌';
    final tr = borderChars != null && borderChars.length >= 5 ? borderChars[4] : '┐';
    final bl = borderChars != null && borderChars.length >= 6 ? borderChars[5] : '└';
    final br = borderChars != null && borderChars.length >= 7 ? borderChars[6] : '┘';

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

  List<String> toAnsiLines() {
    return grid.map((row) {
      final buf = StringBuffer();
      TextStyle? lastStyle;
      for (final cell in row) {
        if (cell.wideContinuation) continue;
        if (cell.style != lastStyle) {
          buf.write(_styleToAnsi(cell.style));
          lastStyle = cell.style;
        }
        buf.write(cell.char);
      }
      if (lastStyle != null && !lastStyle.isClear) {
        buf.write(resetAll());
      }
      return buf.toString();
    }).toList(growable: false);
  }

  List<String> toPlainLines() {
    return grid.map((row) {
      return row.map((cell) => cell.wideContinuation ? '' : cell.char).join();
    }).toList(growable: false);
  }

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
    if (s.foreground != null) buf.write(s.foreground!.sgrSequence());
    if (s.background != null) buf.write(s.background!.sgrSequence(background: true));
    return buf.toString();
  }

  static String _substringByCodeUnits(String text, int start, int end) {
    final runes = text.runes.toList();
    return String.fromCharCodes(runes.sublist(start, end));
  }

  static String _s(String ch) => String.fromCharCodes(ch.runes);
}
