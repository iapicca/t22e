import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:testing/testing.dart';

void main() {
  group('virtualTerminalProvider', () {
    test('creates a VirtualTerminal', () {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final terminal = container.read(virtualTerminalProvider);
      expect(terminal, isA<VirtualTerminal>());
    });

    test('can write to terminal', () {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final terminal = container.read(virtualTerminalProvider);
      expect(() => terminal.write('Hello'), returnsNormally);
    });

    test('can read plain text', () {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final terminal = container.read(virtualTerminalProvider);
      terminal.write('Hello');
      expect(terminal.plainText(), contains('Hello'));
    });
  });

  group('virtualTerminalWithSizeProvider', () {
    test('creates a VirtualTerminal with custom size', () {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final terminal = container.read(
        virtualTerminalWithSizeProvider(width: 40, height: 10),
      );
      expect(terminal.width, 40);
      expect(terminal.height, 10);
    });
  });

  group('widgetTesterProvider', () {
    test('creates a WidgetTester', () {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final tester = container.read(widgetTesterProvider);
      expect(tester, isA<WidgetTester>());
    });

    test('has a virtual terminal', () {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final tester = container.read(widgetTesterProvider);
      expect(tester.virtualTerminal, isA<VirtualTerminal>());
    });
  });
}
