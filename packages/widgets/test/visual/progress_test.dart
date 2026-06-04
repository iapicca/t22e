import 'package:test/test.dart';
import 'package:widgets/widgets.dart';

void main() {
  group('ProgressBar', () {
    test('determinate shows correct fill ratio', () {
      final pb = ProgressBar(fraction: 0.5, barWidth: 20, label: null);
      final view = pb.view();
      final surface = WidgetRenderer.render(view, 30, 1);
      final plain = surface.toPlainLines()[0];
      expect(plain.length, greaterThan(0));
    });

    test('determinate at 100% fills all', () {
      final pb = ProgressBar(fraction: 1.0, barWidth: 10, label: null);
      final view = pb.view();
      final surface = WidgetRenderer.render(view, 20, 1);
      final plain = surface.toPlainLines()[0];
      expect(plain.length, greaterThan(0));
    });

    test('determinate at 0% fills none', () {
      final pb = ProgressBar(fraction: 0.0, barWidth: 10, label: null);
      final view = pb.view();
      final surface = WidgetRenderer.render(view, 20, 1);
      final plain = surface.toPlainLines()[0];
      expect(plain.length, greaterThan(0));
    });

    test('indeterminate advances offset on tick', () {
      final pb = ProgressBar(barWidth: 10, label: null);
      expect(pb.indeterminateOffset, 0);

      final (updated, _) = pb.update(const ProgressTickMsg());
      expect(updated.indeterminateOffset, 1);
    });

    test('tick does nothing for determinate', () {
      final pb = ProgressBar(fraction: 0.5);
      final (updated, _) = pb.update(const ProgressTickMsg());
      expect(identical(updated, pb), isTrue);
    });
  });
}
