import 'package:meta/meta.dart' show internal;

import '../models/size.dart' show Size;
import 'cell.dart' show Cell;
import 'cell_style.dart' show CellStyle;
import 'color_extensions.dart' show ColorAnsi;
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

    final params = <int>[];
    for (final flag in CellStyle.values) {
      if (flag == CellStyle.continuation) continue;
      if (style.styles.contains(flag)) {
        params.add(_styleCode(flag));
      }
    }

    final foreground = style.foreground;
    if (foreground != null) {
      params.add(_foregroundCode(foreground.ansi.code));
    }

    final background = style.background;
    if (background != null) {
      params.add(_backgroundCode(background.ansi.code));
    }

    return '\x1B[${params.join(';')}m';
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

  /// Maps an ANSI 16 code to its foreground SGR parameter.
  /// TODO should create an ansi code extension type to handle this! 
  int _foregroundCode(int ansiCode) =>
      ansiCode < 8 ? 30 + ansiCode : 90 + (ansiCode - 8);

  /// Maps an ANSI 16 code to its background SGR parameter.
    /// TODO should create an ansi code extension type to handle this! 
  int _backgroundCode(int ansiCode) =>
      ansiCode < 8 ? 40 + ansiCode : 100 + (ansiCode - 8);
}
