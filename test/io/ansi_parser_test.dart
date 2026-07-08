import 'dart:async';

import 'package:t22e/t22e.dart';
import 'package:test/test.dart';

void main() {
  group('AnsiParser', () {
    late AnsiParser parser;
    late List<InputEvent> events;

    setUp(() {
      parser = AnsiParser();
      events = <InputEvent>[];
      parser.events.listen(events.add);
    });

    tearDown(() => parser.dispose());

    test('emits CharEvent for plain ASCII characters', () async {
      parser.add([65, 66, 67]); // ABC
      await Future.microtask(() {});

      expect(events, [
        const InputEvent.char(character: 'A'),
        const InputEvent.char(character: 'B'),
        const InputEvent.char(character: 'C'),
      ]);
    });

    test('emits KeyEvent for arrow keys', () async {
      parser.add([0x1B, 0x5B, 0x41]); // ESC [ A
      parser.add([0x1B, 0x5B, 0x42]); // ESC [ B
      parser.add([0x1B, 0x5B, 0x43]); // ESC [ C
      parser.add([0x1B, 0x5B, 0x44]); // ESC [ D
      await Future.microtask(() {});

      expect(events, [
        const InputEvent.key(key: Key.up),
        const InputEvent.key(key: Key.down),
        const InputEvent.key(key: Key.right),
        const InputEvent.key(key: Key.left),
      ]);
    });

    test('emits KeyEvent for common control keys', () async {
      parser.add([0x09]); // tab
      parser.add([0x0D]); // enter
      parser.add([0x7F]); // backspace
      await Future.microtask(() {});

      expect(events, [
        const InputEvent.key(key: Key.tab),
        const InputEvent.key(key: Key.enter),
        const InputEvent.key(key: Key.backspace),
      ]);
    });

    test('emits KeyEvent for Ctrl+C and Ctrl+D', () async {
      parser.add([0x03, 0x04]);
      await Future.microtask(() {});

      expect(events, [
        const InputEvent.key(key: Key.ctrlC),
        const InputEvent.key(key: Key.ctrlD),
      ]);
    });

    test('emits KeyEvent.escape on dispose for trailing ESC', () async {
      parser.add([0x1B]);
      await Future.microtask(() {});
      expect(events, isEmpty);

      parser.dispose();
      await Future.microtask(() {});

      expect(events, [const InputEvent.key(key: Key.escape)]);
    });

    test('buffers incomplete CSI sequences across chunks', () async {
      parser.add([0x1B, 0x5B]);
      await Future.microtask(() {});
      expect(events, isEmpty);

      parser.add([0x41]);
      await Future.microtask(() {});

      expect(events, [const InputEvent.key(key: Key.up)]);
    });

    test('emits UnknownEvent for unrecognized sequences', () async {
      parser.add([0x1B, 0x5B, 0x5A]); // ESC [ Z (undefined)
      await Future.microtask(() {});

      expect(events, [
        const InputEvent.unknown(raw: [0x1B, 0x5B, 0x5A]),
      ]);
    });

    test('emits CharEvent for multi-byte UTF-8 characters', () async {
      // UTF-8 for 'é' (U+00E9).
      parser.add([0xC3, 0xA9]);
      await Future.microtask(() {});

      expect(events, [const InputEvent.char(character: 'é')]);
    });

    test('emits UnknownEvent for invalid UTF-8 lead bytes', () async {
      parser.add([0x80]); // continuation byte without a lead byte
      await Future.microtask(() {});

      expect(events, [const InputEvent.unknown(raw: [0x80])]);
    });

    test('closes the event stream on dispose', () async {
      var done = false;
      parser.events.listen(null, onDone: () => done = true);

      parser.dispose();
      await Future.microtask(() {});

      expect(done, isTrue);
    });
  });
}
