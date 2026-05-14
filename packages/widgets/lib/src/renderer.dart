import 'package:core/core.dart' show Surface;
import 'package:core/core.dart' show Constraints;
import 'widget.dart' show Widget, PaintingContext;

/// Renders a widget tree to a Surface by running layout then paint.
class WidgetRenderer {
  /// Lays out and paints the widget tree, returning the resulting Surface.
  static Surface render(Widget root, int width, int height) {
    final surface = Surface(width, height);
    final constraints = Constraints.tight(width, height);
    root.layout(constraints);
    final context = PaintingContext(surface: surface);
    root.paint(context);
    return surface;
  }
}
