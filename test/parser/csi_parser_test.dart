import 'package:test/test.dart';
import 'package:t22e/src/parser/csi_parser.dart';
import 'package:t22e/src/parser/engine.dart';
import 'package:t22e/src/parser/events.dart';

void main() {
  late CsiParser parser;

  setUp(() {
    parser = CsiParser();
  });

  CsiSequenceData _csi(int finalByte, [List<int> params = const [], List<int> intermediates = const []]) {
    return CsiSequenceData(params, intermediates, finalByte);
  }

  group('arrow keys', () {
    test('up arrow', () {
      final event = parser.parse(_csi(0x41, [1]));
      expect(event, isA<KeyEvent>());
      expect((event as KeyEvent).keyCode, equals(KeyCode.up));
    });

    test('down arrow', () {
      final event = parser.parse(_csi(0x42, [1]));
      expect((event as KeyEvent).keyCode, equals(KeyCode.down));
    });

    test('right arrow', () {
      final event = parser.parse(_csi(0x43, [1]));
      expect((event as KeyEvent).keyCode, equals(KeyCode.right));
    });

    test('left arrow', () {
      final event = parser.parse(_csi(0x44, [1]));
      expect((event as KeyEvent).keyCode, equals(KeyCode.left));
    });

    test('arrow with ctrl modifier', () {
      final event = parser.parse(_csi(0x41, [1, 5]));
      expect((event as KeyEvent).modifiers.ctrl, isTrue);
    });
  });

  group('home/end', () {
    test('home', () {
      final event = parser.parse(_csi(0x48, [1]));
      expect((event as KeyEvent).keyCode, equals(KeyCode.home));
    });

    test('end', () {
      final event = parser.parse(_csi(0x46, [1]));
      expect((event as KeyEvent).keyCode, equals(KeyCode.end));
    });
  });

  group('tilde sequences', () {
    test('page up', () {
      final event = parser.parse(_csi(0x7E, [5]));
      expect((event as KeyEvent).keyCode, equals(KeyCode.pageUp));
    });

    test('page down', () {
      final event = parser.parse(_csi(0x7E, [6]));
      expect((event as KeyEvent).keyCode, equals(KeyCode.pageDown));
    });

    test('insert', () {
      final event = parser.parse(_csi(0x7E, [2]));
      expect((event as KeyEvent).keyCode, equals(KeyCode.insert));
    });

    test('delete', () {
      final event = parser.parse(_csi(0x7E, [3]));
      expect((event as KeyEvent).keyCode, equals(KeyCode.delete));
    });

    test('F5', () {
      final event = parser.parse(_csi(0x7E, [15]));
      expect((event as KeyEvent).keyCode, equals(KeyCode.f5));
    });

    test('F12', () {
      final event = parser.parse(_csi(0x7E, [24]));
      expect((event as KeyEvent).keyCode, equals(KeyCode.f12));
    });
  });

  group('F-keys via SS3', () {
    test('F1', () {
      final event = parser.parse(_csi(0x50));
      expect((event as KeyEvent).keyCode, equals(KeyCode.f1));
    });

    test('F4', () {
      final event = parser.parse(_csi(0x53));
      expect((event as KeyEvent).keyCode, equals(KeyCode.f4));
    });
  });

  group('CPR', () {
    test('cursor position report', () {
      final event = parser.parse(_csi(0x52, [5, 10]));
      expect(event, isA<CursorPositionEvent>());
      expect((event as CursorPositionEvent).row, equals(5));
      expect(event.col, equals(10));
    });
  });

  group('unknown sequences', () {
    test('unknown final byte returns null', () {
      final event = parser.parse(_csi(0x7A));
      expect(event, isNull);
    });
  });
}
