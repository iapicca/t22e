import 'package:test/test.dart';
import 'package:ansi/ansi.dart';

void main() {
  test('eraseDisplay', () {
    expect(eraseDisplay(2), equals('\x1b[2J'));
  });

  test('eraseLine', () {
    expect(eraseLine(1), equals('\x1b[1K'));
  });

  test('eraseScreen', () => expect(AnsiDefaults.eraseScreen, equals('\x1b[2J')));

  test('eraseSavedLines', () => expect(AnsiDefaults.eraseSavedLines, equals('\x1b[3J')));

  test('eraseLineToEnd', () => expect(AnsiDefaults.eraseLineToEnd, equals('\x1b[0K')));

  test('eraseLineToStart', () => expect(AnsiDefaults.eraseLineToStart, equals('\x1b[1K')));

  test('eraseLineAll', () => expect(AnsiDefaults.eraseLineAll, equals('\x1b[2K')));
}
