import 'package:riverpod_annotation/riverpod_annotation.dart'
    show ProviderListenable;

/// Read handle to the Riverpod provider container, passed to [Consumer]
/// builders.
///
/// This mirrors `flutter_riverpod`'s `WidgetRef`: widgets never touch the
/// [ProviderContainer] directly, they go through a `WidgetRef`. The concrete
/// implementation is the consumer's element, which is marked `@internal`.
///
/// `watch` currently behaves like [read] for this milestone; the subscription
/// + `markNeedsBuild` technique that drives automatic rebuilds is added in a
/// later milestone (see `tasks/milestone-6/NOTE-consumer-rebuild-wiring.md`).
abstract class WidgetRef {
  /// Creates a widget ref.
  const WidgetRef();

  /// Reads the current value of [provider] without subscribing to changes.
  T read<T>(ProviderListenable<T> provider);

  /// Reads [provider] and registers it for rebuild-on-change.
  ///
  /// For this milestone this is equivalent to [read]. The later-milestone
  /// implementation subscribes via `container.listen` and marks the owning
  /// element dirty when the provider notifies, exactly like
  /// `flutter_riverpod`'s `ConsumerStatefulElement.watch`.
  T watch<T>(ProviderListenable<T> provider);
}