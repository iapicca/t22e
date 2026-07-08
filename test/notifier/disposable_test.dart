import 'package:t22e/t22e.dart';
import 'package:test/test.dart';

class _TestResource with Disposable {
  int callCount = 0;

  void doWork({String? message}) {
    check(message: message);
    callCount++;
  }

  @override
  void dispose({String? message}) {
    super.dispose(message: message);
    callCount = -1;
  }
}

void main() {
  group('Disposable', () {
    test('isDisposed is false initially', () {
      final r = _TestResource();
      expect(r.isDisposed, isFalse);
    });

    test('doWork succeeds before dispose', () {
      final r = _TestResource();
      expect(() => r.doWork(), returnsNormally);
      expect(r.callCount, 1);
    });

    test('dispose marks as disposed and runs cleanup', () {
      final r = _TestResource();
      r.dispose();
      expect(r.isDisposed, isTrue);
      expect(r.callCount, -1);
    });

    test('doWork throws after dispose', () {
      final r = _TestResource();
      r.dispose();
      expect(() => r.doWork(), throwsStateError);
    });

    test('dispose is idempotent (throws on second call)', () {
      final r = _TestResource();
      r.dispose();
      expect(() => r.dispose(), throwsStateError);
    });

    test('check throws with custom message', () {
      final r = _TestResource();
      r.dispose();
      expect(
        () => r.doWork(message: 'Cannot use: disposed'),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            'Cannot use: disposed',
          ),
        ),
      );
    });
  });
}
