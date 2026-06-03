import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'ffi_raw_backend.dart';
import 'io_raw_backend.dart';
import 'runner.dart';
import 'terminal_io.dart';
import 'system_io.dart';
import 'native_io.dart';
import 'termios_bindings.dart';

part 'providers.g.dart';

/// Factory provider that creates a [SystemIo] managed by Riverpod.
@riverpod
SystemIo systemIo(Ref ref) => const NativeIo();

/// Factory provider that creates [TermiosBindings] managed by Riverpod.
@riverpod
TermiosBindings termiosBindings(Ref ref) {
  final io = ref.watch(systemIoProvider);
  return TermiosBindingsImpl.fromPlatformService(io);
}

/// Factory provider that creates a [TerminalIo] managed by Riverpod.
///
/// Example:
/// ```dart
/// final container = ProviderContainer();
/// final io = container.read(terminalIoProvider);
/// io.write('Hello');
/// container.dispose();
/// ```
@riverpod
TerminalIo terminalIo(Ref ref) {
  return TerminalIo(io: ref.watch(systemIoProvider));
}

/// Factory provider that creates an [IoRawModeBackend] managed by Riverpod.
///
/// Riverpod handles disposal automatically via [ref.onDispose].
///
/// Example:
/// ```dart
/// final container = ProviderContainer();
/// final backend = container.read(ioRawBackendProvider);
/// backend.enable();
/// container.dispose(); // automatically disables and disposes
/// ```
@riverpod
IoRawModeBackend ioRawBackend(Ref ref) {
  final backend = IoRawModeBackend(io: ref.watch(systemIoProvider));
  ref.onDispose(() {
    try {
      backend.dispose();
    } catch (_) {
      // dispose() calls disable() which may fail in non-terminal environments
    }
  });
  return backend;
}

/// Factory provider that creates a [FfiRawModeBackend] managed by Riverpod.
///
/// Riverpod handles disposal automatically via [ref.onDispose].
///
/// Example:
/// ```dart
/// final container = ProviderContainer();
/// final backend = container.read(ffiRawBackendProvider);
/// backend.enable();
/// container.dispose(); // automatically disables and disposes
/// ```
@riverpod
FfiRawModeBackend ffiRawBackend(Ref ref) {
  final backend = FfiRawModeBackend(
    bindings: ref.watch(termiosBindingsProvider),
    io: ref.watch(systemIoProvider),
  );
  ref.onDispose(backend.dispose);
  return backend;
}

/// Factory provider that creates a [TerminalRunner] managed by Riverpod.
///
/// Riverpod handles disposal automatically via [ref.onDispose].
/// The runner is created with Ffi + Io backends.
///
/// Example:
/// ```dart
/// final container = ProviderContainer();
/// final runner = container.read(terminalRunnerProvider);
/// runner.runWithRawMode(() {
///   // ... application code
/// });
/// container.dispose(); // automatically exits raw mode and disposes
/// ```
@riverpod
TerminalRunner terminalRunner(Ref ref) {
  final runner = TerminalRunner(backends: [
    ref.watch(ffiRawBackendProvider),
    ref.watch(ioRawBackendProvider),
  ]);
  ref.onDispose(runner.dispose);
  return runner;
}
