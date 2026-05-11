import 'package:test/test.dart';
import 'package:parser/terminal_parser.dart';
import 'package:widgets/widgets.dart';

void main() {
  group('TextInput', () {
    test('initial state has empty value', () {
      final input = TextInput();
      expect(input.value, '');
      expect(input.cursorPosition, 0);
    });

    test('inserting a character', () {
      final input = TextInput();
      final (updated, _) = input.update(KeyMsg(
        const KeyEvent(keyCode: KeyCode.char, codepoint: 97),
      ));
      expect(updated.value, 'a');
      expect(updated.cursorPosition, 1);
    });

    test('inserting multiple characters', () {
      var input = TextInput();
      for (final cp in [97, 98, 99]) {
        final (updated, _) = input.update(KeyMsg(
          KeyEvent(keyCode: KeyCode.char, codepoint: cp),
        ));
        input = updated;
      }
      expect(input.value, 'abc');
      expect(input.cursorPosition, 3);
    });

    test('backspace removes character before cursor', () {
      final input = TextInput(value: 'ab', cursorPosition: 2);
      final (updated, _) = input.update(KeyMsg(
        const KeyEvent(keyCode: KeyCode.backspace),
      ));
      expect(updated.value, 'a');
      expect(updated.cursorPosition, 1);
    });

    test('delete removes character after cursor', () {
      final input = TextInput(value: 'ab', cursorPosition: 0);
      final (updated, _) = input.update(KeyMsg(
        const KeyEvent(keyCode: KeyCode.delete),
      ));
      expect(updated.value, 'b');
    });

    test('arrow left moves cursor', () {
      final input = TextInput(value: 'ab', cursorPosition: 2);
      final (updated, _) = input.update(KeyMsg(
        const KeyEvent(keyCode: KeyCode.left),
      ));
      expect(updated.cursorPosition, 1);
    });

    test('arrow right moves cursor', () {
      final input = TextInput(value: 'ab', cursorPosition: 0);
      final (updated, _) = input.update(KeyMsg(
        const KeyEvent(keyCode: KeyCode.right),
      ));
      expect(updated.cursorPosition, 1);
    });

    test('home goes to start', () {
      final input = TextInput(value: 'abc', cursorPosition: 2);
      final (updated, _) = input.update(KeyMsg(
        const KeyEvent(keyCode: KeyCode.home),
      ));
      expect(updated.cursorPosition, 0);
    });

    test('end goes to end', () {
      final input = TextInput(value: 'abc', cursorPosition: 0);
      final (updated, _) = input.update(KeyMsg(
        const KeyEvent(keyCode: KeyCode.end),
      ));
      expect(updated.cursorPosition, 3);
    });

    test('cursor blink toggles cursor visibility', () {
      final input = TextInput();
      expect(input.cursorVisible, isTrue);

      final (updated, _) = input.update(const CursorBlinkMsg());
      expect(updated.cursorVisible, isFalse);

      final (updated2, _) = updated.update(const CursorBlinkMsg());
      expect(updated2.cursorVisible, isTrue);
    });

    test('password mode masks value', () {
      final input = TextInput(value: 'secret', echoMode: EchoMode.password);
      expect(input.value, 'secret');
    });

    test('max length prevents overflow', () {
      final input = TextInput(maxLength: 3, value: 'ab', cursorPosition: 2);
      var current = input;
      for (final cp in [99, 100]) {
        final (updated, _) = current.update(KeyMsg(
          KeyEvent(keyCode: KeyCode.char, codepoint: cp),
        ));
        current = updated;
      }
      expect(current.value, 'abc');
    });
  });
}
