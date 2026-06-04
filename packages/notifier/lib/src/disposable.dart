import 'package:meta/meta.dart';

import 'disposed.dart';

/// Signature for callbacks with no arguments or return value.
typedef VoidCallback = void Function();

/// Signature for disposed-state checks with an optional message.
typedef CheckDisposed = void Function({String? message});

/// Mixin providing guarded disposal lifecycle for resource-bearing classes.
///
/// Use [with Disposable] on any class that needs to prevent method calls
/// after disposal. Call [check] at the start of every public method.
///
/// Subclasses MUST call `super.dispose(message)` in their override.
mixin Disposable {
  var _disposed = const Disposed();

  /// Whether this object has been disposed.
  bool get isDisposed => _disposed.safeCheck;

  /// Guard: throws [StateError] if disposed. Call at the top of every
  /// public method that should be blocked after disposal.
  @protected
  CheckDisposed get check => _disposed.check;

  /// Marks as disposed, idempotent; call [super.dispose] in overrides.
  @mustCallSuper
  void dispose({String? message}) {
    check(message: message);
    _disposed = const Disposed(isDisposed: true);
  }
}
