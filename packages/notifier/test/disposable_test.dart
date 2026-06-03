import 'package:notifier/notifier.dart';
import 'package:test/test.dart';

// Test class using the Disposable mixin directly.
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

    test('super.dispose must be called (verifies chain)', () {
      final r = _TestResource();
      // The _TestResource.dispose calls super.dispose which sets isDisposed
      r.dispose();
      expect(r.isDisposed, isTrue);
    });
  });
}
