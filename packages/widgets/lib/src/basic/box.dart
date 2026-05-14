import '../widget.dart' show Widget, PaintingContext;
import '../enums.dart' show BorderStyle;
import 'package:core/core.dart' show Insets, Rect;
import 'package:core/core.dart' show Constraints, Size;
import 'package:core/core.dart' show TextStyle;
import 'package:protocol/protocol.dart' show Defaults;
import 'package:unicode/unicode.dart' show stringWidth;

/// A bordered container widget with optional title, padding, and child.
class Box extends Widget {
  /// Optional child widget inside the border.
  final Widget? child;
  /// The border line style.
  final BorderStyle borderStyle;
  /// Internal padding applied inside the border.
  final Insets padding;
  /// Optional title text on the top border.
  final String? title;
  /// Style for the title text.
  final TextStyle? titleStyle;
  /// Style for border characters and content text.
  final TextStyle? borderTextStyle;

  Box({
    this.child,
    this.borderStyle = BorderStyle.single,
    this.padding = const Insets(0, 0, 0, 0),
    this.title,
    this.titleStyle,
    this.borderTextStyle,
  });

  int get _borderWidth => 1;
  int get _horizontalBorder => _borderWidth * 2;
  int get _verticalBorder => _borderWidth * 2;

  Size? _lastLayoutSize;

  @override
  Size layout(Constraints constraints) {
    final availW =
        (constraints.maxWidth - _horizontalBorder - padding.horizontal).clamp(
          0,
          constraints.maxWidth,
        );
    final availH = (constraints.maxHeight - _verticalBorder - padding.vertical)
        .clamp(0, constraints.maxHeight);

    Size childSize;
    if (child != null) {
      childSize = child!.layout(
        Constraints(
          minWidth: 0,
          maxWidth: availW,
          minHeight: 0,
          maxHeight: availH,
        ),
      );
    } else {
      childSize = const Size(0, 0);
    }

    final totalW = childSize.width + _horizontalBorder + padding.horizontal;
    final totalH = childSize.height + _verticalBorder + padding.vertical;

    final result = Size(
      totalW.clamp(constraints.minWidth, constraints.maxWidth),
      totalH.clamp(constraints.minHeight, constraints.maxHeight),
    );
    _lastLayoutSize = result;
    return result;
  }

  @override
  void paint(PaintingContext context) {
    final size = _lastLayoutSize!;
    final rect = Rect(
      context.offsetX,
      context.offsetY,
      size.width,
      size.height,
    );

    _drawBorder(context, rect);

    if (child != null) {
      child!.paint(
        context.child(
          _borderWidth + padding.left,
          _borderWidth + padding.top,
          style: borderTextStyle,
        ),
      );
    }
  }

  /// Draws the border characters on the surface.
  void _drawBorder(PaintingContext context, Rect rect) {
    final chars = _borderChars();
    final s = borderTextStyle ?? TextStyle.empty;
    final left = rect.left;
    final top = rect.top;
    final right = left + rect.width - 1;
    final bottom = top + rect.height - 1;
    final w = rect.width;
    final h = rect.height;
    final surface = context.surface;

    if (w < 2 || h < 2) return;

    surface.putChar(left, top, chars[2], s);
    surface.putChar(right, top, chars[3], s);
    surface.putChar(left, bottom, chars[4], s);
    surface.putChar(right, bottom, chars[5], s);

    for (var col = left + 1; col < right; col++) {
      surface.putChar(col, top, chars[1], s);
      if (bottom > top) surface.putChar(col, bottom, chars[1], s);
    }

    for (var row = top + 1; row < bottom; row++) {
      surface.putChar(left, row, chars[0], s);
      if (right > left) surface.putChar(right, row, chars[0], s);
    }

    if (title != null && title!.isNotEmpty && w > 2) {
      final titleW = stringWidth(title!);
      final titleX = left + 1 + ((w - 2) - titleW) ~/ 2;
      if (titleX + titleW <= right && titleX > left) {
        surface.putText(titleX, top, title!, titleStyle ?? s);
      }
    }
  }

  /// Returns the border character set for the current style.
  String _borderChars() {
    return switch (borderStyle) {
      BorderStyle.single => Defaults.borderSingle,
      BorderStyle.double => Defaults.borderDouble,
      BorderStyle.rounded => Defaults.borderRounded,
      BorderStyle.thick => Defaults.borderThick,
    };
  }
}
