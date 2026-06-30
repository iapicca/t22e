import 'package:meta/meta.dart';

/// Signature for initialized-state checks with an optional message.
typedef CheckInitialized = void Function({String? message});

/// Immutable guard: throws [StateError] on use-before-init.
@internal
extension type const Initialized._(bool _isInitialized) {
  const Initialized({bool isInitialized = false})
    : _isInitialized = isInitialized;

  /// Throws [StateError] if not yet initialized.
  void check({String? message}) {
    if (!_isInitialized) throw StateError(message ?? 'Not initialized');
  }

  /// Whether this guard is in an initialized state.
  bool get safeCheck => _isInitialized;
}

/// Mixin providing guarded initialization lifecycle for resource classes.
///
/// Call [checkInit] before public methods; subclasses MUST call super.init.
@internal
mixin InitMixin {
  var _initialized = const Initialized();

  bool get isInitialized => _initialized.safeCheck;

  @protected
  CheckInitialized get checkInit => _initialized.check;

  @mustCallSuper
  void init({String? message, bool throwIfExists = false}) {
    if (_initialized.safeCheck) {
      if (throwIfExists) {
        throw StateError(message ?? 'Already initialized');
      }
      return;
    }
    _initialized = const Initialized(isInitialized: true);
  }
}
