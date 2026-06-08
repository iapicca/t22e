import 'package:test/test.dart';
import 'package:ansi/ansi.dart';

void main() {
  group('alternate screen', () {
    test(
      'enterAltScreen',
      () => expect(AnsiDefaults.enterAltScreen, equals('\x1b[?1049h')),
    );
    test('exitAltScreen', () => expect(AnsiDefaults.exitAltScreen, equals('\x1b[?1049l')));
  });

  group('mouse modes', () {
    test(
      'enableNormalMouse',
      () => expect(AnsiDefaults.enableNormalMouse, equals('\x1b[?1000h')),
    );
    test('disableMouse', () {
      expect(AnsiDefaults.disableMouse, equals('\x1b[?1000l\x1b[?1002l\x1b[?1006l'));
    });
    test(
      'enableButtonEvents',
      () => expect(AnsiDefaults.enableButtonEvents, equals('\x1b[?1002h')),
    );
    test(
      'enableSgrMouse',
      () => expect(AnsiDefaults.enableSgrMouse, equals('\x1b[?1006h')),
    );
  });

  group('sync updates', () {
    test('startSync', () => expect(AnsiDefaults.startSync, equals('\x1b[?2026h')));
    test('endSync', () => expect(AnsiDefaults.endSync, equals('\x1b[?2026l')));
  });

  group('bracketed paste', () {
    test('enableBracketedPaste', () {
      expect(AnsiDefaults.enableBracketedPaste, equals('\x1b[?2004h'));
    });
    test('disableBracketedPaste', () {
      expect(AnsiDefaults.disableBracketedPaste, equals('\x1b[?2004l'));
    });
  });

  group('focus tracking', () {
    test('enableFocusTracking', () {
      expect(AnsiDefaults.enableFocusTracking, equals('\x1b[?1004h'));
    });
    test('disableFocusTracking', () {
      expect(AnsiDefaults.disableFocusTracking, equals('\x1b[?1004l'));
    });
  });

  test('setTitle', () {
    expect(setTitle('hello'), equals('\x1b]0;hello\x07'));
  });

  test('hyperlink', () {
    expect(
      hyperlink('https://dart.dev', 'Dart'),
      equals('\x1b]8;;https://dart.dev\x07Dart\x1b]8;;\x07'),
    );
  });

  group('kitty keyboard protocol', () {
    test('enableKittyKeyboard', () {
      expect(enableKittyKeyboard(1), equals('\x1b[>1u'));
    });
    test(
      'disableKittyKeyboard',
      () => expect(AnsiDefaults.disableKittyKeyboard, equals('\x1b[<u')),
    );
    test(
      'queryKittyKeyboard',
      () => expect(AnsiDefaults.queryKittyKeyboard, equals('\x1b[?u')),
    );
  });

  group('color queries', () {
    test('queryForegroundColor', () {
      expect(AnsiDefaults.queryForegroundColor, equals('\x1b]10;?\x07'));
    });
    test('queryBackgroundColor', () {
      expect(AnsiDefaults.queryBackgroundColor, equals('\x1b]11;?\x07'));
    });
  });

  test('softReset', () => expect(AnsiDefaults.softReset, equals('\x1b[!p')));
}
