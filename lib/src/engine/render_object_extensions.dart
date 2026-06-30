import 'package:meta/meta.dart' show internal;

import 'render_object.dart' show RenderObject;

/// Traversal helpers for the render tree.
@internal
extension RenderObjectTraversal on RenderObject {
  /// All descendants of this render object in depth-first order.
  Iterable<RenderObject> get descendants sync* {
    final children = <RenderObject>[];
    visitChildren(children.add);
    for (final child in children) {
      yield child;
      yield* child.descendants;
    }
  }
}
