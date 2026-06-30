import 'package:meta/meta.dart' show immutable, internal;
import 'package:riverpod_annotation/riverpod_annotation.dart'
    show ProviderListenable;

import '../../engine/cell_buffer_builder.dart' show CellBufferBuilder;
import '../../models/constraints.dart' show Constraints;
import '../../models/offset.dart' show Offset;
import '../context.dart' show Context;
import '../element.dart' show Element;
import '../widget.dart' show Widget;
import '../widget_ref.dart' show WidgetRef;

/// Builds a widget subtree while reading providers through [ref].
///
/// Mirrors `flutter_riverpod`'s `Consumer`: instead of taking a single
/// provider as a field, it hands a [WidgetRef] to [builder] so the builder
/// can read whichever providers it needs.
typedef ConsumerBuilder = Widget Function(Context context, WidgetRef ref);

/// A widget that reads Riverpod providers and rebuilds its subtree.
///
/// The [builder] receives a [WidgetRef] and should obtain provider values via
/// [WidgetRef.read] or [WidgetRef.watch]. The returned widget is compiled and
/// mounted as the consumer's only child; `Consumer` itself owns no
/// [RenderObject] and is transparent to layout and paint.
@immutable
class Consumer extends Widget {
  /// Creates a consumer that builds its subtree from [builder].
  const Consumer({required this.builder});

  /// Builds the subtree, reading providers through the supplied [WidgetRef].
  final ConsumerBuilder builder;

  @override
  ConsumerElement compile(Context context) =>
      ConsumerElement(widget: this, context: context);
}

/// Runtime element for a [Consumer].
///
/// It is a transparent proxy: it evaluates [Consumer.builder] with itself as
/// the [WidgetRef], compiles the returned widget into a single child element,
/// and delegates layout and paint to that child.
@internal
class ConsumerElement extends Element implements WidgetRef {
  /// Creates an element for [widget].
  ConsumerElement({required Consumer super.widget, required super.context});

  Consumer get _widget => widget as Consumer;

  /// The child element produced by [Consumer.builder].
  Element? _child;

  @override
  void mount(Element? parent) {
    super.mount(parent);
    final childWidget = _widget.builder(context, this);
    _child = childWidget.compile(context)..mount(this);
    children.add(_child!);
  }

  @override
  void layout(Constraints constraints) {
    final child = _child!;
    child.layout(constraints);
    size = child.size;
    offset = child.offset;
  }

  @override
  void paint(CellBufferBuilder buffer, Offset offset) {
    _child!.paint(buffer, offset + this.offset);
  }

  @override
  T read<T>(ProviderListenable<T> provider) => context.read(provider);

  @override
  T watch<T>(ProviderListenable<T> provider) => context.read(provider);
}