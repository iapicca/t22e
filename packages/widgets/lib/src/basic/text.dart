import '../widget.dart' show Widget, PaintingContext;
import '../enums.dart' show TextAlign;
import 'package:core/core.dart' show Constraints, Size;
import 'package:core/core.dart' show TextStyle;
import 'package:protocol/protocol.dart' show Defaults;
import 'package:unicode/unicode.dart' show stringWidth, charWidth;

class Text extends Widget {
  final String text;
  final TextStyle style;
  final TextAlign align;
  final bool wordWrap;

  Text(
    this.text, {
    this.style = TextStyle.empty,
    this.align = TextAlign.left,
    this.wordWrap = false,
  });

  List<String>? _lines;
  int _measuredWidth = 0;
  int _measuredHeight = 0;
  int _allocatedWidth = 0;

  @override
  Size layout(Constraints constraints) {
    if (text.isEmpty) {
      _lines = [''];
      _measuredWidth = 0;
      _measuredHeight = 1;
      _allocatedWidth = 0;
      return Size(0, 1);
    }

    if (wordWrap && constraints.maxWidth > 0) {
      _lines = _wrapText(text, constraints.maxWidth);
      _measuredWidth = _lines!.fold(
        0,
        (int max, String l) => max > stringWidth(l) ? max : stringWidth(l),
      );
      _measuredHeight = _lines!.length;
    } else {
      final textWidth = stringWidth(text);
      _lines = [text];
      _measuredWidth = textWidth;
      _measuredHeight = 1;
    }

    final w = _measuredWidth.clamp(constraints.minWidth, constraints.maxWidth);
    final h = _measuredHeight.clamp(
      constraints.minHeight,
      constraints.maxHeight,
    );
    _allocatedWidth = constraints.maxWidth;
    return Size(w, h);
  }

  static List<String> _wrapText(String txt, int maxWidth) {
    if (maxWidth <= 0 || stringWidth(txt) <= maxWidth) return [txt];

    final result = <String>[];
    final runeList = txt.runes.toList();
    final total = runeList.length;
    var lineStart = 0;

    while (lineStart < total) {
      var lineEnd = lineStart;
      var lineWidth = 0;
      var lastBreak = -1;
      var lastBreakWidth = 0;

      for (var i = lineStart; i < total; i++) {
        final cw = charWidth(runeList[i]);
        if (lineWidth + cw > maxWidth) {
          if (lastBreak > lineStart) {
            lineEnd = lastBreak;
            lineWidth = lastBreakWidth;
          } else {
            lineEnd = i > lineStart ? i : i + 1;
          }
          break;
        }
        if (runeList[i] == Defaults.codepointSpace ||
            runeList[i] == Defaults.codepointIdeographicSpace) {
          lastBreak = i;
          lastBreakWidth = lineWidth;
        }
        lineWidth += cw;
        lineEnd = i + 1;
      }

      result.add(String.fromCharCodes(runeList.sublist(lineStart, lineEnd)));
      lineStart = lineEnd;
      if (lineStart < total && runeList[lineStart] == Defaults.codepointSpace) {
        lineStart++;
      }
    }

    return result;
  }

  @override
  void paint(PaintingContext context) {
    if (_lines == null || _lines!.isEmpty) return;

    final resolvedStyle = context.inheritedStyle.merge(style);

    for (var i = 0; i < _lines!.length; i++) {
      final line = _lines![i];
      final lineWidth = stringWidth(line);
      final xOffset = switch (align) {
        TextAlign.left => 0,
        TextAlign.center => (_allocatedWidth - lineWidth) ~/ 2,
        TextAlign.right => _allocatedWidth - lineWidth,
      };

      final lineY = context.offsetY + i;
      if (lineY < 0) continue;

      context.surface.putText(
        context.offsetX + xOffset,
        lineY,
        line,
        resolvedStyle,
      );
    }
  }
}
