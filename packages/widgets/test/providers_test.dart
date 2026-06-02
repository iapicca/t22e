import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:widgets/widgets.dart';

void main() {
  group('everyCmdProvider', () {
    test('creates an EveryCmd', () {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final cmd = container.read(
        everyCmdProvider(const Duration(seconds: 1)),
      );
      expect(cmd, isA<EveryCmd>());
      expect(cmd.isDisposed, isFalse);
    });

    test('disposes on container dispose', () {
      final container = ProviderContainer.test();
      final cmd = container.read(
        everyCmdProvider(const Duration(seconds: 1)),
      );
      container.dispose();

      expect(cmd.isDisposed, isTrue);
    });

    test('can execute command', () {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final cmd = container.read(
        everyCmdProvider(const Duration(seconds: 1)),
      );
      expect(() => cmd.execute((_) {}), returnsNormally);
    });
  });
}
