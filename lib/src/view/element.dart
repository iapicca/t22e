import 'package:meta/meta.dart' show internal;

import '../engine/cell_buffer_builder.dart' show CellBufferBuilder;
import '../models/constraints.dart' show Constraints;
import '../models/offset.dart' show Offset;
import '../models/size.dart' show Size;
import 'context.dart' show Context;
import 'widget.dart' show Widget;

/// Runtime representation of a [Widget].
@internal
abstract class Element {
  /// Creates an element for [widget] with [context].
  Element({required this.widget, required this.context});

  /// The widget this element represents.
  final Widget widget;

  /// The build context passed to descendant widgets.
  final Context context;

  /// The parent element, set during [mount].
  Element? parent;

  /// Child elements produced by this element.
  List<Element> children = <Element>[];

  /// The size computed during [layout].
  Size size = Size.zero;

  /// The offset assigned by the parent during [layout].
  Offset offset = const Offset(0, 0);

  /// Attaches this element to [parent].
  void mount(Element? parent) {
    this.parent = parent;
  }

  /// Computes [size] and [offset] under [constraints].
  void layout(Constraints constraints);

  /// Paints this element into [buffer] at [offset].
  void paint(CellBufferBuilder buffer, Offset offset);

  /// Marks this element as needing a rebuild and requests a new frame.
  ///
  /// The host binding coalesces multiple requests per event-loop turn.
  void markNeedsBuild() => context.requestFrame();

  /// Tears down this element and its children, releasing resources.
  ///
  /// Override to cancel owned subscriptions/listeners, then call super.dispose.
  void dispose() {
    for (final child in children) {
      child.dispose();
    }
    children.clear();
  }
}
