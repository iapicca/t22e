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

  group('Da1Query', () {
    test('supported holds value', () {
      final result = Da1Query.supported(65, [22, 28]);
      expect(result, isA<Da1Value>());
      if (result is Da1Value) {
        expect(result.terminalId, 65);
        expect(result.attributes, [22, 28]);
      }
    });

    test('unsupported has no value', () {
      const result = Da1Query.unsupported();
      expect(result, isA<Da1QueryUnsupported>());
    });

    test('equality', () {
      expect(Da1Query.supported(1, []), Da1Query.supported(1, []));
      expect(Da1Query.supported(1, []), isNot(Da1Query.supported(2, [])));
      expect(const Da1Query.unsupported(), const Da1Query.unsupported());
    });
  });

  group('Da1Value', () {
    test('constructs with terminal id and attributes', () {
      final result = Da1Value(65, [22, 28]);
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
      final caps = Capabilities.defaults();
      expect(caps.da1, isA<Da1QueryUnsupported>());
      expect(caps.colorProfile, ColorProfile.ansi16);
      expect(caps.syncSupported, isFalse);
      expect(caps.keyboardProtocol, KeyboardProtocol.basic);
      expect(caps.rows, 24);
      expect(caps.cols, 80);
    });

    test('custom values', () {
      final da1 = Da1Query.supported(65, [22, 28]);
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
