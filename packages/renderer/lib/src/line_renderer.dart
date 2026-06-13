import 'package:ansi/ansi.dart' show moveTo;
import 'diff_result.dart';
import 'frame.dart';

/// Renders changed lines using cursor-positioned ANSI output.
class LineRenderer {
  const LineRenderer();

  /// Produces ANSI escape sequences to update only the changed rows.
  String render(DiffResult diff, Frame currentFrame) => [
    for (final row in diff)
      if (row < currentFrame.height)
        moveTo(row + 1, 0) + currentFrame.styledLines[row],
  ].join();
}
