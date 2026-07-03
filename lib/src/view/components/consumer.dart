import 'package:meta/meta.dart' show immutable, internal;
import 'package:riverpod/misc.dart' show ProviderListenable;
import 'package:riverpod/riverpod.dart' show ProviderSubscription;

import '../../engine/cell_buffer_builder.dart' show CellBufferBuilder;
import '../../models/constraints.dart' show Constraints;
import '../../models/offset.dart' show Offset;
import '../context.dart' show Context;
import '../element.dart' show Element;
import '../widget.dart' show Widget;
import '../widget_ref.dart' show WidgetRef;

/// Builds a widget subtree while reading providers through [ref].
///
/// Mirrors flutter_riverpod: hands [builder] a [WidgetRef] for any provider.
typedef ConsumerBuilder = Widget Function(Context context, WidgetRef ref);

/// A widget that reads Riverpod providers and rebuilds its subtree.
///
/// [builder]'s widget is the only child; Consumer owns no render object.
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

/// Transparent proxy element for a [Consumer]; owns no render object.
///
/// Compiles [Consumer.builder] into a child; [watch] calls [markNeedsBuild].
@internal
class ConsumerElement extends Element implements WidgetRef {
  /// Creates an element for [widget].
  ConsumerElement({required Consumer super.widget, required super.context});

  /// The [Consumer] widget this element represents.
  Consumer get _widget => widget as Consumer;

  /// The child element produced by [Consumer.builder].
  Element? _child;

  /// [watch] subscriptions keyed by listened provider; cancelled in [dispose].
  final Map<ProviderListenable<dynamic>, ProviderSubscription<dynamic>>
      _dependencies =
      <ProviderListenable<dynamic>, ProviderSubscription<dynamic>>{};

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
  void dispose() {
    for (final subscription in _dependencies.values) {
      subscription.close();
    }
    _dependencies.clear();
    super.dispose();
  }

  @override
  T read<T>(ProviderListenable<T> provider) => context.read(provider);

  @override
  T watch<T>(ProviderListenable<T> provider) {
    _dependencies.putIfAbsent(
      provider,
      () => context.container.listen<T>(
        provider,
        (_, _) => markNeedsBuild(),
      ),
    );
    return context.read(provider);
  }
}