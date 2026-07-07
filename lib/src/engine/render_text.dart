import 'dart:math' show max;

import 'package:characters/characters.dart';
import 'package:meta/meta.dart' show internal;

import '../models/constraint_extensions.dart' show ConstraintExtensions;
import '../models/constraints.dart' show Constraints;
import '../models/offset.dart' show Offset;
import '../models/size.dart' show Size;
import 'cell.dart' show Cell;
import 'cell_buffer_builder.dart' show CellBufferBuilder;
import 'cell_style.dart' show CellStyle;
import 'color.dart' show Color;
import 'grapheme.dart' show Grapheme;
import 'render_object.dart' show RenderObject;

/// A leaf render object that paints a string.
@internal
class RenderText extends RenderObject {
  /// Creates a render object for [text] with optional styling.
  RenderText({
    required this.text,
    this.foreground,
    this.background,
    this.styles = const <CellStyle>{},
  });

  /// The text to paint.
  String text;

  /// Optional foreground color.
  Color? foreground;

  /// Optional background color.
  Color? background;

  /// Style flags applied to every cell.
  Set<CellStyle> styles;

  @override
  void performLayout(Constraints constraints) {
    final lines = _graphemeLines;
    final contentWidth = lines.fold(0, (w, line) => max(w, _lineWidth(line)));
    final contentHeight = lines.length;

    // TODO: define the correct behavior when constraints force width to 0.
    size = constraints.constrain(Size(contentWidth, contentHeight));
  }

  @override
  void paint(CellBufferBuilder buffer, Offset offset) {
    final lines = _graphemeLines;
    for (var y = 0; y < lines.length && y < size.height; y++) {
      final line = lines[y];
      var x = 0;
      for (final grapheme in line) {
        if (x >= size.width) break;
        final w = grapheme.width;
        if (x + w > size.width) break;
        buffer.set(
          offset.x + x,
          offset.y + y,
          Cell(
            character: grapheme,
            foreground: foreground,
            background: background,
            styles: styles,
          ),
        );
        if (w == 2 && x + 1 < size.width) {
          buffer.set(
            offset.x + x + 1,
            offset.y + y,
            Cell(
              character: Grapheme.space,
              foreground: foreground,
              background: background,
              styles: {...styles, CellStyle.continuation},
            ),
          );
        }
        x += w;
      }
    }
  }

  @override
  void visitChildren(void Function(RenderObject child) visitor) {}

  List<List<Grapheme>> get _graphemeLines =>
      (text.isEmpty ? const [''] : text.split('\n'))
          .map(_splitGraphemes)
          .toList(growable: false);

  static List<Grapheme> _splitGraphemes(String line) {
    if (line.isEmpty) return const <Grapheme>[];
    final result = <Grapheme>[];
    for (final cluster in Characters(line)) {
      result.add(Grapheme(cluster.toString()));
    }
    return result;
  }

  static int _lineWidth(List<Grapheme> line) =>
      line.fold(0, (w, g) => w + g.width);
}