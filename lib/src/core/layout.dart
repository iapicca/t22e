import '../well_known.dart' show WellKnown;

/// Layout constraints: min/max width and height a widget can occupy
class Constraints {
  /// Minimum allowed width
  final int minWidth;
  /// Maximum allowed width
  final int maxWidth;
  /// Minimum allowed height
  final int minHeight;
  /// Maximum allowed height
  final int maxHeight;

  const Constraints({
    this.minWidth = 0,
    this.maxWidth = WellKnown.unbounded,
    this.minHeight = 0,
    this.maxHeight = WellKnown.unbounded,
  });

  /// Tight constraints: forces the widget to be exactly (width, height)
  const Constraints.tight(int width, int height)
      : minWidth = width,
        maxWidth = width,
        minHeight = height,
        maxHeight = height;

  /// Whether min and max are equal (tight fit)
  bool get isTight => minWidth == maxWidth && minHeight == maxHeight;

  /// Whether maxWidth or maxHeight is unbounded
  bool get isUnbounded =>
      maxWidth == WellKnown.unbounded || maxHeight == WellKnown.unbounded;

  /// Clamps a size to these constraints
  Size constrain(Size size) {
    return Size(
      size.width.clamp(minWidth, maxWidth),
      size.height.clamp(minHeight, maxHeight),
    );
  }

  Constraints multiply(double factor) {
    return Constraints(
      minWidth: (minWidth * factor).round(),
      maxWidth: (maxWidth * factor).round(),
      minHeight: (minHeight * factor).round(),
      maxHeight: (maxHeight * factor).round(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Constraints &&
          minWidth == other.minWidth &&
          maxWidth == other.maxWidth &&
          minHeight == other.minHeight &&
          maxHeight == other.maxHeight);

  @override
  int get hashCode => Object.hash(minWidth, maxWidth, minHeight, maxHeight);

  @override
  String toString() =>
      'Constraints($minWidth≤w≤$maxWidth, $minHeight≤h≤$maxHeight)';
}

/// A width × height size, used for widget layout and measurement
class Size {
  final int width;
  final int height;

  const Size(this.width, this.height);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Size && width == other.width && height == other.height);

  @override
  int get hashCode => Object.hash(width, height);

  @override
  String toString() => 'Size($width, $height)';
}

/// An item in a flex layout: either fixed size or flexible with a flex factor
class LayoutItem {
  final int? fixedSize;
  final int flex;

  const LayoutItem({this.fixedSize, this.flex = 1});

  bool get isFlexible => fixedSize == null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LayoutItem &&
          fixedSize == other.fixedSize &&
          flex == other.flex);

  @override
  int get hashCode => Object.hash(fixedSize, flex);

  @override
  String toString() =>
      isFlexible ? 'LayoutItem(flex:$flex)' : 'LayoutItem(fixed:$fixedSize)';
}

List<int> _splitSpace(int total, List<LayoutItem> items, int gap) {
  if (items.isEmpty) return [];
  if (items.length == 1) {
    final item = items[0];
    return [item.isFlexible ? total : item.fixedSize!];
  }

  final fixedSum =
      items.fold<int>(0, (sum, item) => sum + (item.fixedSize ?? 0));
  final gapSum = (items.length - 1) * gap;
  var remaining = total - fixedSum - gapSum;

  if (remaining <= 0) {
    return items.map((item) => item.isFlexible ? 1 : item.fixedSize!).toList();
  }

  final flexSum =
      items.fold<int>(0, (sum, item) => sum + (item.isFlexible ? item.flex : 0));

  if (flexSum == 0) {
    return items.map((item) => item.fixedSize!).toList();
  }

  final result = List<int>.filled(items.length, 0);
  var allocated = 0;

  for (var i = 0; i < items.length; i++) {
    final item = items[i];
    if (!item.isFlexible) {
      result[i] = item.fixedSize!;
      allocated += result[i];
      continue;
    }
    final raw = (remaining * item.flex) ~/ flexSum;
    result[i] = raw;
    allocated += raw;
  }

  var remainder = remaining - (allocated - fixedSum);
  for (var i = 0; i < items.length && remainder > 0; i++) {
    if (items[i].isFlexible) {
      result[i]++;
      remainder--;
    }
  }

  return result;
}

/// Splits available horizontal space among layout items by flex
List<int> splitHorizontal(int total, List<LayoutItem> items, int gap) =>
    _splitSpace(total, items, gap);

/// Splits available vertical space among layout items by flex
List<int> splitVertical(int total, List<LayoutItem> items, int gap) =>
    _splitSpace(total, items, gap);
