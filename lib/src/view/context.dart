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
  ///
  /// The optional [requestFrame] callback is invoked by elements that need a
  /// rebuild (see `Element.markNeedsBuild`); when omitted, provider-driven
  /// rebuilds are not wired and widgets only update on an explicit recompile.
  const Context(this.container, {this._requestFrame});

  /// The Riverpod container used to read providers.
  final ProviderContainer container;

  /// Frame-request hook set by the host binding that drives re-renders.
  final void Function()? _requestFrame;

  /// Reads the current value of [provider] from the underlying container.
  ///
  /// This performs a one-shot read; it never subscribes. Use `WidgetRef.watch`
  /// from a `Consumer` to register for rebuild-on-change.
  T read<T>(ProviderListenable<T> provider) => container.read(provider);

  /// Requests a new frame from the host binding, if one is wired.
  ///
  /// Called by `Element.markNeedsBuild` when a watched provider changes. It is
  /// a no-op when no host binding supplied [requestFrame] at construction.
  void requestFrame() => _requestFrame?.call();
}