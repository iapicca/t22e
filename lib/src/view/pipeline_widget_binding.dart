import 'package:meta/meta.dart' show internal;

import '../engine/pipeline.dart' show Pipeline;
import '../models/size.dart' show Size;
import 'components/root.dart' show Root;
import 'context.dart' show Context;
import 'render_object_element.dart' show RenderObjectElement;
import 'widget.dart' show Widget;

/// Build-pass bridge that drives a [Pipeline] from a declarative widget tree.
extension PipelineWidgetBinding on Pipeline {
  /// Builds [appChild] into a full-screen [Root] and renders one frame.
  ///
  /// Compiles the widget tree into an element tree, mounts it, and delegates
  /// to [Pipeline.render] for the layout, paint, diff, and flush passes.
  @internal
  void renderWidget(
    Widget appChild,
    Size terminalSize, {
    Context context = const Context(),
  }) {
    final root = Root(terminalSize: terminalSize, child: appChild);
    final element = root.compile(context)..mount(null);
    final renderRoot = (element as RenderObjectElement).renderObject;
    render(renderRoot, terminalSize);
  }
}
