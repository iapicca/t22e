import 'package:meta/meta.dart' show immutable, internal;

import '../../engine/render_root.dart' show RenderRoot;
import '../../models/size.dart' show Size;
import '../context.dart' show Context;
import '../single_child_render_object_element.dart'
    show SingleChildRenderObjectElement;
import '../widget.dart' show Widget;

/// Full-screen root widget that fills the terminal and hosts a single child.
@immutable
class Root extends Widget {
  /// Creates a root binding [child] to the full [terminalSize].
  const Root({required this.terminalSize, required this.child});

  /// The terminal size this root fills.
  final Size terminalSize;

  /// The single child widget hosted by this root.
  final Widget child;

  @override
  RootElement compile(Context context) =>
      RootElement(widget: this, context: context);
}

/// Runtime element that owns the [RenderRoot] for a [Root] widget.
@internal
class RootElement extends SingleChildRenderObjectElement {
  /// Creates an element for [widget].
  RootElement({required Root super.widget, required super.context});

  Root get _widget => widget as Root;

  @override
  Widget? get childWidget => _widget.child;

  @override
  RenderRoot createRenderObject() => RenderRoot();
}
