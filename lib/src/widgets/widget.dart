import '../core/surface.dart' show Surface;
import '../core/style.dart' show TextStyle;
import '../core/layout.dart' show Constraints, Size;

abstract class Widget {
  const Widget();

  Size layout(Constraints constraints);
  void paint(PaintingContext context);
}

class PaintingContext {
  final Surface surface;
  final int offsetX;
  final int offsetY;
  final TextStyle inheritedStyle;

  const PaintingContext({
    required this.surface,
    this.offsetX = 0,
    this.offsetY = 0,
    this.inheritedStyle = TextStyle.empty,
  });

  PaintingContext child(int x, int y, {TextStyle? style}) {
    return PaintingContext(
      surface: surface,
      offsetX: offsetX + x,
      offsetY: offsetY + y,
      inheritedStyle: style ?? inheritedStyle,
    );
  }
}
