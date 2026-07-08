import 'dart:convert' show utf8;

import 'package:t22e/t22e.dart';
import 'package:test/test.dart';

void main() {
  group('utf8Length', () {
    test('single-byte ASCII range', () {
      expect(utf8Length(0x00), 1);
      expect(utf8Length(0x41), 1); // 'A'
      expect(utf8Length(0x7F), 1);
    });

    test('two-byte lead', () {
      expect(utf8Length(0xC3), 2); // 'é' lead
      expect(utf8Length(0xDF), 2);
    });

    test('three-byte lead', () {
      expect(utf8Length(0xE0), 3);
      expect(utf8Length(0xEF), 3);
    });

    test('four-byte lead', () {
      expect(utf8Length(0xF0), 4);
      expect(utf8Length(0xF4), 4);
    });

    test('invalid lead bytes return 0', () {
      expect(utf8Length(0x80), 0); // continuation byte
      expect(utf8Length(0xFE), 0);
      expect(utf8Length(0xFF), 0);
    });
  });

  group('utf8.decode (default decoder)', () {
    test('decodes a valid single-character run', () {
      expect(utf8.decode(<int>[0x41]), 'A');
    });

    test('decodes a multi-byte character', () {
      // UTF-8 for 'é' (U+00E9).
      expect(utf8.decode(<int>[0xC3, 0xA9]), 'é');
    });

    test('decodes a three-byte character', () {
      // UTF-8 for '€' (U+20AC).
      expect(utf8.decode(<int>[0xE2, 0x82, 0xAC]), '€');
    });

    test('throws FormatException on malformed bytes', () {
      expect(() => utf8.decode(<int>[0xC3]), throwsFormatException);
      expect(() => utf8.decode(<int>[0x80]), throwsFormatException);
    });
  });
}