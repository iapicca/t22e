import 'package:test/test.dart';
import 'package:t22e/src/renderer/sync_renderer.dart';
import 'package:t22e/src/renderer/frame.dart';

void main() {
  group('SyncRenderer', () {
    test('without sync support passes content through', () {
      final renderer = SyncRenderer(syncSupported: false);
      final diff = DiffResult([0]);
      final frame = Frame(['A'], ['A']);
      final output = renderer.render(diff, frame);
      expect(output, '\x1b[1;0HA');
    });

    test('with sync support wraps content', () {
      final renderer = SyncRenderer(syncSupported: true);
      final diff = DiffResult([0]);
      final frame = Frame(['A'], ['A']);
      final output = renderer.render(diff, frame);
      expect(output, startsWith('\x1b[?2026h'));
      expect(output, endsWith('\x1b[?2026l'));
      expect(output, contains('\x1b[1;0HA'));
    });

    test('empty content is returned as-is (no sync markers)', () {
      final renderer = SyncRenderer(syncSupported: true);
      final diff = DiffResult([]);
      final frame = Frame([''], ['']);
      expect(renderer.render(diff, frame), '');
    });
  });
}
