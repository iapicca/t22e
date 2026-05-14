import 'package:protocol/protocol.dart' show Defaults;

/// Layout constraints: min/max width and height bounds.
class Constraints {
  /// Minimum allowed width.
  final int minWidth;
  /// Maximum allowed width.
  final int maxWidth;
  /// Minimum allowed height.
  final int minHeight;
  /// Maximum allowed height.
  final int maxHeight;

  const Constraints({
    this.minWidth = 0,
    this.maxWidth = Defaults.unbounded,
    this.minHeight = 0,
    this.maxHeight = Defaults.unbounded,
  });

  /// Tight constraints forcing an exact size.
  const Constraints.tight(int width, int height)
    : minWidth = width,
      maxWidth = width,
      minHeight = height,
      maxHeight = height;

  /// True if width and height are both tightly constrained.
  bool get isTight => minWidth == maxWidth && minHeight == maxHeight;

  /// True if either maxWidth or maxHeight is unbounded.
  bool get isUnbounded =>
      maxWidth == Defaults.unbounded || maxHeight == Defaults.unbounded;

  /// Clamps a size to fit within these constraints.
  Size constrain(Size size) {
    return Size(
      size.width.clamp(minWidth, maxWidth),
      size.height.clamp(minHeight, maxHeight),
    );
  }

  /// Scales all constraints by a factor.
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

/// A simple width × height size.
class Size {
  /// Width in columns.
  final int width;
  /// Height in rows.
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

/// Describes a flex item with optional fixed size and flex factor.
class LayoutItem {
  /// Fixed size (pixels/columns), or null for flexible.
  final int? fixedSize;
  /// Flex factor when distributing remaining space.
  final int flex;

  const LayoutItem({this.fixedSize, this.flex = 1});

  /// True if this item stretches to fill available space.
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

/// Distributes available space among items using a flexbox-like algorithm.
List<int> _splitSpace(int total, List<LayoutItem> items, int gap) {
  if (items.isEmpty) return [];
  if (items.length == 1) {
    final item = items[0];
    return [item.isFlexible ? total : item.fixedSize!];
  }

  final fixedSum = items.fold<int>(
    0,
    (sum, item) => sum + (item.fixedSize ?? 0),
  );
  final gapSum = (items.length - 1) * gap;
  var remaining = total - fixedSum - gapSum;

  if (remaining <= 0) {
    return items.map((item) => item.isFlexible ? 1 : item.fixedSize!).toList();
  }

  final flexSum = items.fold<int>(
    0,
    (sum, item) => sum + (item.isFlexible ? item.flex : 0),
  );

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

/// Distributes available horizontal space using flexbox rules.
List<int> splitHorizontal(int total, List<LayoutItem> items, int gap) =>
    _splitSpace(total, items, gap);

/// Distributes available vertical space using flexbox rules.
List<int> splitVertical(int total, List<LayoutItem> items, int gap) =>
    _splitSpace(total, items, gap);
