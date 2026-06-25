import 'package:meta/meta.dart' show internal;

import '../models/constraints.dart' show Constraints;
import '../models/offset.dart' show Offset;
import '../models/size.dart' show Size;
import 'cell_buffer_builder.dart' show CellBufferBuilder;

/// Data stored on a [RenderObject] by its parent.
@internal
abstract class ParentData {
  /// Called when this data is detached from its render object.
  void detach();
}

/// [ParentData] for box-model parents that position children with an offset.
@internal
class BoxParentData extends ParentData {
  /// The offset assigned by the parent.
  Offset offset;

  /// Creates parent data with the given [offset].
  BoxParentData({this.offset = const Offset(0, 0)});

  @override
  void detach() {}
}

/// Base class for nodes in the render tree.
@internal
abstract class RenderObject {
  /// The size computed during [layout].
  Size size = Size.zero;

  /// The parent render object, if any.
  RenderObject? parent;

  /// Data owned by [parent] that describes this object's slot and position.
  ParentData? parentData;

  /// The offset assigned by [parent], stored in [parentData].
  Offset get offset {
    final data = parentData;
    return data is BoxParentData ? data.offset : const Offset(0, 0);
  }

  /// Stores [value] in the attached [BoxParentData], if any.
  set offset(Offset value) {
    final data = parentData;
    if (data is BoxParentData) data.offset = value;
  }

  /// Computes [size] under [constraints] and returns it.
  Size layout(Constraints constraints) {
    performLayout(constraints);
    return size;
  }

  /// Subclass layout implementation.
  void performLayout(Constraints constraints);

  /// Paints this render object into [buffer] at the given [offset].
  void paint(CellBufferBuilder buffer, Offset offset);

  /// Calls [visitor] for every child render object.
  void visitChildren(void Function(RenderObject child) visitor);
}

/// Mixin for [RenderObject]s that have exactly one child.
@internal
mixin SingleChildRenderObject on RenderObject {
  RenderObject? _child;

  /// The single child of this render object.
  RenderObject? get child => _child;

  /// Attaches [value] as the single child, updating parent and parent data.
  set child(RenderObject? value) {
    if (_child == value) return;
    if (_child != null) {
      _child!.parentData?.detach();
      _child!.parentData = null;
      _child!.parent = null;
    }
    _child = value;
    if (_child != null) {
      _child!.parent = this;
      _child!.parentData = BoxParentData();
    }
  }

  @override
  void visitChildren(void Function(RenderObject child) visitor) {
    final child = _child;
    if (child != null) visitor(child);
  }
}
