import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:core/core.dart';

part 'frame.freezed.dart';

/// A rendered frame containing plain lines, styled ANSI lines, and optional cell grid.
@freezed
abstract class Frame with _$Frame {
  const Frame._();

  factory Frame(List<String> plainLines, List<String> styledLines, {List<List<Cell>>? cells}) = _Frame;

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

/// The result of diffing two frames: a list of changed row indices.
@freezed
abstract class DiffResult with _$DiffResult {
  const DiffResult._();

  const factory DiffResult(List<int> changedRows) = _DiffResult;

  /// True if at least one row changed.
  bool get hasChanges => changedRows.isNotEmpty;
}

/// Compares two frames and returns rows that changed (by plain text or style).
DiffResult diff(Frame previous, Frame current) {
  final changedRows = <int>[];
  final maxRows = previous.height > current.height
      ? previous.height
      : current.height;

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
