import 'package:riverpod/riverpod.dart' show ProviderContainer;
import 'package:t22e/t22e.dart';
import 'package:test/test.dart';

void main() {
  group('public providers', () {
    test('terminalSizeProvider defaults to 80x24', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(terminalSizeProvider), const Size(80, 24));
    });

    test('terminalSizeProvider notifies watchers when set', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final sizes = <Size>[];
      container.listen<Size>(terminalSizeProvider, (_, value) => sizes.add(value));

      container.read(terminalSizeProvider.notifier).set(const Size(40, 10));

      expect(sizes, [const Size(40, 10)]);
      expect(container.read(terminalSizeProvider), const Size(40, 10));
    });

    test('contextProvider exposes a Context wrapping the active container', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final context = container.read(contextProvider);

      expect(context, isA<Context>());
      expect(
        context.read(terminalSizeProvider),
        container.read(terminalSizeProvider),
      );
    });
  });
}
