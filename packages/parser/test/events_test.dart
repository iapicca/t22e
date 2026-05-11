import 'package:test/test.dart';
import 'package:parser/terminal_parser.dart';

void main() {
  group('KeyEvent', () {
    test('basic key event', () {
      final event = KeyEvent(keyCode: KeyCode.up);
      expect(event.keyCode, equals(KeyCode.up));
      expect(event.modifiers.ctrl, isFalse);
      expect(event.type, equals(KeyEventType.down));
      expect(event.codepoint, isNull);
    });

    test('key event with modifiers', () {
      final mods = KeyModifiers(ctrl: true, shift: true);
      final event = KeyEvent(keyCode: KeyCode.char, modifiers: mods, codepoint: 0x41);
      expect(event.modifiers.ctrl, isTrue);
      expect(event.modifiers.shift, isTrue);
      expect(event.codepoint, equals(0x41));
    });

    test('equality', () {
      final a = KeyEvent(keyCode: KeyCode.enter);
      final b = KeyEvent(keyCode: KeyCode.enter);
      expect(a, equals(b));
    });

    test('toString', () {
      final event = KeyEvent(keyCode: KeyCode.char, codepoint: 0x41);
      expect(event.toString(), contains('U+0041'));
    });
  });

  group('MouseEvent', () {
    test('basic mouse event', () {
      final event = MouseEvent(button: MouseButton.left, action: MouseAction.press, x: 10, y: 20);
      expect(event.button, equals(MouseButton.left));
      expect(event.action, equals(MouseAction.press));
      expect(event.x, equals(10));
      expect(event.y, equals(20));
    });

    test('equality', () {
      final a = MouseEvent(button: MouseButton.left, action: MouseAction.press, x: 5, y: 10);
      final b = MouseEvent(button: MouseButton.left, action: MouseAction.press, x: 5, y: 10);
      expect(a, equals(b));
    });
  });

  group('PasteEvent', () {
    test('content', () {
      final event = PasteEvent('hello');
      expect(event.content, equals('hello'));
    });
  });

  group('CursorPositionEvent', () {
    test('position', () {
      final event = CursorPositionEvent(5, 10);
      expect(event.row, equals(5));
      expect(event.col, equals(10));
    });
  });

  group('ColorQueryEvent', () {
    test('color query', () {
      final event = ColorQueryEvent(10, 255, 0, 128);
      expect(event.colorNumber, equals(10));
      expect(event.r, equals(255));
      expect(event.g, equals(0));
      expect(event.b, equals(128));
    });
  });

  group('PrimaryDeviceAttributesEvent', () {
    test('attributes', () {
      final event = PrimaryDeviceAttributesEvent([64, 1]);
      expect(event.params, contains(64));
    });
  });

  group('WindowResizeEvent', () {
    test('resize', () {
      final event = WindowResizeEvent(24, 80);
      expect(event.rows, equals(24));
      expect(event.cols, equals(80));
    });
  });

  group('FocusEvent', () {
    test('focus', () => expect(FocusEvent(true).focused, isTrue));
    test('blur', () => expect(FocusEvent(false).focused, isFalse));
  });

  group('ErrorEvent', () {
    test('error message', () {
      final event = ErrorEvent('something went wrong');
      expect(event.message, contains('wrong'));
    });
  });

  group('InternalEvent', () {
    test('kind', () {
      final event = InternalEvent('tick');
      expect(event.kind, equals('tick'));
    });

    test('with data', () {
      final event = InternalEvent('title_changed', {'title': 'hello'});
      expect(event.data!['title'], equals('hello'));
    });
  });
}
