import 'package:core/core.dart' show Surface;
import 'package:core/core.dart' show TextStyle;
import 'package:core/core.dart' show Constraints, Size;

/// Base class for all widgets. Subclasses implement [layout] and [paint].
abstract class Widget {
  const Widget();

  /// Computes the widget's size given the provided constraints.
  Size layout(Constraints constraints);
  /// Paints the widget onto the surface via the given painting context.
  void paint(PaintingContext context);
}

/// Carries the surface and offset/position context for a widget during painting.
class PaintingContext {
  /// The target surface to paint onto.
  final Surface surface;
  /// X offset from the parent's origin.
  final int offsetX;
  /// Y offset from the parent's origin.
  final int offsetY;
  /// Resolved text style inherited from parent widgets.
  final TextStyle inheritedStyle;

  const PaintingContext({
    required this.surface,
    this.offsetX = 0,
    this.offsetY = 0,
    this.inheritedStyle = TextStyle.empty,
  });

  /// Creates a child context offset by (x, y) with an optional style override.
  PaintingContext child(int x, int y, {TextStyle? style}) {
    return PaintingContext(
      surface: surface,
      offsetX: offsetX + x,
      offsetY: offsetY + y,
      inheritedStyle: style ?? inheritedStyle,
    );
  }
}
