import 'dart:math';

import 'package:core/core.dart' show TextStyle, ColorSgr;
import 'package:protocol/protocol.dart' show Defaults;
import 'package:ansi/ansi.dart' show hyperlink;
import 'frame.dart' show Frame;

/// Per-cell diff renderer that only outputs changed cells for minimal terminal output.
/// Produces ANSI output by diffing individual cells between frames.
String cellRrender(Frame previous, Frame current) {
  if (current.cells.isEmpty) {
    return '';
  }

  final buf = StringBuffer();

  for (var i = 0; i < max(previous.cells.height, current.cells.height); ++i) {
    final previousRow = previous.cells.row(i);
    final currentRow = current.cells.row(i);

    for (var j = 0; j < currentRow.length; j++) {
      final currentCell = currentRow[j];
      if (currentCell.wideContinuation) continue;

      final previousCell = (j < previousRow.length) ? previousRow[j] : null;

      if (previousCell != null && previousCell == currentCell) continue;

      final hasLinkChanged = previousCell?.hyperlink != currentCell.hyperlink;

      if (previousCell == null ||
          previousCell.style != currentCell.style ||
          hasLinkChanged) {
        buf.write(
          _styleAndLinkToAnsi(currentCell.style, currentCell.hyperlink),
        );
      }

      if (previousCell == null ||
          previousCell.char != currentCell.char ||
          hasLinkChanged) {
        /// TODO this doesn't belong here!
        buf.write('\x1b[${i + 1};${j + 1}H');
        if (previousCell?.hyperlink != null && currentCell.hyperlink == null) {
          buf.write(Defaults.st);
        }
        buf.write(currentCell.char);
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
