import 'package:notifier/notifier.dart';
import 'package:test/test.dart';

int _counter = 0;

void _listener() {
  _counter++;
}

void main() {
  setUp(() => _counter = 0);

  group('ChangeNotifier', () {
    test('hasListeners is false initially', () {
      final cn = ChangeNotifier();
      expect(cn.hasListeners, isFalse);
    });

    test('addListener registers listener', () {
      final cn = ChangeNotifier();
      cn.addListener(_listener);
      expect(cn.hasListeners, isTrue);
    });

    test('removeListener unregisters listener', () {
      final cn = ChangeNotifier();
      cn.addListener(_listener);
      cn.removeListener(_listener);
      expect(cn.hasListeners, isFalse);
    });

    test('notifyListeners calls all registered listeners', () {
      final cn = ChangeNotifier();
      cn.addListener(_listener);
      cn.notifyListeners();
      expect(_counter, 1);
    });

    test('notifyListeners calls multiple listeners', () {
      final cn = ChangeNotifier();
      var a = 0;
      var b = 0;
      cn.addListener(() => a++);
      cn.addListener(() => b++);
      cn.notifyListeners();
      expect(a, 1);
      expect(b, 1);
    });

    test('duplicate listener is not added', () {
      final cn = ChangeNotifier();
      cn.addListener(_listener);
      cn.addListener(_listener);
      cn.notifyListeners();
      expect(_counter, 1);
    });

    test('removing non-existent listener is safe', () {
      final cn = ChangeNotifier();
      void other() {}
      expect(() => cn.removeListener(other), returnsNormally);
    });

    test('listener can add another listener during notification', () {
      final cn = ChangeNotifier();
      var called = false;
      cn.addListener(() {
        cn.addListener(() => called = true);
      });
      cn.notifyListeners();
      expect(cn.hasListeners, isTrue);
      expect(called, isFalse); // added after iteration
    });

    test('listener can remove itself during notification', () {
      final cn = ChangeNotifier();
      late void Function() self;
      self = () {
        _counter++;
        cn.removeListener(self);
      };
      cn.addListener(self);
      cn.notifyListeners();
      expect(_counter, 1);
      expect(cn.hasListeners, isFalse);
    });

    test('notifyListeners copies list for safe iteration', () {
      final cn = ChangeNotifier();
      cn.addListener(_listener);
      cn.addListener(() {
        cn.removeListener(_listener);
      });
      // Both listeners should fire because iteration is on a copy.
      cn.notifyListeners();
      // _counter should be 1 (from _listener) even though it was
      // removed during notification.
      expect(_counter, 1);
    });

    test('dispose clears listeners and marks disposed', () {
      final cn = ChangeNotifier();
      cn.addListener(_listener);
      cn.dispose(null);
      expect(cn.isDisposed, isTrue);
      expect(cn.hasListeners, isFalse);
    });

    test('addListener throws after dispose', () {
      final cn = ChangeNotifier();
      cn.dispose(null);
      expect(() => cn.addListener(_listener), throwsStateError);
    });

    test('removeListener throws after dispose', () {
      final cn = ChangeNotifier();
      cn.dispose(null);
      expect(() => cn.removeListener(_listener), throwsStateError);
    });

    test('notifyListeners throws after dispose', () {
      final cn = ChangeNotifier();
      cn.dispose(null);
      expect(() => cn.notifyListeners(), throwsStateError);
    });

    test('custom message on addListener after dispose', () {
      final cn = ChangeNotifier();
      cn.dispose(null);
      expect(
        () => cn.addListener(_listener, message: 'Nope'),
        throwsA(
          isA<StateError>().having((e) => e.message, 'message', 'Nope'),
        ),
      );
    });

    test('custom message on notifyListeners after dispose', () {
      final cn = ChangeNotifier();
      cn.dispose(null);
      expect(
        () => cn.notifyListeners(message: 'Gone'),
        throwsA(
          isA<StateError>().having((e) => e.message, 'message', 'Gone'),
        ),
      );
    });
  });
}
