import '../core/cell.dart';
import '../core/surface.dart';

/// A rendered frame snapshot: plain lines, ANSI-styled lines, and optional cells
class Frame {
  /// Line strings without escape codes (for diffing)
  final List<String> plainLines;
  /// Line strings with full ANSI styling
  final List<String> styledLines;
  /// Optional per-cell data for cell-level rendering
  final List<List<Cell>>? cells;

  Frame(this.plainLines, this.styledLines, {this.cells});

  /// Creates a frame from a Surface, optionally including cell data
  factory Frame.fromSurface(Surface surface, {bool includeCells = false}) {
    return Frame(
      surface.toPlainLines(),
      surface.toAnsiLines(),
      cells: includeCells ? surface.grid : null,
    );
  }

  int get height => plainLines.length;
}

/// Result of diffing two frames: list of row indices that changed
class DiffResult {
  final List<int> changedRows;

  const DiffResult(this.changedRows);

  bool get hasChanges => changedRows.isNotEmpty;
}

/// Computes which rows changed between two frames (by plain and styled content)
DiffResult diff(Frame previous, Frame current) {
  final changedRows = <int>[];
  final maxRows =
      previous.height > current.height ? previous.height : current.height;

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
