import 'package:riverpod/riverpod.dart';
import 'package:terminal/terminal.dart';
import 'package:test/test.dart';

void main() {
  group('terminalIoProvider', () {
    test('creates a TerminalIo', () {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final io = container.read(terminalIoProvider);
      expect(io, isA<TerminalIo>());
    });

    test('can write to terminal', () {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final io = container.read(terminalIoProvider);
      expect(() => io.write('test'), returnsNormally);
    });
  });

  group('ioRawBackendProvider', () {
    test('creates an IoRawModeBackend', () {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final backend = container.read(ioRawBackendProvider);
      expect(backend, isA<IoRawModeBackend>());
      expect(backend.isDisposed, isFalse);
    });

    test('disposes on container dispose', () {
      final container = ProviderContainer.test();
      final backend = container.read(ioRawBackendProvider);
      try {
        container.dispose();
      } catch (_) {
        // dispose() calls disable() which may fail in non-terminal environments
      }

      expect(backend.isDisposed, isTrue);
    });
  });

  group('ffiRawBackendProvider', () {
    test('creates a FfiRawModeBackend', () {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final backend = container.read(ffiRawBackendProvider);
      expect(backend, isA<FfiRawModeBackend>());
      expect(backend.isDisposed, isFalse);
    });

    test('disposes on container dispose', () {
      final container = ProviderContainer.test();
      final backend = container.read(ffiRawBackendProvider);
      container.dispose();

      expect(backend.isDisposed, isTrue);
    });
  });

  group('terminalRunnerProvider', () {
    test('creates a TerminalRunner', () {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final runner = container.read(terminalRunnerProvider);
      expect(runner, isA<TerminalRunner>());
      expect(runner.isDisposed, isFalse);
      expect(runner.isRawMode, isFalse);
    });

    test('disposes on container dispose', () {
      final container = ProviderContainer.test();
      final runner = container.read(terminalRunnerProvider);
      container.dispose();

      expect(runner.isDisposed, isTrue);
    });
  });
}
