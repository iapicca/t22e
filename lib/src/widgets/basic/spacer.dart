import '../widget.dart' show Widget, PaintingContext;
import '../../core/layout.dart' show Constraints, Size;

class Spacer extends Widget {
  final int flex;

  const Spacer({this.flex = 1});

  @override
  Size layout(Constraints constraints) {
    return Size(constraints.maxWidth, constraints.maxHeight);
  }

  @override
  void paint(PaintingContext context) {}
}
