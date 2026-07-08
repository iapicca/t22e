import 'package:riverpod/riverpod.dart';
import 'package:t22e/t22e.dart';
import 'package:test/test.dart';

void main() {
  group('utf8DecoderProvider', () {
    test('returns utf8.decode as the default', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final decoder = container.read(utf8DecoderProvider);
      expect(decoder(<int>[0x41]), 'A');
      expect(decoder(<int>[0xC3, 0xA9]), 'é');
      expect(() => decoder(<int>[0xC3]), throwsFormatException);
    });

    test('can be overridden with a fake', () {
      String? fake(List<int> bytes) => '<${bytes.length}>';
      final container = ProviderContainer(
        overrides: [utf8DecoderProvider.overrideWithValue(fake)],
      );
      addTearDown(container.dispose);

      expect(container.read(utf8DecoderProvider), same(fake));
      expect(container.read(utf8DecoderProvider)(<int>[1, 2, 3]), '<3>');
    });

    test('ansiParserProvider wires the overridden decoder', () {
      var calls = 0;
      String? fake(List<int> bytes) {
        calls++;
        return 'X';
      }
      final container = ProviderContainer(
        overrides: [utf8DecoderProvider.overrideWithValue(fake)],
      );
      addTearDown(container.dispose);

      final parser = container.read(ansiParserProvider);
      final events = <InputEvent>[];
      parser.events.listen(events.add);
      parser.add(<int>[0x41]); // printable, triggers the decoder
      expect(calls, 1);
      expect(events, [const InputEvent.char(character: 'X')]);
    });
  });
}