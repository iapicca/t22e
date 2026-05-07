import '../core/cell.dart' show Cell;
import '../core/style.dart' show TextStyle;
import '../ansi/term.dart' show hyperlink;
import 'frame.dart' show Frame;

class CellRenderer {
  const CellRenderer();

  String render(Frame previous, Frame current) {
    final buf = StringBuffer();
    final prevCells = previous.cells;
    final currCells = current.cells;
    if (currCells == null) return '';
    final prevHeight = prevCells?.length ?? 0;
    final curHeight = currCells.length;
    final maxRows = prevHeight > curHeight ? prevHeight : curHeight;

    for (var r = 0; r < maxRows; r++) {
      final prevRow = (prevCells != null && r < prevCells.length) ? prevCells[r] : null;
      final curRow = currCells[r];
      final curWidth = curRow.length;

      TextStyle? lastStyle;

      for (var c = 0; c < curWidth; c++) {
        final curr = curRow[c];
        if (curr.wideContinuation) continue;

        final prev = (prevRow != null && c < prevRow.length) ? prevRow[c] : null;

        if (prev != null && prev == curr) continue;

        final linkChanged = prev?.hyperlink != curr.hyperlink;

        if (prev == null || prev.style != curr.style || linkChanged) {
          lastStyle = curr.style;
          buf.write(_styleAndLinkToAnsi(curr.style, curr.hyperlink));
        }

        if (prev == null || prev.char != curr.char || linkChanged) {
          buf.write('\x1b[${r + 1};${c + 1}H');
          if (prev?.hyperlink != null && curr.hyperlink == null) {
            buf.write('\x1b]8;;\x07');
          }
          buf.write(curr.char);
        }
      }
    }

    return buf.toString();
  }

  String _styleAndLinkToAnsi(TextStyle s, String? linkUri) {
    final buf = StringBuffer();
    if (s.bold == true) buf.write('\x1b[1m');
    if (s.dim == true) buf.write('\x1b[2m');
    if (s.italic == true) buf.write('\x1b[3m');
    if (s.underline == true) buf.write('\x1b[4m');
    if (s.blink == true) buf.write('\x1b[5m');
    if (s.reverse == true) buf.write('\x1b[7m');
    if (s.strikethrough == true) buf.write('\x1b[9m');
    if (s.overline == true) buf.write('\x1b[53m');
    if (s.foreground != null) buf.write(s.foreground!.sgrSequence());
    if (s.background != null) buf.write(s.background!.sgrSequence(background: true));
    if (linkUri != null) buf.write(hyperlink(linkUri, ''));
    return buf.toString();
  }
}
