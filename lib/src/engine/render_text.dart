import 'dart:math' show max;

import 'package:meta/meta.dart' show internal;

import '../models/constraint_extensions.dart' show ConstraintExtensions;
import '../models/constraints.dart' show Constraints;
import '../models/offset.dart' show Offset;
import '../models/size.dart' show Size;
import 'cell.dart' show Cell;
import 'cell_buffer_builder.dart' show CellBufferBuilder;
import 'cell_style.dart' show CellStyle;
import 'color.dart' show Color;
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
    final lines = _lines;
    final contentWidth = lines.fold(0, (w, line) => max(w, line.length));
    final contentHeight = lines.length;

    // TODO: define the correct behavior when constraints force width to 0.
    size = constraints.constrain(Size(contentWidth, contentHeight));
  }

  @override
  void paint(CellBufferBuilder buffer, Offset offset) {
    final lines = _lines;
    for (var y = 0; y < lines.length && y < size.height; y++) {
      final line = lines[y];
      for (var x = 0; x < line.length && x < size.width; x++) {
        buffer.set(
          offset.x + x,
          offset.y + y,
          Cell(
            character: line[x],
            foreground: foreground,
            background: background,
            styles: styles,
          ),
        );
      }
    }
  }

  @override
  void visitChildren(void Function(RenderObject child) visitor) {}

  List<String> get _lines => text.isEmpty ? const [''] : text.split('\n');
}
