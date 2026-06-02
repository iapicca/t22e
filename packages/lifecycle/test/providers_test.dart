import 'package:lifecycle/lifecycle.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';

void main() {
  group('altScreenManagerProvider', () {
    test('creates an AltScreenManager', () {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final manager = container.read(altScreenManagerProvider);
      expect(manager, isA<AltScreenManager>());
      expect(manager.isDisposed, isFalse);
    });

    test('disposes on container dispose', () {
      final container = ProviderContainer.test();
      final manager = container.read(altScreenManagerProvider);
      container.dispose();

      expect(manager.isDisposed, isTrue);
    });
  });

  group('terminalGuardProvider', () {
    test('creates a TerminalGuard', () {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final guard = container.read(terminalGuardProvider);
      expect(guard, isA<TerminalGuard>());
      expect(guard.isDisposed, isFalse);
    });

    test('disposes on container dispose', () {
      final container = ProviderContainer.test();
      final guard = container.read(terminalGuardProvider);
      container.dispose();

      expect(guard.isDisposed, isTrue);
    });

    test('can arm and restore', () {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final guard = container.read(terminalGuardProvider);
      guard.arm();
      expect(guard.isRestored, isFalse);
      guard.restore();
      expect(guard.isRestored, isTrue);
    });

    test('runGuarded restores after execution', () {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final guard = container.read(terminalGuardProvider);
      guard.arm();
      guard.runGuarded(() {
        expect(guard.isRestored, isFalse);
      });
      expect(guard.isRestored, isTrue);
    });
  });

  group('signalHandlerProvider', () {
    test('creates a SignalHandler', () {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final handler = container.read(
        signalHandlerProvider(onInterrupt: () {}),
      );
      expect(handler, isA<SignalHandler>());
      expect(handler.isDisposed, isFalse);
    });

    test('disposes on container dispose', () {
      final container = ProviderContainer.test();
      final handler = container.read(
        signalHandlerProvider(onInterrupt: () {}),
      );
      container.dispose();

      expect(handler.isDisposed, isTrue);
    });
  });
}
