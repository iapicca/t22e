import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:core/core.dart' show CellGrid, Surface, SurfaceAnsiExport;

part 'frame.freezed.dart';

/// A rendered frame containing plain lines, styled ANSI lines, and optional cell grid.
@freezed
abstract class Frame with _$Frame {
  const Frame._();

  factory Frame(
    List<String> plainLines,
    List<String> styledLines, {
    @Default(CellGrid.empty()) CellGrid cells,
  }) = _Frame;

  /// Creates a Frame from a Surface, optionally including the cell grid.
  factory Frame.fromSurface(Surface surface, {bool includeCells = false}) =>
      Frame(
        surface.toPlainLines(),
        surface.toAnsiLines(),
        cells: includeCells ? surface.grid : const CellGrid.empty(),
      );

  /// Number of rows in this frame.
  int get height => plainLines.length;
}

extension type FrameLine(({String plain, String styled}) _) {
  String get plain => _.plain;
  String get styled => _.styled;
}

extension FrameLineFromRow on Frame {
  FrameLine frameLine(int row) => FrameLine((
    plain: row < height ? plainLines[row] : '',
    styled: row < height ? styledLines[row] : '',
  ));
}
