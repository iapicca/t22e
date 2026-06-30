import 'package:meta/meta.dart' show immutable;
import 'package:riverpod/riverpod.dart' show ProviderContainer;
import 'package:t22e/t22e.dart';
import 'package:test/test.dart';

void main() {
  group('Widget', () {
    test('can be const constructed and compiled into an Element', () {
      const widget = _StubWidget();
      final element = widget.compile(Context(ProviderContainer()));

      expect(element, isA<Element>());
      expect(element.widget, same(widget));
    });
  });
}

@immutable
class _StubWidget extends Widget {
  const _StubWidget();

  @override
  Element compile(Context context) =>
      _StubElement(widget: this, context: context);
}

class _StubElement extends Element {
  _StubElement({required super.widget, required super.context});

  @override
  void layout(Constraints constraints) => size = const Size(1, 1);

  @override
  void paint(CellBufferBuilder buffer, Offset offset) {}
}
