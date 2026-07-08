import 'package:t22e/t22e.dart';
import 'package:test/test.dart';

void main() {
  group('Disposed', () {
    test('not disposed by default', () {
      const d = Disposed();
      expect(d.safeCheck, isFalse);
    });

    test('constructed as disposed', () {
      const d = Disposed(isDisposed: true);
      expect(d.safeCheck, isTrue);
    });

    test('check does not throw when not disposed', () {
      const d = Disposed();
      expect(() => d.check(), returnsNormally);
    });

    test('check throws StateError when disposed', () {
      const d = Disposed(isDisposed: true);
      expect(() => d.check(), throwsStateError);
    });

    test('check uses custom message when disposed', () {
      const d = Disposed(isDisposed: true);
      expect(
        () => d.check(message: 'Custom error'),
        throwsA(
          isA<StateError>().having((e) => e.message, 'message', 'Custom error'),
        ),
      );
    });

    test('check default message when disposed', () {
      const d = Disposed(isDisposed: true);
      expect(
        () => d.check(),
        throwsA(
          isA<StateError>().having((e) => e.message, 'message', 'Disposed'),
        ),
      );
    });
  });
}
