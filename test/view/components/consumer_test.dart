import 'package:riverpod/riverpod.dart'
    show Notifier, NotifierProvider, Provider, ProviderContainer;
import 'package:t22e/t22e.dart';
import 'package:test/test.dart';

class _Counter extends Notifier<int> {
  @override
  int build() => 42;

  void set(int value) => state = value;
}

final _counterProvider = NotifierProvider<_Counter, int>(_Counter.new);

void main() {
  group('Consumer widget', () {
    test('reads a provider through ref.read and compiles the builder subtree',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final consumer = Consumer(
        builder: (context, ref) => Text('${ref.read(_counterProvider)}'),
      );
      final element = consumer.compile(Context(container));

      expect(element, isA<ConsumerElement>());
      expect(element.widget, same(consumer));
      expect(element.children, isEmpty);

      element.mount(null);
      expect(element.children, hasLength(1));
      final child = element.children.single;
      expect(child, isA<RenderObjectElement<RenderText>>());
      expect(
        (child as RenderObjectElement<RenderText>).renderObject.text,
        '42',
      );
    });

    test('ref.watch obtains the same value as ref.read for this milestone', () {
      final name = Provider<String>((ref) => 'Ada');
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final consumer = Consumer(
        builder: (context, ref) => Text(ref.watch(name)),
      );
      final element = consumer.compile(Context(container))..mount(null);

      final child = element.children.single as RenderObjectElement<RenderText>;
      expect(child.renderObject.text, 'Ada');
    });

    test('reflects updated provider state after a recompile', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final first = Consumer(
        builder: (context, ref) => Text('${ref.read(_counterProvider)}'),
      );
      final firstChild =
          (first.compile(Context(container))..mount(null)).children.single
              as RenderObjectElement<RenderText>;
      expect(firstChild.renderObject.text, '42');

      container.read(_counterProvider.notifier).set(99);

      final second = Consumer(
        builder: (context, ref) => Text('${ref.read(_counterProvider)}'),
      );
      final secondChild =
          (second.compile(Context(container))..mount(null)).children.single
              as RenderObjectElement<RenderText>;
      expect(secondChild.renderObject.text, '99');
    });

    test('is transparent to layout and paint by delegating to its child', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final consumer = Consumer(
        builder: (context, ref) => Text('${ref.read(_counterProvider)}'),
      );
      final element = consumer.compile(Context(container))..mount(null);

      element.layout(Constraints.loose(const Size(20, 10)));
      expect(element.size, const Size(2, 1));

      final builder = CellBufferBuilder(const Size(5, 3));
      element.paint(builder, const Offset(0, 0));
      final buffer = builder.build();
      expect(buffer.get(0, 0).character, '4');
      expect(buffer.get(1, 0).character, '2');
    });
  });
}