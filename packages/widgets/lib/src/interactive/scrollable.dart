import '../model.dart' show Model;
import '../msg.dart' show Msg, KeyMsg;
import '../cmd.dart' show Cmd;
import 'package:core/core.dart' show Constraints, Size;
import 'package:core/core.dart' show TextStyle;
import 'package:protocol/protocol.dart' show Defaults;
import '../widget.dart' show Widget, PaintingContext;
import '../enums.dart' show Axis;
import 'package:parser/terminal_parser.dart' show KeyEvent;

/// A scrollable viewport wrapping a child widget with scroll position.
class Scrollable extends Model<Scrollable> {
  /// Horizontal scroll offset.
  final int scrollX;
  /// Vertical scroll offset.
  final int scrollY;
  /// The child widget to scroll.
  final Widget child;
  /// Scroll axis direction.
  final Axis axis;
  /// Lines to scroll per step.
  final int scrollStep;
  /// Width of the viewport in columns.
  final int viewportWidth;
  /// Height of the viewport in rows.
  final int viewportHeight;

  const Scrollable({
    this.scrollX = 0,
    this.scrollY = 0,
    required this.child,
    this.axis = Axis.vertical,
    this.scrollStep = Defaults.defaultScrollStep,
    this.viewportWidth = Defaults.defaultTerminalWidth,
    this.viewportHeight = Defaults.defaultTerminalHeight,
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

  /// Returns a copy with overridden fields.
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

/// Internal widget that paints the child at a scroll offset with a scrollbar.
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
    this.viewportWidth = Defaults.defaultTerminalWidth,
    this.viewportHeight = Defaults.defaultTerminalHeight,
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
    child.paint(context.child(-scrollX, -scrollY));

    if (viewportHeight > Defaults.scrollbarMinViewportHeight) {
      final sbX = context.offsetX + viewportWidth - 1;
      final sbTop = context.offsetY;
      final sbBottom = context.offsetY + viewportHeight - 1;

      for (var r = sbTop; r <= sbBottom; r++) {
        context.surface.putChar(
          sbX,
          r,
          Defaults.charLightShade,
          TextStyle.empty,
        );
      }
    }
  }
}
