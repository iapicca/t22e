import 'package:test/test.dart';
import 'package:t22e/src/ansi/color.dart';

void main() {
  group('RGB colors', () {
    test('foreground RGB', () {
      expect(setForegroundRgb(255, 0, 128), equals('\x1b[38;2;255;0;128m'));
    });
    test('background RGB', () {
      expect(setBackgroundRgb(0, 128, 255), equals('\x1b[48;2;0;128;255m'));
    });
  });

  group('256-color palette', () {
    test('foreground 256', () {
      expect(setForeground256(42), equals('\x1b[38;5;42m'));
    });
    test('background 256', () {
      expect(setBackground256(199), equals('\x1b[48;5;199m'));
    });
  });

  group('ANSI 16 colors', () {
    test('foreground ANSI', () {
      expect(foregroundAnsi(1), equals('\x1b[31m'));
    });
    test('background ANSI', () {
      expect(backgroundAnsi(4), equals('\x1b[44m'));
    });
    test('bright foreground ANSI', () {
      expect(foregroundBrightAnsi(3), equals('\x1b[93m'));
    });
    test('bright background ANSI', () {
      expect(backgroundBrightAnsi(7), equals('\x1b[107m'));
    });
  });

  test('reset color', () {
    expect(resetColor(), equals('\x1b[39;49m'));
  });
}
