import '../core/surface.dart' show Surface;
import 'frame.dart';

class LineRenderer {
  const LineRenderer();

  String render(DiffResult diff, Frame currentFrame) {
    final buf = StringBuffer();
    for (final row in diff.changedRows) {
      if (row < currentFrame.height) {
        buf.write('\x1b[${row + 1};0H');
        buf.write(currentFrame.styledLines[row]);
      }
    }
    return buf.toString();
  }
}
