import 'package:core/core.dart' show TextStyle;
import 'package:protocol/protocol.dart' show Defaults;
import 'package:ansi/ansi.dart' show hyperlink;
import 'frame.dart' show Frame;

/// Per-cell diff renderer that only outputs changed cells for minimal terminal output.
class CellRenderer {
  const CellRenderer();

  /// Produces ANSI output by diffing individual cells between frames.
  String render(Frame previous, Frame current) {
    final buf = StringBuffer();
    final prevCells = previous.cells;
    final currCells = current.cells;
    if (currCells == null) return '';
    final prevHeight = prevCells?.length ?? 0;
    final curHeight = currCells.length;
    final maxRows = prevHeight > curHeight ? prevHeight : curHeight;

    for (var r = 0; r < maxRows; r++) {
      final prevRow = (prevCells != null && r < prevCells.length)
          ? prevCells[r]
          : null;
      final curRow = currCells[r];
      final curWidth = curRow.length;

      /// TODO: Track last style to optimize SGR sequence emission
      // ignore: unused_local_variable
      TextStyle? lastStyle;

      for (var c = 0; c < curWidth; c++) {
        final curr = curRow[c];
        if (curr.wideContinuation) continue;

        final prev = (prevRow != null && c < prevRow.length)
            ? prevRow[c]
            : null;

        if (prev != null && prev == curr) continue;

        final linkChanged = prev?.hyperlink != curr.hyperlink;

        if (prev == null || prev.style != curr.style || linkChanged) {
          lastStyle = curr.style;
          buf.write(_styleAndLinkToAnsi(curr.style, curr.hyperlink));
        }

        if (prev == null || prev.char != curr.char || linkChanged) {
          buf.write('\x1b[${r + 1};${c + 1}H');
          if (prev?.hyperlink != null && curr.hyperlink == null) {
            buf.write(Defaults.st);
          }
          buf.write(curr.char);
        }
      }
    }

    return buf.toString();
  }

  /// Converts a TextStyle and optional hyperlink URI to SGR escape sequences.
  String _styleAndLinkToAnsi(TextStyle s, String? linkUri) {
    final buf = StringBuffer();
    if (s.bold == true) buf.write('${Defaults.csi}${Defaults.sgrBold}m');
    if (s.dim == true) buf.write('${Defaults.csi}${Defaults.sgrFaint}m');
    if (s.italic == true) buf.write('${Defaults.csi}${Defaults.sgrItalic}m');
    if (s.underline == true) {
      buf.write('${Defaults.csi}${Defaults.sgrUnderline}m');
    }
    if (s.blink == true) buf.write('${Defaults.csi}${Defaults.sgrBlink}m');
    if (s.reverse == true) buf.write('${Defaults.csi}${Defaults.sgrReverse}m');
    if (s.strikethrough == true) {
      buf.write('${Defaults.csi}${Defaults.sgrStrikethrough}m');
    }
    if (s.overline == true) {
      buf.write('${Defaults.csi}${Defaults.sgrOverline}m');
    }
    if (s.foreground != null) buf.write(s.foreground!.sgrSequence());
    if (s.background != null) {
      buf.write(s.background!.sgrSequence(background: true));
    }
    if (linkUri != null) buf.write(hyperlink(linkUri, ''));
    return buf.toString();
  }
}
