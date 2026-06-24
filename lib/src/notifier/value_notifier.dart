import 'change_notifier.dart';

/// A [ChangeNotifier] that holds a single value and notifies listeners
/// whenever the value changes. Mirrors Flutter's [ValueNotifier].
class ValueNotifier<T> extends ChangeNotifier {
  T _value;

  /// Custom error message used when disposed checks fail.
  final String? _message;

  /// Creates a [ValueNotifier] wrapping [value].
  ValueNotifier(this._value, {this._message});

  /// The current value. Setting it notifies listeners only if changed.
  T get value => _value;

  /// Updates the value and notifies listeners if the new value differs.
  set value(T newValue) {
    check(message: _message);
    if (_value == newValue) return;
    _value = newValue;
    notifyListeners(message: _message);
  }
}
