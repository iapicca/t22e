import 'package:test/test.dart';
import 'package:core/core.dart';
import 'package:renderer/renderer.dart';

void main() {
  group('Frame', () {
    test('fromSurface captures plain and styled lines', () {
      final s = Surface(5, 3);
      s.putChar(0, 0, 'A', TextStyle.empty);
      final frame = Frame.fromSurface(s);
      expect(frame.height, 3);
      expect(frame.plainLines[0], 'A    ');
      expect(frame.styledLines[0], contains('A'));
    });
  });

  group('diff', () {
    test('no change returns empty diff', () {
      final s = Surface(5, 3);
      final prev = Frame.fromSurface(s);
      final curr = Frame.fromSurface(s);
      final result = diff(prev, curr);
      expect(result.hasChanges, isFalse);
      expect(result.changedRows, isEmpty);
    });

    test('content change detects changed row', () {
      final prev = Frame.fromSurface(Surface(5, 3));

      final currSurface = Surface(5, 3);
      currSurface.putChar(2, 1, 'X', TextStyle.empty);
      final curr = Frame.fromSurface(currSurface);

      final result = diff(prev, curr);
      expect(result.hasChanges, isTrue);
      expect(result.changedRows, [1]);
    });

    test('style-only change is detected', () {
      final prevSurface = Surface(5, 3);
      prevSurface.putChar(0, 0, 'A', TextStyle.empty);
      final prev = Frame.fromSurface(prevSurface);

      final currSurface = Surface(5, 3);
      currSurface.putChar(0, 0, 'A', TextStyle(bold: true));
      final curr = Frame.fromSurface(currSurface);

      final result = diff(prev, curr);
      expect(result.hasChanges, isTrue);
    });

    test('resize larger detects new rows', () {
      final prev = Frame.fromSurface(Surface(5, 2));
      final curr = Frame.fromSurface(Surface(5, 5));
      final result = diff(prev, curr);
      expect(result.changedRows, [2, 3, 4]);
    });

    test('resize smaller detects removed rows', () {
      final prev = Frame.fromSurface(Surface(5, 5));
      final curr = Frame.fromSurface(Surface(5, 2));
      final result = diff(prev, curr);
      expect(result.changedRows, [2, 3, 4]);
    });

    test('multiple changes detected', () {
      final prev = Frame.fromSurface(Surface(5, 5));
      final currSurface = Surface(5, 5);
      currSurface.putChar(0, 0, 'X', TextStyle.empty);
      currSurface.putChar(0, 4, 'Y', TextStyle.empty);
      final curr = Frame.fromSurface(currSurface);

      final result = diff(prev, curr);
      expect(result.changedRows, [0, 4]);
    });
  });
}
