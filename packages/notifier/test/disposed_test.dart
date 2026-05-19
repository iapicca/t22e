import 'package:notifier/notifier.dart';
import 'package:test/test.dart';

void main() {
  group('Disposed', () {
    test('not disposed by default', () {
      final d = const Disposed();
      expect(d.safeCheck, isFalse);
    });

    test('constructed as disposed', () {
      final d = const Disposed(isDisposed: true);
      expect(d.safeCheck, isTrue);
    });

    test('check does not throw when not disposed', () {
      const d = Disposed();
      expect(() => d.check(), returnsNormally);
    });

    test('check throws StateError when disposed', () {
      final d = const Disposed(isDisposed: true);
      expect(() => d.check(), throwsStateError);
    });

    test('check uses custom message when disposed', () {
      final d = const Disposed(isDisposed: true);
      expect(
        () => d.check(message: 'Custom error'),
        throwsA(
          isA<StateError>().having((e) => e.message, 'message', 'Custom error'),
        ),
      );
    });

    test('check default message when disposed', () {
      final d = const Disposed(isDisposed: true);
      expect(
        () => d.check(),
        throwsA(
          isA<StateError>().having((e) => e.message, 'message', 'Disposed'),
        ),
      );
    });

    test('safeCheck is false before dispose', () {
      const d = Disposed();
      expect(d.safeCheck, isFalse);
    });

    test('const Disposed(isDisposed: true) marks disposed', () {
      final d = const Disposed(isDisposed: true);
      expect(d.safeCheck, isTrue);
    });

    test('const Disposed() marks not disposed', () {
      final d = const Disposed();
      expect(d.safeCheck, isFalse);
    });
  });
}
