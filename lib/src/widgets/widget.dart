import '../core/surface.dart' show Surface;
import '../core/style.dart' show TextStyle;
import '../core/layout.dart' show Constraints, Size;

/// Base class for all UI widgets in the framework
abstract class Widget {
  const Widget();

  /// Computes the widget's size given the available constraints
  Size layout(Constraints constraints);
  /// Paints the widget onto the surface via the painting context
  void paint(PaintingContext context);
}

/// Carries the surface, offset, and inherited style for widget painting
class PaintingContext {
  /// The surface being painted to
  final Surface surface;
  /// Horizontal offset from the parent
  final int offsetX;
  /// Vertical offset from the parent
  final int offsetY;
  /// Inherited text style from ancestor widgets
  final TextStyle inheritedStyle;

  const PaintingContext({
    required this.surface,
    this.offsetX = 0,
    this.offsetY = 0,
    this.inheritedStyle = TextStyle.empty,
  });

  /// Creates a child context shifted by (x, y) with an optional style override
  PaintingContext child(int x, int y, {TextStyle? style}) {
    return PaintingContext(
      surface: surface,
      offsetX: offsetX + x,
      offsetY: offsetY + y,
      inheritedStyle: style ?? inheritedStyle,
    );
  }
}
