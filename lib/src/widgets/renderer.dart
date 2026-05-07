import '../core/surface.dart' show Surface;
import '../core/layout.dart' show Constraints;
import 'widget.dart' show Widget, PaintingContext;

class WidgetRenderer {
  static Surface render(Widget root, int width, int height) {
    final surface = Surface(width, height);
    final constraints = Constraints.tight(width, height);
    root.layout(constraints);
    final context = PaintingContext(surface: surface);
    root.paint(context);
    return surface;
  }
}
