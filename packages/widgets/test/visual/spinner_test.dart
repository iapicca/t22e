import 'package:test/test.dart';
import 'package:widgets/widgets.dart';

void main() {
  group('Spinner', () {
    test('default frames list is not empty', () {
      expect(Spinner.defaultFrames.length, greaterThan(0));
    });

    test('frame advances on tick', () {
      final spinner = Spinner();
      expect(spinner.frame, 0);

      final (updated, _) = spinner.update(const SpinnerTickMsg());
      expect(updated.frame, 1);
    });

    test('frame wraps around', () {
      final frames = ['a', 'b', 'c'];
      final spinner = Spinner(frame: 2, frames: frames);
      final (updated, _) = spinner.update(const SpinnerTickMsg());
      expect(updated.frame, 0);
    });

    test('view returns a Widget', () {
      final spinner = Spinner(label: 'test');
      final view = spinner.view();
      expect(view, isA<Widget>());
    });

    test('render does not crash', () {
      final spinner = Spinner(label: 'test');
      final view = spinner.view();
      expect(() => WidgetRenderer.render(view, 20, 1), returnsNormally);
    });
  });
}
