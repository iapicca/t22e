import 'package:riverpod/misc.dart' show ProviderListenable;
import 'package:riverpod/riverpod.dart' show ProviderContainer;

/// App context wrapping the active [ProviderContainer] for the whole tree.
///
/// Tree-local data (constraints, theme) deferred to a later widget context.
class Context {
  /// Creates an app context backed by [container].
  ///
  /// [requestFrame] drives provider rebuilds; omitted means not wired.
  const Context(this.container, {this._requestFrame});

  /// The Riverpod container used to read providers.
  final ProviderContainer container;

  /// Frame-request hook set by the host binding that drives re-renders.
  final void Function()? _requestFrame;

  /// Reads the current value of [provider] as a one-shot, never subscribing.
  ///
  /// Use `WidgetRef.listen` from a `Consumer` to register rebuild-on-change.
  T read<T>(ProviderListenable<T> provider) => container.read(provider);

  /// Requests a new frame from the host binding, if one is wired.
  ///
  /// Called by `Element.markNeedsBuild`; a no-op when no binding is wired.
  void requestFrame() => _requestFrame?.call();
}