import 'package:test/test.dart';
import 'package:t22e/src/ansi/codes.dart';

void main() {
  group('ANSI constants', () {
    test('esc is \\x1b', () => expect(esc, equals('\x1b')));
    test('csi is \\x1b[', () => expect(csi, equals('\x1b[')));
    test('osc is \\x1b]', () => expect(osc, equals('\x1b]')));
    test('dcs is \\x1bP', () => expect(dcs, equals('\x1bP')));
    test('st is \\x1b\\', () => expect(st, equals('\x1b\\')));
    test('bel is \\x07', () => expect(bel, equals('\x07')));
  });

  group('text attributes', () {
    test('bold on', () => expect(bold(true), equals('\x1b[1m')));
    test('bold off', () => expect(bold(false), equals('\x1b[22m')));
    test('dim on', () => expect(dim(true), equals('\x1b[2m')));
    test('dim off', () => expect(dim(false), equals('\x1b[22m')));
    test('italic on', () => expect(italic(true), equals('\x1b[3m')));
    test('italic off', () => expect(italic(false), equals('\x1b[23m')));
    test('underline on', () => expect(underline(true), equals('\x1b[4m')));
    test('underline off', () => expect(underline(false), equals('\x1b[24m')));
    test('blink on', () => expect(blink(true), equals('\x1b[5m')));
    test('blink off', () => expect(blink(false), equals('\x1b[25m')));
    test('reverse on', () => expect(reverse(true), equals('\x1b[7m')));
    test('reverse off', () => expect(reverse(false), equals('\x1b[27m')));
    test('strikethrough on', () => expect(strikethrough(true), equals('\x1b[9m')));
    test('strikethrough off', () => expect(strikethrough(false), equals('\x1b[29m')));
    test('overLine on', () => expect(overLine(true), equals('\x1b[53m')));
    test('overLine off', () => expect(overLine(false), equals('\x1b[55m')));
    test('resetAll', () => expect(resetAll(), equals('\x1b[0m')));
  });
}
