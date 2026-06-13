import 'dart:math' as math show max;

import 'frame.dart' show Frame, FrameLineFromRow;

/// The result of diffing two frames: a list of changed row indices.
extension type DiffResult(List<int> it) implements Iterable<int> {
  /// True if at least one row changed.
  bool get hasChanges => it.isNotEmpty;

  /// Compares two frames and returns rows that changed (by plain text or style).
  factory DiffResult.fromFrames(Frame previous, Frame current) => DiffResult([
    for (var i = 0; i < math.max(previous.height, current.height); i++)
      if (previous.frameLine(i) != current.frameLine(i)) i,
  ]);
}
