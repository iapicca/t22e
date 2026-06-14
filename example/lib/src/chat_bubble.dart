import 'package:widgets/widgets.dart';
import 'package:core/core.dart';
import 'package:unicode/unicode.dart' show stringWidth, charWidth;
import 'package:protocol/protocol.dart' show UnicodeCodepoints;

class ChatBubble extends Widget {
  final String text;
  final bool isUser;
  final int maxWidth;

  Size _size = Size(0, 0);
  late List<String> _lines;

  Size get size => _size;

  ChatBubble({
    required this.text,
    required this.isUser,
    required this.maxWidth,
  });

  @override
  Size layout(Constraints constraints) {
    final bubbleMaxWidth = maxWidth - 4;
    _lines = _wrapText(text, bubbleMaxWidth);
    final textWidth = _lines.fold(
      0,
      (int max, String l) => max > stringWidth(l) ? max : stringWidth(l),
    );
    final bubbleWidth = (textWidth + 4).clamp(6, maxWidth);
    final bubbleHeight = _lines.length + 2;

    _size = Size(
      bubbleWidth.clamp(constraints.minWidth, constraints.maxWidth),
      bubbleHeight.clamp(constraints.minHeight, constraints.maxHeight),
    );
    return _size;
  }

  @override
  void paint(PaintingContext context) {
    final bgColor = isUser ? Color.green() : Color.blue();
    final textColor = isUser ? Color.black() : Color.white();

    final bubbleStyle = TextStyle(foreground: textColor, background: bgColor);

    for (var y = 0; y < _size.height; y++) {
      for (var x = 0; x < _size.width; x++) {
        context.surface.putChar(
          x + context.offsetX,
          y + context.offsetY,
          ' ',
          bubbleStyle,
        );
      }
    }

    final contentX = context.offsetX + 2;
    for (var i = 0; i < _lines.length; i++) {
      context.surface.putText(
        contentX,
        context.offsetY + 1 + i,
        _lines[i],
        bubbleStyle,
      );
    }
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
        if (runeList[i] == UnicodeCodepoints.codepointSpace ||
            runeList[i] == UnicodeCodepoints.codepointIdeographicSpace) {
          lastBreak = i;
          lastBreakWidth = lineWidth;
        }
        lineWidth += cw;
        lineEnd = i + 1;
      }

      result.add(String.fromCharCodes(runeList.sublist(lineStart, lineEnd)));
      lineStart = lineEnd;
      if (lineStart < total &&
          runeList[lineStart] == UnicodeCodepoints.codepointSpace) {
        lineStart++;
      }
    }

    return result;
  }
}
