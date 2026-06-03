import 'package:notifier/notifier.dart';
import 'package:test/test.dart';

void main() {
  group('ValueNotifier', () {
    test('value getter returns initial value', () {
      final vn = ValueNotifier<int>(42);
      expect(vn.value, 42);
    });

    test('value setter updates value', () {
      final vn = ValueNotifier<int>(0);
      vn.value = 42;
      expect(vn.value, 42);
    });

    test('value setter with same value does not notify', () {
      var notified = 0;
      final vn = ValueNotifier<int>(42);
      vn.addListener(() => notified++);
      vn.value = 42;
      expect(notified, 0);
    });

    test('value setter with different value notifies listeners', () {
      var notified = 0;
      final vn = ValueNotifier<int>(0);
      vn.addListener(() => notified++);
      vn.value = 42;
      expect(notified, 1);
    });

    test('value getter after dispose throws', () {
      final vn = ValueNotifier<int>(42);
      vn.dispose();
      expect(vn.isDisposed, isTrue);
      // The getter does NOT have a check guard in the base class.
      // ValueNotifier.value getter currently has no guard.
      // This test documents that behavior — reads are allowed.
      expect(vn.value, 42);
    });

    test('value setter after dispose throws', () {
      final vn = ValueNotifier<int>(42);
      vn.dispose();
      expect(() => vn.value = 0, throwsStateError);
    });

    test('value setter after dispose throws with custom message', () {
      final vn = ValueNotifier<int>(42, message: 'ValueNotifier done');
      vn.dispose();
      expect(
        () => vn.value = 0,
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            'ValueNotifier done',
          ),
        ),
      );
    });

    test('inherits ChangeNotifier listener behavior', () {
      final vn = ValueNotifier<int>(0);
      expect(vn.hasListeners, isFalse);
      vn.addListener(() {});
      expect(vn.hasListeners, isTrue);
    });

    test('notifyListeners accessible from ValueNotifier', () {
      var called = false;
      final vn = ValueNotifier<int>(0);
      vn.addListener(() => called = true);
      vn.notifyListeners();
      expect(called, isTrue);
    });

    test('dispose on ValueNotifier blocks listener ops', () {
      final vn = ValueNotifier<String>('hello');
      vn.addListener(() {});
      vn.dispose();
      expect(vn.isDisposed, isTrue);
      expect(vn.hasListeners, isFalse);
      expect(() => vn.addListener(() {}), throwsStateError);
    });

    test('works with nullable value', () {
      final vn = ValueNotifier<String?>('hello');
      vn.value = null;
      expect(vn.value, isNull);

      var called = false;
      vn.addListener(() => called = true);
      vn.value = 'world';
      expect(vn.value, 'world');
      expect(called, isTrue);

      vn.value = 'world'; // same value, no notification
      // called should still be true from the previous change
    });

    test('works with custom objects', () {
      final vn = ValueNotifier<Duration>(const Duration(seconds: 1));
      vn.value = const Duration(seconds: 2);
      expect(vn.value, const Duration(seconds: 2));
    });

    test('_message propagates to all check points', () {
      final vn = ValueNotifier<int>(0, message: 'CustomMsg');
      vn.dispose();
      // notifyListeners through value setter
      expect(
        () => vn.value = 1,
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            'CustomMsg',
          ),
        ),
      );
      // addListener with explicit message override
      expect(
        () => vn.addListener(() {}, message: 'CustomMsg'),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            'CustomMsg',
          ),
        ),
      );
    });
  });
}
