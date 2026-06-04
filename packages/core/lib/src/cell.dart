import 'package:freezed_annotation/freezed_annotation.dart';
import 'style.dart';

part 'cell.freezed.dart';

/// A single character cell on the terminal grid, with style and wide-char info.
@freezed
abstract class Cell with _$Cell {
  const Cell._();

  const factory Cell({
    @Default(' ') String char,
    @Default(TextStyle.empty) TextStyle style,
    @Default(false) bool wideContinuation,
    String? hyperlink,
  }) = _Cell;

  /// Returns a new cell with the given style merged on top.
  Cell mergeStyle(TextStyle override) {
    final merged = style.merge(override);
    if (identical(merged, style)) return this;
    return copyWith(style: merged);
  }
}
