import 'package:riverpod/riverpod.dart';
import 'package:t22e/t22e.dart';
import 'package:test/test.dart';

void main() {
  group('IO providers', () {
    test('ansiParserProvider exposes an AnsiParser', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final parser = container.read(ansiParserProvider);

      expect(parser, isA<AnsiParser>());
    });
  });
}
