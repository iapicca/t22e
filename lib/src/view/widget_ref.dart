import 'package:riverpod_annotation/riverpod_annotation.dart'
    show ProviderListenable;

/// Read handle to Riverpod providers passed to [Consumer] builders.
///
/// Mirrors flutter_riverpod's `WidgetRef`: widgets never touch the container.
abstract class WidgetRef {
  /// Creates a widget ref.
  const WidgetRef();

  /// Reads the current value of [provider] without subscribing to changes.
  T read<T>(ProviderListenable<T> provider);

  /// Reads [provider] and rebuilds this subtree when it changes.
  ///
  /// Mirrors flutter_riverpod's `WidgetRef.watch`; one subscription per build.
  T watch<T>(ProviderListenable<T> provider);
}