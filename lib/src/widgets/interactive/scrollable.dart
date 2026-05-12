import '../../loop/model.dart' show Model;
import '../../loop/msg.dart' show Msg, KeyMsg;
import '../../loop/cmd.dart' show Cmd;
import '../../core/layout.dart' show Constraints, Size;
import '../../core/style.dart' show TextStyle;
import '../../well_known.dart' show WellKnown;
import '../widget.dart' show Widget, PaintingContext;
import '../enums.dart' show Axis;
import '../../parser/events.dart' show KeyEvent;

/// A scrollable viewport model that can scroll a child widget
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
    this.scrollStep = WellKnown.defaultScrollStep,
    this.viewportWidth = WellKnown.defaultTerminalWidth,
    this.viewportHeight = WellKnown.defaultTerminalHeight,
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

  /// Copy with optional field updates
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

/// Internal widget that renders a scrolled child with a scrollbar
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
    this.viewportWidth = WellKnown.defaultTerminalWidth,
    this.viewportHeight = WellKnown.defaultTerminalHeight,
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
    if (viewportHeight > WellKnown.scrollbarMinViewportHeight) {
      final sbX = context.offsetX + viewportWidth - 1;
      final sbTop = context.offsetY;
      final sbBottom = context.offsetY + viewportHeight - 1;

      // Draw track
      for (var r = sbTop; r <= sbBottom; r++) {
        context.surface.putChar(sbX, r, WellKnown.charLightShade, TextStyle.empty);
      }
    }
  }
}
