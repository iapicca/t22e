import 'package:capability/capability.dart';
import 'package:core/core.dart' show ColorProfile;
import 'package:protocol/protocol.dart' show Defaults;
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';

void main() {
  group('da1ProbeProvider', () {
    test('returns a Da1Query future', () {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final future = container.read(da1ProbeProvider.future);
      expect(future, isA<Future<Da1Query>>());
    });
  });

  group('colorProbeProvider', () {
    test('returns a ColorProfile future', () {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final future = container.read(colorProbeProvider.future);
      expect(future, isA<Future<ColorProfile>>());
    });

    test('colorFromEnvProvider returns a function', () {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final fn = container.read(colorFromEnvProvider);
      expect(fn, isA<ColorProfile>());
    });

    test('detectColorFromEnv returns a ColorProfile', () {
      expect(detectColorFromEnv({}), isA<ColorProfile>());
    });
  });

  group('syncProbeProvider', () {
    test('returns a bool future', () {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final future = container.read(syncProbeProvider.future);
      expect(future, isA<Future<bool>>());
    });
  });

  group('keyboardProbeProvider', () {
    test('returns a KeyboardProtocol future', () {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final future = container.read(keyboardProbeProvider.future);
      expect(future, isA<Future<KeyboardProtocol>>());
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

    test('when destructures supported', () {
      final result = Da1Query.supported(65, [22, 28]);
      final output = result.when(
        supported: (id, attrs) => '$id:$attrs',
        unsupported: () => 'none',
      );
      expect(output, '65:[22, 28]');
    });

    test('when handles unsupported', () {
      const result = Da1Query.unsupported();
      final output = result.when(
        supported: (id, attrs) => '$id:$attrs',
        unsupported: () => 'none',
      );
      expect(output, 'none');
    });
  });

  group('Da1Value', () {
    test('constructs with terminal id and attributes', () {
      final result = Da1Value(65, [22, 28]);
      expect(result.terminalId, 65);
      expect(result.attributes, [22, 28]);
    });

    test('equality same values', () {
      expect(Da1Value(1, [2, 3]), Da1Value(1, [2, 3]));
    });

    test('equality different terminalId', () {
      expect(Da1Value(1, [2, 3]), isNot(Da1Value(2, [2, 3])));
    });

    test('equality different attributes', () {
      expect(Da1Value(1, [2, 3]), isNot(Da1Value(1, [4, 5])));
    });

    test('hashCode consistent', () {
      expect(Da1Value(1, [2, 3]).hashCode, Da1Value(1, [2, 3]).hashCode);
    });

    test('is a Da1Query', () {
      expect(Da1Value(0, []), isA<Da1Query>());
    });
  });

  group('Da1QueryUnsupported', () {
    test('all instances equal', () {
      expect(const Da1QueryUnsupported(), const Da1QueryUnsupported());
    });

    test('hashCode consistent', () {
      expect(
        const Da1QueryUnsupported().hashCode,
        const Da1QueryUnsupported().hashCode,
      );
    });

    test('is a Da1Query', () {
      expect(const Da1QueryUnsupported(), isA<Da1Query>());
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

    test('copyWith overrides fields', () {
      final original = Capabilities.defaults();
      final copied = original.copyWith(
        colorProfile: ColorProfile.trueColor,
        syncSupported: true,
      );
      expect(copied.colorProfile, ColorProfile.trueColor);
      expect(copied.syncSupported, isTrue);
      expect(copied.da1, original.da1);
      expect(copied.keyboardProtocol, original.keyboardProtocol);
      expect(copied.rows, original.rows);
      expect(copied.cols, original.cols);
    });

    test('equality same values', () {
      final da1 = Da1Query.supported(65, [22, 28]);
      final a = Capabilities(
        da1: da1,
        colorProfile: ColorProfile.trueColor,
        syncSupported: true,
        keyboardProtocol: KeyboardProtocol.kitty,
        rows: 40,
        cols: 120,
      );
      final b = Capabilities(
        da1: da1,
        colorProfile: ColorProfile.trueColor,
        syncSupported: true,
        keyboardProtocol: KeyboardProtocol.kitty,
        rows: 40,
        cols: 120,
      );
      expect(a, b);
    });

    test('equality different values', () {
      final a = Capabilities.defaults();
      final b = Capabilities.defaults().copyWith(syncSupported: true);
      expect(a, isNot(b));
    });

    test('hashCode consistent', () {
      final da1 = Da1Query.supported(65, [22, 28]);
      final a = Capabilities(
        da1: da1,
        colorProfile: ColorProfile.trueColor,
        syncSupported: true,
        keyboardProtocol: KeyboardProtocol.kitty,
        rows: 40,
        cols: 120,
      );
      final b = Capabilities(
        da1: da1,
        colorProfile: ColorProfile.trueColor,
        syncSupported: true,
        keyboardProtocol: KeyboardProtocol.kitty,
        rows: 40,
        cols: 120,
      );
      expect(a.hashCode, b.hashCode);
    });
  });

  group('detectColorFromEnv', () {
    test('COLORTERM=truecolor returns trueColor', () {
      expect(
        detectColorFromEnv({'COLORTERM': Defaults.envColortermTruecolor}),
        ColorProfile.trueColor,
      );
    });

    test('COLORTERM=24bit returns trueColor', () {
      expect(
        detectColorFromEnv({'COLORTERM': Defaults.envColorterm24bit}),
        ColorProfile.trueColor,
      );
    });

    test('TERM ending with -256color returns indexed256', () {
      expect(
        detectColorFromEnv({'TERM': 'xterm-256color'}),
        ColorProfile.indexed256,
      );
    });

    test('TERM ending with -truecolor returns trueColor', () {
      expect(
        detectColorFromEnv({'TERM': 'xterm-truecolor'}),
        ColorProfile.trueColor,
      );
    });

    test('TERM ending with -direct returns trueColor', () {
      expect(
        detectColorFromEnv({'TERM': 'xterm-direct'}),
        ColorProfile.trueColor,
      );
    });

    test('empty env returns ansi16', () {
      expect(detectColorFromEnv({}), ColorProfile.ansi16);
    });

    test('unknown TERM returns ansi16', () {
      expect(detectColorFromEnv({'TERM': 'vt100'}), ColorProfile.ansi16);
    });
  });

  group('detectColorFromDa1', () {
    test('trueColor attribute returns trueColor', () {
      final da1 = Da1Query.supported(65, [Defaults.da1AttrTrueColor]);
      expect(detectColorFromDa1(da1), ColorProfile.trueColor);
    });

    test('256 color attribute returns indexed256', () {
      final da1 = Da1Query.supported(65, [Defaults.da1AttrIndexed256]);
      expect(detectColorFromDa1(da1), ColorProfile.indexed256);
    });

    test('no color attributes returns ansi16', () {
      final da1 = Da1Query.supported(65, [1, 2, 3]);
      expect(detectColorFromDa1(da1), ColorProfile.ansi16);
    });

    test('empty attributes returns ansi16', () {
      final da1 = Da1Query.supported(65, []);
      expect(detectColorFromDa1(da1), ColorProfile.ansi16);
    });

    test('unsupported returns ansi16', () {
      const da1 = Da1Query.unsupported();
      expect(detectColorFromDa1(da1), ColorProfile.ansi16);
    });
  });
}
