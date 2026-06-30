import 'package:freezed_annotation/freezed_annotation.dart';

import 'cell_style.dart';
import 'color.dart';

part 'cell.freezed.dart';

/// A single terminal cell containing a visible character and its attributes.
@freezed
@internal
abstract class Cell with _$Cell {
  const Cell._();

  /// Creates a cell with the given character, optional colors, and styles.
  ///
  // TODO: character is currently a plain String. This does not enforce a
  // single grapheme cluster and ignores multi-cell widths (e.g. emojis, CJK).
  const factory Cell({
    @Default(' ') String character,
    Color? foreground,
    Color? background,
    @Default(<CellStyle>{}) Set<CellStyle> styles,
  }) = _Cell;

  /// A blank cell with a space, no colors, and no styles.
  static const Cell blank = Cell();
}
