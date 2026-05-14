import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:protocol/protocol.dart' show Defaults;

part 'layout.freezed.dart';

/// Layout constraints: min/max width and height bounds.
@freezed
abstract class Constraints with _$Constraints {
  const Constraints._();

  const factory Constraints({
    @Default(0) int minWidth,
    @Default(Defaults.unbounded) int maxWidth,
    @Default(0) int minHeight,
    @Default(Defaults.unbounded) int maxHeight,
  }) = _Constraints;

  factory Constraints.tight(int width, int height) {
    return Constraints(
      minWidth: width,
      maxWidth: width,
      minHeight: height,
      maxHeight: height,
    );
  }

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
}

/// A simple width × height size.
@freezed
abstract class Size with _$Size {
  const factory Size(int width, int height) = _Size;
}

/// Describes a flex item with optional fixed size and flex factor.
@freezed
abstract class LayoutItem with _$LayoutItem {
  const LayoutItem._();

  const factory LayoutItem({
    int? fixedSize,
    @Default(1) int flex,
  }) = _LayoutItem;

  /// True if this item stretches to fill available space.
  bool get isFlexible => fixedSize == null;
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
