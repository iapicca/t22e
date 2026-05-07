import '../../loop/model.dart' show Model;
import '../../loop/msg.dart' show Msg, KeyMsg;
import '../../loop/cmd.dart' show Cmd;
import '../../core/layout.dart' show Constraints, Size;
import '../../core/style.dart' show TextStyle;
import '../widget.dart' show Widget, PaintingContext;
import '../enums.dart' show Axis;
import '../../parser/events.dart' show KeyEvent;

class Scrollable extends Model<Scrollable> {
  final int scrollX;
  final int scrollY;
  final Widget child;
  final Axis axis;
  final int scrollStep;
  final int viewportWidth;
  final int viewportHeight;

  const Scrollable({
    this.scrollX = 0,
    this.scrollY = 0,
    required this.child,
    this.axis = Axis.vertical,
    this.scrollStep = 3,
    this.viewportWidth = 80,
    this.viewportHeight = 24,
  });

  @override
  (Scrollable, Cmd?) update(Msg msg) {
    if (msg is KeyMsg) {
      return _handleKey(msg.event);
    }
    return (this, null);
  }

  (Scrollable, Cmd?) _handleKey(KeyEvent event) {
    return (this, null);
  }

  Scrollable copyWith({
    int? scrollX,
    int? scrollY,
    Widget? child,
    Axis? axis,
    int? scrollStep,
    int? viewportWidth,
    int? viewportHeight,
  }) {
    return Scrollable(
      scrollX: scrollX ?? this.scrollX,
      scrollY: scrollY ?? this.scrollY,
      child: child ?? this.child,
      axis: axis ?? this.axis,
      scrollStep: scrollStep ?? this.scrollStep,
      viewportWidth: viewportWidth ?? this.viewportWidth,
      viewportHeight: viewportHeight ?? this.viewportHeight,
    );
  }

  @override
  Widget view() {
    return _ScrollView(
      child: child,
      scrollX: scrollX,
      scrollY: scrollY,
      viewportWidth: viewportWidth,
      viewportHeight: viewportHeight,
    );
  }
}

class _ScrollView extends Widget {
  final Widget child;
  final int scrollX;
  final int scrollY;
  final int viewportWidth;
  final int viewportHeight;

  const _ScrollView({
    required this.child,
    this.scrollX = 0,
    this.scrollY = 0,
    this.viewportWidth = 80,
    this.viewportHeight = 24,
  });

  @override
  Size layout(Constraints constraints) {
    return Size(
      viewportWidth.clamp(constraints.minWidth, constraints.maxWidth),
      viewportHeight.clamp(constraints.minHeight, constraints.maxHeight),
    );
  }

  @override
  void paint(PaintingContext context) {
    // Paint child at negative scroll offset
    child.paint(context.child(-scrollX, -scrollY));

    // Draw scrollbar on right edge
    if (viewportHeight > 2) {
      final sbX = context.offsetX + viewportWidth - 1;
      final sbTop = context.offsetY;
      final sbBottom = context.offsetY + viewportHeight - 1;

      // Draw track
      for (var r = sbTop; r <= sbBottom; r++) {
        context.surface.putChar(sbX, r, '\u2591', TextStyle.empty);
      }
    }
  }
}
