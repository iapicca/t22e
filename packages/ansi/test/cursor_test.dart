import 'package:test/test.dart';
import 'package:ansi/ansi.dart';

void main() {
  group('cursor movement', () {
    test('moveTo', () => expect(moveTo(3, 7), equals('\x1b[3;7H')));
    test('moveUp', () => expect(moveUp(3), equals('\x1b[3A')));
    test('moveDown', () => expect(moveDown(2), equals('\x1b[2B')));
    test('moveRight', () => expect(moveRight(5), equals('\x1b[5C')));
    test('moveLeft', () => expect(moveLeft(4), equals('\x1b[4D')));
    test('moveColumn', () => expect(moveColumn(10), equals('\x1b[10G')));
  });

  group('cursor visibility', () {
    test('hideCursor', () => expect(hideCursor(), equals('\x1b[?25l')));
    test('showCursor', () => expect(showCursor(), equals('\x1b[?25h')));
  });

  group('cursor save/restore', () {
    test('saveCursor', () => expect(saveCursor(), equals('\x1b[s')));
    test('restoreCursor', () => expect(restoreCursor(), equals('\x1b[u')));
  });

  test('requestPosition', () {
    expect(requestPosition(), equals('\x1b[6n'));
  });

  group('cursor style', () {
    test('blinkingBlock', () {
      expect(setStyle(CursorStyle.blinkingBlock), equals('\x1b[1 q'));
    });
    test('steadyBar', () {
      expect(setStyle(CursorStyle.steadyBar), equals('\x1b[6 q'));
    });
  });
}
