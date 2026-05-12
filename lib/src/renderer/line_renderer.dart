import '../ansi/cursor.dart' show moveTo;
import 'frame.dart';

/// Renders changed lines by moving cursor and writing styled content
class LineRenderer {
  const LineRenderer();

  /// Generates ANSI output for the changed rows in a diff
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
