import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:core/core.dart';

import 'diff_result.dart';

part 'frame.freezed.dart';

/// A rendered frame containing plain lines, styled ANSI lines, and optional cell grid.
@freezed
abstract class Frame with _$Frame {
  const Frame._();

  factory Frame(
    List<String> plainLines,
    List<String> styledLines, {
    List<List<Cell>>? cells,
  }) = _Frame;

  /// Creates a Frame from a Surface, optionally including the cell grid.
  factory Frame.fromSurface(Surface surface, {bool includeCells = false}) {
    return Frame(
      surface.toPlainLines(),
      surface.toAnsiLines(),
      cells: includeCells ? surface.grid : null,
    );
  }

  /// Number of rows in this frame.
  int get height => plainLines.length;
}

/// Compares two frames and returns rows that changed (by plain text or style).
DiffResult diff(Frame previous, Frame current) {
  final changedRows = <int>[];
  final maxRows = max(previous.height, current.height);

  for (var r = 0; r < maxRows; r++) {
    final prevPlain = r < previous.height ? previous.plainLines[r] : '';
    final currPlain = r < current.height ? current.plainLines[r] : '';
    final prevStyled = r < previous.height ? previous.styledLines[r] : '';
    final currStyled = r < current.height ? current.styledLines[r] : '';

    if (prevPlain != currPlain || prevStyled != currStyled) {
      changedRows.add(r);
    }
  }

  return DiffResult(changedRows);
}
