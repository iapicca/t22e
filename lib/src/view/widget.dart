import 'package:meta/meta.dart' show immutable, internal;

import 'context.dart' show Context;
import 'element.dart' show Element;

/// Immutable configuration for a piece of UI.
///
/// TODO: Equality and Key support are deferred. Identity equality is correct
/// for const widgets but not for value-equal non-const widgets.
@immutable
@internal
abstract class Widget {
  /// Creates a widget.
  const Widget();

  /// Compiles this widget into a runtime [Element].
  Element compile(Context context);
}
