import 'package:meta/meta.dart' show internal;

/// Immutable guard: throws [StateError] on use-after-dispose.
@internal
extension type const Disposed._(bool _isDisposed) {
  /// Permit operations; not yet disposed.
  const Disposed({bool isDisposed = false}) : _isDisposed = isDisposed;

  /// Throws [StateError] with [message] if already disposed.
  void check({String? message}) {
    if (_isDisposed) throw StateError(message ?? 'Disposed');
  }

  /// Whether this guard is in a disposed state.
  bool get safeCheck => _isDisposed;
}
