import 'package:freezed_annotation/freezed_annotation.dart';

import 'cell_style.dart';
import 'color.dart';
import 'grapheme.dart';

part 'cell.freezed.dart';

/// A single terminal cell containing a visible character and its attributes.
@freezed
@internal
abstract class Cell with _$Cell {
  const Cell._();

  /// Creates a cell with the given character, optional colors, and styles.
  ///
  // TODO: `Grapheme` is const-unchecked; `Grapheme.validated` enforces the
  // single-cluster contract at runtime (text-to-cell boundaries). Wide
  // characters occupy two cells; the second carries `CellStyle.continuation`.
  const factory Cell({
    @Default(Grapheme.space) Grapheme character,
    Color? foreground,
    Color? background,
    @Default(<CellStyle>{}) Set<CellStyle> styles,
  }) = _Cell;

  /// A blank cell with a space, no colors, and no styles.
  static const Cell blank = Cell();
}