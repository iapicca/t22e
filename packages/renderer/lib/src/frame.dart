import 'package:core/core.dart';

/// A rendered frame containing plain lines, styled ANSI lines, and optional cell grid.
class Frame {
  /// Lines as plain text (no escape sequences).
  final List<String> plainLines;
  /// Lines with ANSI escape sequences.
  final List<String> styledLines;
  /// Optional row-major cell grid for per-cell diffing.
  final List<List<Cell>>? cells;

  Frame(this.plainLines, this.styledLines, {this.cells});

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
class DiffResult {
  /// Indices of rows that differ between previous and current frames.
  final List<int> changedRows;

  const DiffResult(this.changedRows);

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
