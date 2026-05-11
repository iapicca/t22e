import 'package:core/core.dart' show Surface;
import 'package:core/core.dart' show TextStyle;
import 'package:core/core.dart' show Constraints, Size;

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
