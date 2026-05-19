import 'package:meta/meta.dart';

import 'disposable.dart';

/// Observable object that manages a list of listeners and notifies them
/// of changes. Mirrors Flutter's [ChangeNotifier] with structured disposal.
class ChangeNotifier with Disposable {
  final List<VoidCallback> _listeners = [];

  /// Whether any listeners are currently registered.
  bool get hasListeners => _listeners.isNotEmpty;

  /// Registers a [listener] to be notified on changes.
  /// Pass [message] to customize the disposed error.
  void addListener(VoidCallback listener, {String? message}) {
    check(message: message);
    if (!_listeners.contains(listener)) _listeners.add(listener);
  }

  /// Unregisters a previously added [listener].
  void removeListener(VoidCallback listener, {String? message}) {
    check(message: message);
    _listeners.remove(listener);
  }

  /// Notifies all registered listeners.
  /// The list is copied before iteration to guard against mutation.
  void notifyListeners({String? message}) {
    check(message: message);
    for (final listener in _listeners.toList()) {
      listener();
    }
  }

  /// Clears all listeners and marks as disposed.
  @mustCallSuper
  @override
  void dispose(String? message) {
    super.dispose(message);
    _listeners.clear();
  }
}
