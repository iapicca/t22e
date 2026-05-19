# Private Named Parameters — TerminalRunner limitation

`TerminalRunner._backends` cannot use `this._backends` with a const default
because `FfiRawModeBackend()` is not a const constructor.

## Why FfiRawModeBackend can't be const

The constructor chain:
```
FfiRawModeBackend()
  → TermiosBindingsImpl.fromPlatformService(_io)
    → PlatformService(io: io).library
      → DynamicLibrary.open(...)  // FFI — inherently runtime
```

`DynamicLibrary.open` is a runtime FFI call. There's no way to make it const.

## What was done instead

- Removed the unused `io` parameter from `TerminalRunner` (no callers ever passed it)
- Inlined `FfiRawModeBackend()` and `IoRawModeBackend()` with their own defaults
- Removed the `SystemIo` import from runner.dart

The constructor remains in initializer-list form:
```dart
TerminalRunner({List<RawModeBackend>? backends})
  : _backends = backends ?? [FfiRawModeBackend(), IoRawModeBackend()];
```
