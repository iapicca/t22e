import 'package:meta/meta.dart' show internal;

import 'constraints.dart' show Constraints;
import 'size.dart' show Size;

/// Layout helpers applied to [Constraints].
@internal
extension ConstraintExtensions on Constraints {
  /// Clamps [size] to the min/max bounds of these constraints.
  /// TODO shouldn't this be named clamp?
  Size constrain(Size size) => Size(
    size.width.clamp(minWidth, maxWidth),
    size.height.clamp(minHeight, maxHeight),
  );
}
