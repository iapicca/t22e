import '../widget.dart' show Widget, PaintingContext;
import '../enums.dart' show MainAxisAlignment, CrossAxisAlignment;
import 'package:core/core.dart'
    show Constraints, Size, LayoutItem, splitHorizontal;

/// Lays out children horizontally with flexbox-like distribution.
class Row extends Widget {
  /// Children placed left to right.
  final List<Widget> children;
  /// Gap in cells between children.
  final int gap;
  /// Main axis alignment (horizontal).
  final MainAxisAlignment mainAxisAlignment;
  /// Cross axis alignment (vertical).
  final CrossAxisAlignment crossAxisAlignment;

  Row({
    required this.children,
    this.gap = 0,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  List<int>? _childPositions;
  List<Size>? _childSizes;
  int _totalHeight = 0;
  int _totalWidth = 0;
  int _parentCrossSize = 0;

  @override
  Size layout(Constraints constraints) {
    _childPositions = [];
    _childSizes = [];
    _parentCrossSize = constraints.maxHeight;

    final availW = constraints.maxWidth;
    final availH = constraints.maxHeight;

    final measured = <Size>[];
    final items = <LayoutItem>[];
    var fixedSum = 0;

    for (final child in children) {
      final looseSize = child.layout(
        Constraints(maxWidth: availW, maxHeight: availH),
      );
      measured.add(looseSize);

      if (looseSize.width >= availW && availW > 0) {
        items.add(const LayoutItem(flex: 1));
      } else {
        items.add(LayoutItem(fixedSize: looseSize.width));
        fixedSum += looseSize.width;
      }
    }

    final gapSum = gap * (children.length - 1);
    final remaining = availW - fixedSum - gapSum;
    List<int> widths;

    if (remaining > 0) {
      widths = splitHorizontal(
        remaining,
        items.where((item) => item.isFlexible).toList(),
        0,
      );
      var wi = 0;
      var finalWidths = <int>[];
      for (final item in items) {
        if (item.isFlexible) {
          finalWidths.add(widths[wi]);
          wi++;
        } else {
          finalWidths.add(item.fixedSize!);
        }
      }
      widths = finalWidths;
    } else {
      widths = items.map((item) => item.fixedSize ?? 0).toList();
    }

    var xOffset = _mainAxisOffset(widths, availW);
    var maxChildH = 0;

    for (var i = 0; i < children.length; i++) {
      final w = widths[i];
      final childH = measured[i].height;
      final childConstraints = Constraints(
        minWidth: w,
        maxWidth: w,
        minHeight: childH,
        maxHeight: childH,
      );
      final finalSize = children[i].layout(childConstraints);
      _childSizes!.add(finalSize);
      _childPositions!.add(xOffset);
      xOffset += w + gap;
      if (finalSize.height > maxChildH) maxChildH = finalSize.height;
    }

    _totalWidth = widths.fold(0, (a, b) => a + b) + gapSum;
    _totalHeight = maxChildH;

    return Size(
      _totalWidth.clamp(constraints.minWidth, constraints.maxWidth),
      _totalHeight.clamp(constraints.minHeight, constraints.maxHeight),
    );
  }

  /// Computes the main-axis offset based on alignment.
  int _mainAxisOffset(List<int> widths, int parentWidth) {
    final totalContent =
        widths.fold(0, (a, b) => a + b) + gap * (children.length - 1);
    return switch (mainAxisAlignment) {
      MainAxisAlignment.start => 0,
      MainAxisAlignment.center => (parentWidth - totalContent) ~/ 2,
      MainAxisAlignment.end => parentWidth - totalContent,
      MainAxisAlignment.spaceBetween || MainAxisAlignment.spaceAround => 0,
    };
  }

  @override
  void paint(PaintingContext context) {
    if (_childPositions == null || _childSizes == null) return;

    for (var i = 0; i < children.length; i++) {
      final x = _childPositions![i];
      final childSize = _childSizes![i];
      final y = _crossAxisOffset(childSize.height, _totalHeight);
      children[i].paint(context.child(x, y));
    }
  }

  /// Computes the cross-axis offset based on alignment.
  int _crossAxisOffset(int childHeight, int parentHeight) {
    final pSize = _parentCrossSize;
    return switch (crossAxisAlignment) {
      CrossAxisAlignment.start => 0,
      CrossAxisAlignment.center => (pSize - childHeight) ~/ 2,
      CrossAxisAlignment.end => pSize - childHeight,
      CrossAxisAlignment.stretch => 0,
    };
  }
}
