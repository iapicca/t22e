import 'package:meta/meta.dart' show internal;

import '../models/size.dart' show Size;
import 'cell.dart' show Cell;
import 'cell_buffer.dart' show CellBuffer;

/// Mutable accumulator that produces an immutable [CellBuffer] in a single
/// build step.

/// TODO this looks like bullshit!
@internal
class CellBufferBuilder {
  /// Creates a builder of [size] filled with [defaultCell].
  CellBufferBuilder(Size size, {Cell defaultCell = Cell.blank})
    : _width = size.width,
      _cells = List.filled(size.area, defaultCell, growable: false);

  final int _width;
  final List<Cell> _cells;

  /// The builder width.
  int get width => _width;

  /// The total number of cells.
  int get area => _cells.length;

  /// The builder height.
  int get height => _width == 0 ? 0 : _cells.length ~/ _width;

  /// Writes [cell] at 2D coordinates if inside bounds.
  void set(int x, int y, Cell cell) {
    if (x < 0 || x >= _width || y < 0 || y >= height) return;
    _cells[y * _width + x] = cell;
  }

  /// Builds an immutable [CellBuffer] from the accumulated cells.
  CellBuffer build() => CellBuffer(width: _width, cells: _cells);
}
