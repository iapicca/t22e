import 'package:meta/meta.dart' show internal;

import '../models/offset.dart';
import '../models/size.dart';
import 'cell.dart';
import 'cell_buffer.dart';

/// Coordinate and mutation helpers for [CellBuffer].
@internal
extension CellBufferExtensions on CellBuffer {
  /// Buffer height derived from [width] and [cells].
  int get height => width == 0 ? 0 : (area / width).ceil();

  /// Converts 2D coordinates into a flat index.
  int indexAt(int x, int y) {
    RangeError.checkValueInInterval(x, 0, width - 1, 'x');
    RangeError.checkValueInInterval(y, 0, height - 1, 'y');
    return y * width + x;
  }

  /// Converts a flat index into 2D coordinates.
  Offset offsetAt(int index) {
    RangeError.checkValidIndex(index, cells);
    return Offset(index % width, index ~/ width);
  }

  /// Returns the cell at 2D coordinates.
  Cell get(int x, int y) => getAt(indexAt(x, y));

  /// Returns the cell at [index].
  Cell getAt(int index) {
    RangeError.checkValidIndex(index, cells);
    return cells[index];
  }

  /// Returns a new buffer with [cell] written at 2D coordinates.
  CellBuffer set(int x, int y, Cell cell) => setAt(indexAt(x, y), cell);

  /// Returns a new buffer with [cell] written at [index].
  CellBuffer setAt(int index, Cell cell) {
    RangeError.checkValidIndex(index, cells);
    final newCells = [
      for (var i = 0; i < cells.length; i++) i == index ? cell : cells[i],
    ];
    return CellBuffer(width: width, cells: newCells);
  }

  /// Returns a new buffer resized to [newSize], preserving overlapping content.
  CellBuffer resize(Size newSize, {Cell defaultCell = Cell.blank}) {
    final newCells = [
      for (var y = 0; y < newSize.height; y++)
        for (var x = 0; x < newSize.width; x++)
          if (y < height && x < width) get(x, y) else defaultCell,
    ];
    return CellBuffer(width: newSize.width, cells: newCells);
  }
}
