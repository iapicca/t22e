import 'package:test/test.dart';
import 'package:parser/terminal_parser.dart';

void main() {
  late Vt500Engine engine;

  setUp(() {
    engine = Vt500Engine();
  });

  group('ground state', () {
    test('printable characters produce CharData', () {
      final result = engine.advance(0x41);
      expect(result, isA<CharData>());
      expect((result as CharData).codepoint, equals(0x41));
    });

    test('multiple printable chars produce multiple CharData', () {
      final results = engine.advanceAll([0x48, 0x65, 0x6C, 0x6C, 0x6F]);
      expect(results.length, equals(5));
    });

    test('ESC transitions to escape state', () {
      final result = engine.advance(0x1B);
      expect(result, isNull);
    });
  });

  group('escape state', () {
    test('ESC+A produces EscSequenceData', () {
      engine.advance(0x1B);
      final result = engine.advance(0x41);
      expect(result, isA<EscSequenceData>());
      expect((result as EscSequenceData).finalByte, equals(0x41));
    });

    test('ESC c produces reset internal event marker', () {
      engine.advance(0x1B);
      final result = engine.advance(0x63);
      expect(result, isA<EscSequenceData>());
      expect((result as EscSequenceData).finalByte, equals(0x63));
    });

    test('ESC O P produces SS3 F1', () {
      engine.advance(0x1B);
      engine.advance(0x4F);
      final result = engine.advance(0x50);
      expect(result, isA<EscSequenceData>());
    });
  });

  group('CSI state', () {
    test('CSI A produces cursor up', () {
      engine.advance(0x1B);
      engine.advance(0x5B);
      final result = engine.advance(0x41);
      expect(result, isA<CsiSequenceData>());
      final csi = result as CsiSequenceData;
      expect(csi.finalByte, equals(0x41));
    });

    test('CSI with params', () {
      engine.advance(0x1B);
      engine.advance(0x5B);
      engine.advance(0x31);
      engine.advance(0x3B);
      engine.advance(0x35);
      final result = engine.advance(0x41);
      expect(result, isA<CsiSequenceData>());
      final csi = result as CsiSequenceData;
      expect(csi.params, containsAll([1, 5]));
      expect(csi.finalByte, equals(0x41));
    });

    test('CSI tilde sequences', () {
      engine.advance(0x1B);
      engine.advance(0x5B);
      engine.advance(0x31);
      engine.advance(0x35);
      final result = engine.advance(0x7E);
      expect(result, isA<CsiSequenceData>());
      expect((result as CsiSequenceData).finalByte, equals(0x7E));
      expect(result.params, contains(15));
    });

    test('CSI 8-bit', () {
      final result = engine.advance(0x9B);
      expect(result, isNull);
      final result2 = engine.advance(0x41);
      expect(result2, isA<CsiSequenceData>());
    });
  });

  group('OSC state', () {
    test('OSC string terminated by BEL', () {
      engine.advance(0x1B);
      engine.advance(0x5D);
      for (final b in '0;hello'.codeUnits) {
        engine.advance(b);
      }
      final result = engine.advance(0x07);
      expect(result, isA<OscSequenceData>());
      expect((result as OscSequenceData).content, equals('0;hello'));
    });

    test('OSC 8-bit', () {
      final result = engine.advance(0x9D);
      expect(result, isNull);
    });

    test('OSC terminated by ST', () {
      engine.advance(0x1B);
      engine.advance(0x5D);
      for (final b in '10;rgb:ff00/0000/0000'.codeUnits) {
        engine.advance(b);
      }
      engine.advance(0x1B);
      final result = engine.advance(0x5C);
      expect(result, isA<OscSequenceData>());
    });
  });

  group('DCS state', () {
    test('DCS passthrough', () {
      engine.advance(0x1B);
      engine.advance(0x50);
      engine.advance(0x70);
      for (final b in '{data}'.codeUnits) {
        engine.advance(b);
      }
      engine.advance(0x1B);
      final result = engine.advance(0x5C);
      expect(result, isA<DcsSequenceData>());
    });
  });

  group('reset', () {
    test('reset clears state', () {
      engine.advance(0x1B);
      engine.reset();
      final result = engine.advance(0x41);
      expect(result, isA<CharData>());
    });
  });
}
