import 'dart:async';

import 'package:test/test.dart';
import 'package:parser/terminal_parser.dart';
import 'package:widgets/widgets.dart';
import 'package:example_app/example_app.dart';

void main() {
  group('ChatApp', () {
    test('initial model is provided', () {
      final model = ChatModel(terminalWidth: 100, terminalHeight: 50);
      final app = ChatApp(model);
      expect(app.model.terminalWidth, 100);
      expect(app.model.terminalHeight, 50);
    });

    test('dispatch updates input via KeyMsg', () {
      final app = ChatApp(ChatModel());
      app.dispatch(
        KeyMsg(const KeyEvent(keyCode: KeyCode.char, codepoint: 97)),
      );
      expect(app.model.input.value, 'a');
    });

    test('dispatch enter adds user message', () {
      var model = ChatModel();
      (model, _) = model.update(
        KeyMsg(const KeyEvent(keyCode: KeyCode.char, codepoint: 104)),
      );
      (model, _) = model.update(
        KeyMsg(const KeyEvent(keyCode: KeyCode.char, codepoint: 105)),
      );
      final app = ChatApp(model);
      app.dispatch(KeyMsg(const KeyEvent(keyCode: KeyCode.enter)));

      expect(app.model.messages.length, 1);
      expect(app.model.messages[0].text, 'hi');
      expect(app.model.messages[0].isBot, false);
      expect(app.model.input.value, '');
    });

    test('dispatch enter triggers bot reply via TickCmd', () async {
      var model = ChatModel();
      (model, _) = model.update(
        KeyMsg(const KeyEvent(keyCode: KeyCode.char, codepoint: 104)),
      );
      final app = ChatApp(model);
      app.dispatch(KeyMsg(const KeyEvent(keyCode: KeyCode.enter)));

      await Future.delayed(const Duration(milliseconds: 300));

      expect(app.model.messages.length, 2);
      expect(app.model.messages[1].text, 'Your message was 1 characters');
      expect(app.model.messages[1].isBot, true);
    });

    test('view returns widget tree', () {
      final app = ChatApp(ChatModel());
      expect(app.view(), isA<Widget>());
    });

    test('view after messages renders correctly', () {
      var model = ChatModel();
      (model, _) = model.update(
        KeyMsg(const KeyEvent(keyCode: KeyCode.char, codepoint: 104)),
      );
      (model, _) = model.update(KeyMsg(const KeyEvent(keyCode: KeyCode.enter)));
      final app = ChatApp(model);
      expect(app.view(), isA<Widget>());
    });

    test('dispatch QuitMsg does not change model', () {
      final app = ChatApp(ChatModel());
      app.dispatch(const QuitMsg());
      expect(app.model.messages, isEmpty);
    });

    test('dispatch Ctrl+C does not change model', () {
      final app = ChatApp(ChatModel());
      app.dispatch(
        KeyMsg(const KeyEvent(keyCode: KeyCode.char, codepoint: 0x03)),
      );
      expect(app.model.messages, isEmpty);
    });

    test('dispatch WindowSizeMsg updates dimensions', () {
      final app = ChatApp(ChatModel());
      app.dispatch(WindowSizeMsg(120, 50));
      expect(app.model.terminalWidth, 120);
      expect(app.model.terminalHeight, 50);
    });
  });
}
