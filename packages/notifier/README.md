# notifier

Observable objects with structured disposal lifecycle.

## Purpose

Provides the observable pattern with robust lifecycle management. Ensures
resources are properly cleaned up and methods aren't called at wrong stages.

## Exports

- **Disposable** mixin — `isDisposed`, `check` guard, `dispose()` method
- **Disposed** extension type — immutable guard throwing on use-after-dispose
- **InitMixin** mixin — `isInitialized`, `checkInit` guard, `init()` method
- **ChangeNotifier** — listener list with `addListener`, `removeListener`,
  `notifyListeners`
- **ValueNotifier\<T\>** — holds a single value, notifies on change

## Usage

Extend classes with `Disposable` for cleanup safety. Use `ChangeNotifier` or
`ValueNotifier` for observable state. Guards throw on use-before-init or
use-after-dispose.
