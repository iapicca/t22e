import 'package:meta/meta.dart' show internal;

import '../models/size.dart' show Size;
import 'cell.dart' show Cell;
import 'cell_style.dart' show CellStyle;
import 'color_extensions.dart' show AnsiColorSgr, ColorAnsi;
import 'diff_engine.dart' show DiffOp, DiffOpMove, DiffOpStyle, DiffOpWrite;

/// Converts [DiffOp] update operations into ANSI escape sequences.
@internal
class AnsiWriter {
  /// Creates an ANSI writer.
  const AnsiWriter();

  /// Builds the ANSI byte string for [ops] within a terminal of [size].
  String write(List<DiffOp> ops, Size size) {
    final buffer = StringBuffer();
    var activeStyle = Cell.blank;

    for (final op in ops) {
      switch (op) {
        case DiffOpMove(:final offset):
          buffer.write('\x1B[${offset.y + 1};${offset.x + 1}H');
        case DiffOpStyle(:final style):
          final normalized = style.styles.contains(CellStyle.continuation)
              ? style.copyWith(
                  styles: style.styles
                      .where((s) => s != CellStyle.continuation)
                      .toSet(),
                )
              : style;
          if (activeStyle == normalized) continue;
          activeStyle = normalized;
          buffer.write(_sgr(normalized));
        case DiffOpWrite(:final character):
          buffer.write(character);
      }
    }

    return buffer.toString();
  }

  /// Builds the SGR escape sequence that activates [style].
  String _sgr(Cell style) {
    final visibleStyles = style.styles.where(
      (flag) => flag != CellStyle.continuation,
    );
    if (style.foreground == null &&
        style.background == null &&
        visibleStyles.isEmpty) {
      return '\x1B[0m';
    }

    final buffer = StringBuffer();

    if (visibleStyles.isNotEmpty) {
      final styleParams = <int>[];
      for (final flag in CellStyle.values) {
        if (flag == CellStyle.continuation) continue;
        if (style.styles.contains(flag)) {
          styleParams.add(_styleCode(flag));
        }
      }
      buffer.write('\x1B[${styleParams.join(';')}m');
    }

    final foreground = style.foreground;
    if (foreground != null) {
      buffer.write(foreground.ansi.toSgr());
    }

    final background = style.background;
    if (background != null) {
      buffer.write(background.ansi.toSgr(background: true));
    }

    return buffer.toString();
  }

  /// Maps a [CellStyle] flag to its SGR parameter code.
  /// TODO this should be simplified with enanced enumns!
  /// TODO this should be in CellStyle file!
  int _styleCode(CellStyle style) => switch (style) {
    CellStyle.bold => 1,
    CellStyle.italic => 3,
    CellStyle.underline => 4,
    CellStyle.inverse => 7,
    CellStyle.continuation =>
      throw StateError('continuation must never emit an SGR code'),
  };
}
