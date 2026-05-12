import '../widget.dart' show Widget, PaintingContext;
import '../enums.dart' show MainAxisAlignment, CrossAxisAlignment;
import '../../core/layout.dart' show Constraints, Size, LayoutItem, splitVertical;

/// A widget that lays out its children vertically in a column
class Column extends Widget {
  final List<Widget> children;
  final int gap;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  Column({
    required this.children,
    this.gap = 0,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  List<int>? _childPositions;
  List<Size>? _childSizes;
  int _totalWidth = 0;
  int _totalHeight = 0;
  int _parentCrossSize = 0;

  @override
  Size layout(Constraints constraints) {
    _childPositions = [];
    _childSizes = [];
    _parentCrossSize = constraints.maxWidth;

    final availW = constraints.maxWidth;
    final availH = constraints.maxHeight;

    // First pass: measure all children
    final measured = <Size>[];
    final items = <LayoutItem>[];
    var fixedSum = 0;

    for (final child in children) {
      final looseSize = child.layout(Constraints(
        maxWidth: availW,
        maxHeight: availH,
      ));
      measured.add(looseSize);

      if (looseSize.height >= availH && availH > 0) {
        items.add(const LayoutItem(flex: 1));
      } else {
        items.add(LayoutItem(fixedSize: looseSize.height));
        fixedSum += looseSize.height;
      }
    }

    // Distribute vertical space
    final gapSum = gap * (children.length - 1);
    final remaining = availH - fixedSum - gapSum;
    List<int> heights;

    if (remaining > 0) {
      heights = splitVertical(remaining, items.where((item) => item.isFlexible).toList(), 0);
      var hi = 0;
      var finalHeights = <int>[];
      for (final item in items) {
        if (item.isFlexible) {
          finalHeights.add(heights[hi]);
          hi++;
        } else {
          finalHeights.add(item.fixedSize!);
        }
      }
      heights = finalHeights;
    } else {
      heights = items.map((item) => item.fixedSize ?? 0).toList();
    }

    // Second pass: tight height, measured width
    var yOffset = _mainAxisOffset(heights, availH);
    var maxChildW = 0;

    for (var i = 0; i < children.length; i++) {
      final h = heights[i];
      final childW = measured[i].width;
      final childConstraints = Constraints(
        minWidth: childW, maxWidth: childW,
        minHeight: h, maxHeight: h,
      );
      final finalSize = children[i].layout(childConstraints);
      _childSizes!.add(finalSize);
      _childPositions!.add(yOffset);
      yOffset += h + gap;
      if (finalSize.width > maxChildW) maxChildW = finalSize.width;
    }

    _totalHeight = heights.fold(0, (a, b) => a + b) + gapSum;
    _totalWidth = maxChildW;

    return Size(
      _totalWidth.clamp(constraints.minWidth, constraints.maxWidth),
      _totalHeight.clamp(constraints.minHeight, constraints.maxHeight),
    );
  }

  int _mainAxisOffset(List<int> heights, int parentHeight) {
    final totalContent = heights.fold(0, (a, b) => a + b) + gap * (children.length - 1);
    return switch (mainAxisAlignment) {
      MainAxisAlignment.start => 0,
      MainAxisAlignment.center => (parentHeight - totalContent) ~/ 2,
      MainAxisAlignment.end => parentHeight - totalContent,
      MainAxisAlignment.spaceBetween || MainAxisAlignment.spaceAround => 0,
    };
  }

  @override
  void paint(PaintingContext context) {
    if (_childPositions == null || _childSizes == null) return;

    for (var i = 0; i < children.length; i++) {
      final y = _childPositions![i];
      final childSize = _childSizes![i];
      final x = _crossAxisOffset(childSize.width, _totalWidth);
      children[i].paint(context.child(x, y));
    }
  }

  int _crossAxisOffset(int childWidth, int parentWidth) {
    final pSize = _parentCrossSize;
    return switch (crossAxisAlignment) {
      CrossAxisAlignment.start => 0,
      CrossAxisAlignment.center => (pSize - childWidth) ~/ 2,
      CrossAxisAlignment.end => pSize - childWidth,
      CrossAxisAlignment.stretch => 0,
    };
  }
}
