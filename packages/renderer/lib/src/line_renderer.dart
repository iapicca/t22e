import 'package:ansi/ansi.dart' show moveTo;
import 'frame.dart';

/// Renders changed lines using cursor-positioned ANSI output.
class LineRenderer {
  const LineRenderer();

  /// Produces ANSI escape sequences to update only the changed rows.
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
