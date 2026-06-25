import 'render_object.dart' show RenderObject;
import 'render_root.dart' show RenderRoot;

/// Helpers for attaching children to a [RenderRoot].
extension RenderRootBinding on RenderRoot {
  /// Attaches [child] to this root and returns the root for chaining.
  RenderRoot attach(RenderObject child) => this..child = child;
}
