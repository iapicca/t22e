import 'package:meta/meta.dart' show internal;

import 'constraints.dart' show Constraints;
import 'size.dart' show Size;

@internal
extension ConstraintExtensions on Constraints {
  Size constrain(Size size) => Size(
    size.width.clamp(minWidth, maxWidth),
    size.height.clamp(minHeight, maxHeight),
  );
}
