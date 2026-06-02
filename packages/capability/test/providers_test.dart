import 'package:capability/capability.dart';
import 'package:core/core.dart' show ColorProfile;
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';

void main() {
  group('da1ProbeProvider', () {
    test('returns a function', () {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final probeFn = container.read(da1ProbeProvider);
      expect(probeFn, isA<Function>());
    });
  });

  group('colorProbeProvider', () {
    test('returns a function', () {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final probeFn = container.read(colorProbeProvider);
      expect(probeFn, isA<Function>());
    });

    test('colorFromEnvProvider returns a function', () {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final fn = container.read(colorFromEnvProvider);
      expect(fn, isA<Function>());
    });

    test('detectColorFromEnv returns a ColorProfile', () {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final fn = container.read(colorFromEnvProvider);
      final profile = fn();
      expect(profile, isA<ColorProfile>());
    });
  });

  group('syncProbeProvider', () {
    test('returns a function', () {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final probeFn = container.read(syncProbeProvider);
      expect(probeFn, isA<Function>());
    });
  });

  group('keyboardProbeProvider', () {
    test('returns a function', () {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final probeFn = container.read(keyboardProbeProvider);
      expect(probeFn, isA<Function>());
    });
  });

  group('capabilitiesProvider', () {
    test('provider is defined', () {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final future = container.read(capabilitiesProvider.future);
      expect(future, isA<Future<Capabilities>>());
    });
  });

  group('QueryResult', () {
    test('supported holds value', () {
      final result = QueryResult.supported(42);
      expect(result, isA<Supported<int>>());
      if (result is Supported<int>) {
        expect(result.value, 42);
      }
    });

    test('unavailable has no value', () {
      const result = QueryResult.unavailable();
      expect(result, isA<Unavailable>());
    });

    test('equality', () {
      expect(QueryResult.supported(1), QueryResult.supported(1));
      expect(QueryResult.supported(1), isNot(QueryResult.supported(2)));
      expect(const QueryResult.unavailable(), const QueryResult.unavailable());
    });
  });

  group('Da1Result', () {
    test('constructs with terminal id and attributes', () {
      final result = Da1Result(65, [22, 28]);
      expect(result.terminalId, 65);
      expect(result.attributes, [22, 28]);
    });
  });

  group('KeyboardProtocol', () {
    test('enum values', () {
      expect(KeyboardProtocol.basic.index, 0);
      expect(KeyboardProtocol.kitty.index, 1);
    });
  });

  group('Capabilities', () {
    test('defaults', () {
      const caps = Capabilities();
      expect(caps.da1, isA<Unavailable>());
      expect(caps.colorProfile, ColorProfile.ansi16);
      expect(caps.syncSupported, isFalse);
      expect(caps.keyboardProtocol, KeyboardProtocol.basic);
      expect(caps.rows, 24);
      expect(caps.cols, 80);
    });

    test('custom values', () {
      final da1 = QueryResult.supported(Da1Result(65, [22, 28]));
      final caps = Capabilities(
        da1: da1,
        colorProfile: ColorProfile.trueColor,
        syncSupported: true,
        keyboardProtocol: KeyboardProtocol.kitty,
        rows: 40,
        cols: 120,
      );
      expect(caps.da1, da1);
      expect(caps.colorProfile, ColorProfile.trueColor);
      expect(caps.syncSupported, isTrue);
      expect(caps.keyboardProtocol, KeyboardProtocol.kitty);
      expect(caps.rows, 40);
      expect(caps.cols, 120);
    });
  });
}
