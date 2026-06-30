import 'package:riverpod/riverpod.dart' show ProviderContainer;
import 'package:riverpod_annotation/riverpod_annotation.dart'
    show ProviderListenable;

/// Application context that exposes Riverpod provider access during the
/// build pass.
///
/// This is the "app context": it wraps the active [ProviderContainer] and is
/// shared across the whole widget tree. Tree-local data (parent constraints,
/// theme, style) is intentionally not stored here yet; a separate widget
/// context can be introduced later without changing this surface.
class Context {
  /// Creates an app context backed by [container].
  const Context(this.container);

  /// The Riverpod container used to read providers.
  final ProviderContainer container;

  /// Reads the current value of [provider] from the underlying container.
  ///
  /// This performs a one-shot read. Provider-driven rebuilds are wired in a
  /// later milestone through `Consumer` / `WidgetRef.watch`; until then this
  /// method is the only way widgets obtain provider snapshots.
  T read<T>(ProviderListenable<T> provider) => container.read(provider);
}