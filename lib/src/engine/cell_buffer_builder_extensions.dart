import 'package:meta/meta.dart' show internal;

import '../models/offset.dart' show Offset;
import 'cell.dart' show Cell;
import 'cell_buffer_builder.dart' show CellBufferBuilder;

/// Batch write helpers for [CellBufferBuilder].
@internal
extension CellBufferBuilderBatch on CellBufferBuilder {
  /// Writes [cell] at each coordinate in [offsets] relative to [origin].
  void setMany(Offset origin, Iterable<Offset> offsets, Cell cell) {
    for (final offset in offsets) {
      set(origin.x + offset.x, origin.y + offset.y, cell);
    }
  }
}
