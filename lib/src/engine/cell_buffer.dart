import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/size.dart';
import 'cell.dart';

part 'cell_buffer.freezed.dart';

/// A flat buffer of immutable [Cell] values addressed as a 2D terminal grid.
@freezed
@internal
abstract class CellBuffer with _$CellBuffer {
  const CellBuffer._();

  /// Creates a buffer with the given [width] and [cells].
  const factory CellBuffer({required int width, required List<Cell> cells}) =
      _CellBuffer;

  /// Total number of cells.
  int get area => cells.length;

  /// Buffer size derived from [width] and [cells].
  Size get size => Size(width, width == 0 ? 0 : (cells.length / width).ceil());
}
