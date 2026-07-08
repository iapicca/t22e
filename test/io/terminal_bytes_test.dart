import 'package:t22e/t22e.dart';
import 'package:test/test.dart';

void main() {
  group('isControlByte', () {
    test('true below 0x20', () {
      expect(isControlByte(0x00), isTrue);
      expect(isControlByte(0x0D), isTrue); // CR
      expect(isControlByte(0x1F), isTrue);
    });

    test('true for DEL (0x7F)', () {
      expect(isControlByte(0x7F), isTrue);
    });

    test('false for printable and high bytes', () {
      expect(isControlByte(0x20), isFalse); // space
      expect(isControlByte(0x41), isFalse); // 'A'
      expect(isControlByte(0x7E), isFalse); // '~'
      expect(isControlByte(0x80), isFalse);
    });
  });

  group('isCsiParamByte', () {
    test('true in 0x30..0x3F', () {
      expect(isCsiParamByte(0x30), isTrue); // '0'
      expect(isCsiParamByte(0x3F), isTrue); // '?'
      expect(isCsiParamByte(0x35), isTrue);
    });

    test('false outside the range', () {
      expect(isCsiParamByte(0x2F), isFalse);
      expect(isCsiParamByte(0x40), isFalse);
    });
  });

  group('isCsiIntermediateByte', () {
    test('true in 0x20..0x2F', () {
      expect(isCsiIntermediateByte(0x20), isTrue);
      expect(isCsiIntermediateByte(0x2F), isTrue);
      expect(isCsiIntermediateByte(0x21), isTrue);
    });

    test('false outside the range', () {
      expect(isCsiIntermediateByte(0x1F), isFalse);
      expect(isCsiIntermediateByte(0x30), isFalse);
    });
  });

  group('isCsiFinalByte', () {
    test('true in 0x40..0x7E', () {
      expect(isCsiFinalByte(0x40), isTrue); // '@'
      expect(isCsiFinalByte(0x41), isTrue); // 'A' (up)
      expect(isCsiFinalByte(0x7E), isTrue); // '~'
    });

    test('false outside the range', () {
      expect(isCsiFinalByte(0x3F), isFalse);
      expect(isCsiFinalByte(0x7F), isFalse);
    });
  });
}