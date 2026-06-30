import 'package:riverpod_annotation/riverpod_annotation.dart'
    show ProviderListenable;

/// Read handle to the Riverpod provider container, passed to [Consumer]
/// builders.
///
/// This mirrors `flutter_riverpod`'s `WidgetRef`: widgets never touch the
/// [ProviderContainer] directly, they go through a `WidgetRef`. The concrete
/// implementation is the consumer's element, which is marked `@internal`.
abstract class WidgetRef {
  /// Creates a widget ref.
  const WidgetRef();

  /// Reads the current value of [provider] without subscribing to changes.
  T read<T>(ProviderListenable<T> provider);

  /// Reads [provider] and registers it for rebuild-on-change.
  ///
  /// Subscribes via `ProviderContainer.listen` so that, when [provider]
  /// notifies, the owning element is marked dirty and a new frame is
  /// requested, mirroring `flutter_riverpod`'s `ConsumerStatefulElement.watch`.
  /// A provider watched more than once in a single build pass is subscribed at
  /// most once.
  T watch<T>(ProviderListenable<T> provider);
}