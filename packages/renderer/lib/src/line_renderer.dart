import 'package:ansi/ansi.dart' show moveTo;
import 'frame.dart';

class LineRenderer {
  const LineRenderer();

  String render(DiffResult diff, Frame currentFrame) {
    final buf = StringBuffer();
    for (final row in diff.changedRows) {
      if (row < currentFrame.height) {
        buf.write(moveTo(row + 1, 0));
        buf.write(currentFrame.styledLines[row]);
      }
    }
    return buf.toString();
  }
}
