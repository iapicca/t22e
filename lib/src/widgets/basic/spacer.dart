import '../widget.dart' show Widget, PaintingContext;
import '../../core/layout.dart' show Constraints, Size;

/// A widget that takes up available space in a flex layout
class Spacer extends Widget {
  /// Flex factor for proportional space distribution
  final int flex;

  const Spacer({this.flex = 1});

  @override
  Size layout(Constraints constraints) {
    return Size(constraints.maxWidth, constraints.maxHeight);
  }

  @override
  void paint(PaintingContext context) {}
}
