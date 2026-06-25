import 'package:meta/meta.dart' show immutable, internal;

import '../../engine/cell_style.dart' show CellStyle;
import '../../engine/color.dart' show Color;
import '../../engine/render_text.dart' show RenderText;
import '../context.dart' show Context;
import '../render_object_element.dart' show RenderObjectElement;
import '../widget.dart' show Widget;

/// A leaf widget that displays a string of text.
@immutable
class Text extends Widget {
  /// Creates a text widget with optional cell styling.
  const Text(
    this.text, {
    this.foreground,
    this.background,
    this.styles = const <CellStyle>{},
  });

  /// The text to display.
  final String text;

  /// Optional foreground color.
  final Color? foreground;

  /// Optional background color.
  final Color? background;

  /// Style flags applied to every cell.
  final Set<CellStyle> styles;

  @override
  TextElement compile(Context context) =>
      TextElement(widget: this, context: context);
}

/// Runtime element that owns the [RenderText] for a [Text] widget.
@internal
class TextElement extends RenderObjectElement<RenderText> {
  /// Creates an element for [widget].
  TextElement({required Text super.widget, required super.context});

  Text get _widget => widget as Text;

  @override
  RenderText createRenderObject() => RenderText(
    text: _widget.text,
    foreground: _widget.foreground,
    background: _widget.background,
    styles: _widget.styles,
  );
}
