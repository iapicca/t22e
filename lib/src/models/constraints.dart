import 'package:freezed_annotation/freezed_annotation.dart';

import 'size.dart';

part 'constraints.freezed.dart';

/// Immutable bounds describing the sizes a widget may occupy.
@freezed
@internal
abstract class Constraints with _$Constraints {
  /// Creates constraints with the given min and max bounds.
  const factory Constraints({
    required int minWidth,
    required int maxWidth,
    required int minHeight,
    required int maxHeight,
  }) = _Constraints;

  /// Constraints that force exactly [size].
  factory Constraints.tight(Size size) => Constraints(
    minWidth: size.width,
    maxWidth: size.width,
    minHeight: size.height,
    maxHeight: size.height,
  );

  /// Constraints that allow any size up to [size].
  factory Constraints.loose(Size size) => Constraints(
    minWidth: 0,
    maxWidth: size.width,
    minHeight: 0,
    maxHeight: size.height,
  );
}
