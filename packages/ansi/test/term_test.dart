import 'package:test/test.dart';
import 'package:ansi/ansi.dart';

void main() {
  group('alternate screen', () {
    test('enterAltScreen', () => expect(enterAltScreen(), equals('\x1b[?1049h')));
    test('exitAltScreen', () => expect(exitAltScreen(), equals('\x1b[?1049l')));
  });

  group('mouse modes', () {
    test('enableNormalMouse', () => expect(enableNormalMouse(), equals('\x1b[?1000h')));
    test('disableMouse', () {
      expect(disableMouse(), equals('\x1b[?1000l\x1b[?1002l\x1b[?1006l'));
    });
    test('enableButtonEvents', () => expect(enableButtonEvents(), equals('\x1b[?1002h')));
    test('enableSgrMouse', () => expect(enableSgrMouse(), equals('\x1b[?1006h')));
  });

  group('sync updates', () {
    test('startSync', () => expect(startSync(), equals('\x1b[?2026h')));
    test('endSync', () => expect(endSync(), equals('\x1b[?2026l')));
  });

  group('bracketed paste', () {
    test('enableBracketedPaste', () {
      expect(enableBracketedPaste(), equals('\x1b[?2004h'));
    });
    test('disableBracketedPaste', () {
      expect(disableBracketedPaste(), equals('\x1b[?2004l'));
    });
  });

  group('focus tracking', () {
    test('enableFocusTracking', () {
      expect(enableFocusTracking(), equals('\x1b[?1004h'));
    });
    test('disableFocusTracking', () {
      expect(disableFocusTracking(), equals('\x1b[?1004l'));
    });
  });

  test('setTitle', () {
    expect(setTitle('hello'), equals('\x1b]0;hello\x07'));
  });

  test('hyperlink', () {
    expect(hyperlink('https://dart.dev', 'Dart'),
        equals('\x1b]8;;https://dart.dev\x07Dart\x1b]8;;\x07'));
  });

  group('kitty keyboard protocol', () {
    test('enableKittyKeyboard', () {
      expect(enableKittyKeyboard(1), equals('\x1b[>1u'));
    });
    test('disableKittyKeyboard', () => expect(disableKittyKeyboard(), equals('\x1b[<u')));
    test('queryKittyKeyboard', () => expect(queryKittyKeyboard(), equals('\x1b[?u')));
  });

  group('color queries', () {
    test('queryForegroundColor', () {
      expect(queryForegroundColor(), equals('\x1b]10;?\x07'));
    });
    test('queryBackgroundColor', () {
      expect(queryBackgroundColor(), equals('\x1b]11;?\x07'));
    });
  });

  test('softReset', () => expect(softReset(), equals('\x1b[!p')));
}
