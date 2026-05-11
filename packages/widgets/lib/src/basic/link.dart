import '../widget.dart' show Widget, PaintingContext;
import 'package:core/core.dart' show Constraints, Size;
import 'package:core/core.dart' show TextStyle;
import 'package:core/core.dart' show Cell;
import 'package:unicode/unicode.dart' show stringWidth;

class Hyperlink extends Widget {
  final String uri;
  final String text;
  final TextStyle? style;
  int _width = 0;

  Hyperlink(this.uri, this.text, {this.style});

  @override
  Size layout(Constraints constraints) {
    final textWidth = stringWidth(text);
    _width = textWidth.clamp(constraints.minWidth, constraints.maxWidth);
    return Size(_width, 1);
  }

  @override
  void paint(PaintingContext context) {
    if (text.isEmpty) return;

    final resolvedStyle = context.inheritedStyle.merge(
      style ?? TextStyle.link(),
    );
    final x = context.offsetX;
    final y = context.offsetY;

    if (y < 0 || y >= context.surface.height) return;

    final clusters = _graphemeClusters(text);
    var col = x;

    context.surface.grid[y] = List<Cell>.of(context.surface.grid[y]);

    for (final cluster in clusters) {
      if (col >= context.surface.width) break;

      context.surface.grid[y][col] = Cell(
        char: cluster,
        style: resolvedStyle,
        hyperlink: uri,
      );
      col += 1;
    }
  }

  static List<String> _graphemeClusters(String text) {
    return text.runes.map((r) => String.fromCharCode(r)).toList();
  }
}
