import 'package:test/test.dart';
import 'package:parser/terminal_parser.dart';
import 'package:widgets/widgets.dart';
import 'package:example_app/example_app.dart';

void main() {
  group('ChatModel', () {
    test('initial state has empty messages and default input', () {
      final model = ChatModel();
      expect(model.messages, isEmpty);
      expect(model.input.value, '');
      expect(model.terminalWidth, 80);
      expect(model.terminalHeight, 24);
    });

    test('custom dimensions are stored', () {
      final model = ChatModel(terminalWidth: 120, terminalHeight: 40);
      expect(model.terminalWidth, 120);
      expect(model.terminalHeight, 40);
    });

    test('inserting a character delegates to TextInput', () {
      final model = ChatModel();
      final (updated, _) = model.update(
        KeyMsg(const KeyEvent(keyCode: KeyCode.char, codepoint: 97)),
      );
      expect(updated.input.value, 'a');
      expect(updated.messages, isEmpty);
    });

    test('backspace removes character via input delegation', () {
      var model = ChatModel();
      (model, _) = model.update(
        KeyMsg(const KeyEvent(keyCode: KeyCode.char, codepoint: 97)),
      );
      (model, _) = model.update(
        KeyMsg(const KeyEvent(keyCode: KeyCode.char, codepoint: 98)),
      );
      expect(model.input.value, 'ab');

      (model, _) = model.update(
        KeyMsg(const KeyEvent(keyCode: KeyCode.backspace)),
      );
      expect(model.input.value, 'a');
    });

    test('enter creates user message and returns TickCmd', () {
      var model = ChatModel();
      (model, _) = model.update(
        KeyMsg(const KeyEvent(keyCode: KeyCode.char, codepoint: 97)),
      );
      (model, _) = model.update(
        KeyMsg(const KeyEvent(keyCode: KeyCode.char, codepoint: 98)),
      );

      final (updated, cmd) = model.update(
        KeyMsg(const KeyEvent(keyCode: KeyCode.enter)),
      );

      expect(updated.messages.length, 1);
      expect(updated.messages[0].text, 'ab');
      expect(updated.messages[0].isBot, false);
      expect(updated.input.value, '');
      expect(updated.input.cursorPosition, 0);
      expect(cmd, isA<TickCmd>());
      expect((cmd as TickCmd).delay, const Duration(milliseconds: 250));
    });

    test('enter does nothing on empty input', () {
      final model = ChatModel();
      final (updated, cmd) = model.update(
        KeyMsg(const KeyEvent(keyCode: KeyCode.enter)),
      );

      expect(updated.messages, isEmpty);
      expect(cmd, isNull);
    });

    test('BotReplyMsg adds bot message with character count', () {
      final model = ChatModel();
      final (updated, cmd) = model.update(BotReplyMsg('Hello'));

      expect(updated.messages.length, 1);
      expect(updated.messages[0].text, 'Your message was 5 characters');
      expect(updated.messages[0].isBot, true);
      expect(cmd, isNull);
    });

    test('WindowSizeMsg updates dimensions', () {
      final model = ChatModel();
      final (updated, cmd) = model.update(WindowSizeMsg(100, 50));

      expect(updated.terminalWidth, 100);
      expect(updated.terminalHeight, 50);
      expect(cmd, isNull);
    });

    test('QuitMsg returns NoCmd', () {
      final model = ChatModel();
      final (updated, cmd) = model.update(const QuitMsg());

      expect(updated.messages, isEmpty);
      expect(cmd.runtimeType.toString(), contains('NoCmd'));
    });

    test('Ctrl+C returns no cmd', () {
      final model = ChatModel();
      final (updated, cmd) = model.update(
        KeyMsg(const KeyEvent(keyCode: KeyCode.char, codepoint: 0x03)),
      );

      expect(updated.messages, isEmpty);
      expect(cmd, isNull);
    });

    test('CursorBlinkMsg delegates to TextInput', () {
      final model = ChatModel();
      expect(model.input.cursorVisible, isTrue);

      final (updated, _) = model.update(const CursorBlinkMsg());
      expect(updated.input.cursorVisible, isFalse);
    });

    test('view returns non-null widget tree', () {
      var model = ChatModel();
      (model, _) = model.update(
        KeyMsg(const KeyEvent(keyCode: KeyCode.char, codepoint: 97)),
      );
      (model, _) = model.update(
        KeyMsg(const KeyEvent(keyCode: KeyCode.char, codepoint: 98)),
      );
      (model, _) = model.update(KeyMsg(const KeyEvent(keyCode: KeyCode.enter)));
      (model, _) = model.update(BotReplyMsg('ab'));

      final widget = model.view();
      expect(widget, isA<Widget>());
    });

    test('multiple messages accumulate in order', () {
      var model = ChatModel();

      (model, _) = model.update(
        KeyMsg(const KeyEvent(keyCode: KeyCode.char, codepoint: 72)),
      );
      (model, _) = model.update(KeyMsg(const KeyEvent(keyCode: KeyCode.enter)));
      (model, _) = model.update(BotReplyMsg('H'));
      expect(model.messages.length, 2);
      expect(model.messages[0].text, 'H');
      expect(model.messages[0].isBot, false);
      expect(model.messages[1].text, 'Your message was 1 characters');
      expect(model.messages[1].isBot, true);
    });

    test('copyWith returns new instance with overridden fields', () {
      final model = ChatModel(terminalWidth: 120, terminalHeight: 40);
      final copy = model.copyWith(terminalWidth: 80);

      expect(copy.terminalWidth, 80);
      expect(copy.terminalHeight, 40);
      expect(model.terminalWidth, 120);
    });
  });
}
