import 'package:core/core.dart';

class Frame {
  final List<String> plainLines;
  final List<String> styledLines;
  final List<List<Cell>>? cells;

  Frame(this.plainLines, this.styledLines, {this.cells});

  factory Frame.fromSurface(Surface surface, {bool includeCells = false}) {
    return Frame(
      surface.toPlainLines(),
      surface.toAnsiLines(),
      cells: includeCells ? surface.grid : null,
    );
  }

  int get height => plainLines.length;
}

class DiffResult {
  final List<int> changedRows;

  const DiffResult(this.changedRows);

  bool get hasChanges => changedRows.isNotEmpty;
}

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
