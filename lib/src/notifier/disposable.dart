import 'package:meta/meta.dart';

import 'disposed.dart';

/// Signature for callbacks with no arguments or return value.
typedef VoidCallback = void Function();

/// Signature for disposed-state checks with an optional message.
typedef CheckDisposed = void Function({String? message});

/// Mixin providing guarded disposal lifecycle for resource-bearing classes.
///
/// Call [check] before public methods; subclasses MUST call super.dispose.
@internal
mixin Disposable {
  var _disposed = const Disposed();

  /// Whether this object has been disposed.
  bool get isDisposed => _disposed.safeCheck;

  /// Guard: throws [StateError] if disposed.
  @protected
  CheckDisposed get check => _disposed.check;

  /// Marks as disposed, idempotent; call [super.dispose] in overrides.
  @mustCallSuper
  void dispose({String? message}) {
    check(message: message);
    _disposed = const Disposed(isDisposed: true);
  }
}
