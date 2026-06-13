import 'cell.dart' show Cell;
import 'layout.dart' show Size;

extension type CellGrid(List<List<Cell>> _grid) implements List<List<Cell>> {
  int get height => _grid.length;
  int get width => isEmpty ? 0 : _grid[0].length;
  bool get isEmpty  =>  _grid.isEmpty;

  const CellGrid.empty() : _grid = const [];

  CellGrid.generate(Size size) :  _grid = List.generate(
        size.height,
        (_) => List.filled(size.width, const Cell(), growable: false),
        growable: false,
      );

  List<Cell> row(int row) => isEmpty ? [] :  _grid[row];

  // Safe accessor helper
  Cell? getCell(int row, int col) {
    if (row < 0 || row >= height || col < 0 || col >= width) return null;
    return _grid[row][col];
  }
}
