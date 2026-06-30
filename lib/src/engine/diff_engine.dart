import 'package:meta/meta.dart' show internal;

import '../models/offset.dart' show Offset;
import '../models/size.dart' show Size;
import 'cell.dart' show Cell;
import 'cell_buffer.dart' show CellBuffer;
import 'cell_buffer_extensions.dart' show CellBufferExtensions;

// TODO I don't like this one bit! looks like TEA approach!

/// A terminal update operation emitted by [DiffEngine].
@internal
sealed class DiffOp {
  /// Creates a diff operation.
  const DiffOp();
}

/// Positions the terminal cursor at [offset] using zero-indexed coordinates.
@internal
final class DiffOpMove extends DiffOp {
  /// Creates a cursor move operation.
  const DiffOpMove(this.offset);

  /// The target cursor position.
  final Offset offset;

  @override
  bool operator ==(Object other) =>
      other is DiffOpMove && other.offset == offset;

  @override
  int get hashCode => offset.hashCode;
}

/// Updates the active terminal style to match [style].
@internal
final class DiffOpStyle extends DiffOp {
  /// Creates a style change operation.
  const DiffOpStyle(this.style);

  /// The cell whose colors and style flags become active.
  ///
  /// [Cell.character] is ignored; the cell is only a canonical style carrier.
  final Cell style;

  @override
  bool operator ==(Object other) =>
      other is DiffOpStyle && other.style == style;

  @override
  int get hashCode => style.hashCode;
}

/// Writes [character] at the current cursor position.
@internal
final class DiffOpWrite extends DiffOp {
  /// Creates a character write operation.
  const DiffOpWrite(this.character);

  /// The visible character to write.
  final String character;

  @override
  bool operator ==(Object other) =>
      other is DiffOpWrite && other.character == character;

  @override
  int get hashCode => character.hashCode;
}

/// Compares two [CellBuffer] instances and emits minimal update operations.
@internal
class DiffEngine {
  /// Creates a diff engine.
  const DiffEngine();

  /// Scans [target] against [current] and returns the update operations.
  ///
  /// [size] defines the grid dimensions and must match both buffers.
  List<DiffOp> diff(CellBuffer target, CellBuffer current, Size size) {
    assert(
      target.width == current.width,
      'target and current buffers must have the same width',
    );
    assert(
      target.area == current.area,
      'target and current buffers must have the same area',
    );

    final ops = <DiffOp>[];
    var cursor = -1;
    var activeStyle = Cell.blank;

    for (var i = 0; i < target.area; i++) {
      final targetCell = target.getAt(i);
      if (targetCell == current.getAt(i)) continue;

      if (cursor + 1 != i) {
        ops.add(DiffOpMove(target.offsetAt(i)));
      }

      final targetStyle = Cell(
        character: ' ',
        foreground: targetCell.foreground,
        background: targetCell.background,
        styles: targetCell.styles,
      );
      if (activeStyle != targetStyle) {
        ops.add(DiffOpStyle(targetStyle));
        activeStyle = targetStyle;
      }

      ops.add(DiffOpWrite(targetCell.character));
      cursor = i;
    }

    return ops;
  }

  /// Returns a value copy of [target] suitable for use as the current buffer.
  CellBuffer copyTarget(CellBuffer target) =>
      CellBuffer(width: target.width, cells: List.of(target.cells));
}
