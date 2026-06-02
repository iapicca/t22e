import 'package:capability/capability.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';

void main() {
  group('da1ProbeProvider', () {
    test('creates a Da1Probe', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final probe = container.read(da1ProbeProvider);
      expect(probe, isA<Da1Probe>());
      expect(probe.isDisposed, isFalse);
    });

    test('disposes on container dispose', () {
      final container = ProviderContainer();
      final probe = container.read(da1ProbeProvider);
      container.dispose();

      expect(probe.isDisposed, isTrue);
    });
  });

  group('colorProbeProvider', () {
    test('creates a ColorProbe', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final probe = container.read(colorProbeProvider);
      expect(probe, isA<ColorProbe>());
      expect(probe.isDisposed, isFalse);
    });

    test('disposes on container dispose', () {
      final container = ProviderContainer();
      final probe = container.read(colorProbeProvider);
      container.dispose();

      expect(probe.isDisposed, isTrue);
    });

    test('detectFromEnv returns a ColorProfile', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final probe = container.read(colorProbeProvider);
      final profile = probe.detectFromEnv();
      expect(profile, isNotNull);
    });
  });

  group('syncProbeProvider', () {
    test('creates a SyncProbe', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final probe = container.read(syncProbeProvider);
      expect(probe, isA<SyncProbe>());
      expect(probe.isDisposed, isFalse);
    });

    test('disposes on container dispose', () {
      final container = ProviderContainer();
      final probe = container.read(syncProbeProvider);
      container.dispose();

      expect(probe.isDisposed, isTrue);
    });
  });

  group('keyboardProbeProvider', () {
    test('creates a KeyboardProbe', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final probe = container.read(keyboardProbeProvider);
      expect(probe, isA<KeyboardProbe>());
      expect(probe.isDisposed, isFalse);
    });

    test('disposes on container dispose', () {
      final container = ProviderContainer();
      final probe = container.read(keyboardProbeProvider);
      container.dispose();

      expect(probe.isDisposed, isTrue);
    });
  });

  group('probePipelineProvider', () {
    test('creates a ProbePipeline', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final pipeline = container.read(probePipelineProvider);
      expect(pipeline, isA<ProbePipeline>());
    });

    test('pipeline has non-null probes', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final pipeline = container.read(probePipelineProvider);
      expect(pipeline.da1Probe, isNotNull);
      expect(pipeline.colorProbe, isNotNull);
      expect(pipeline.syncProbe, isNotNull);
      expect(pipeline.keyboardProbe, isNotNull);
    });
  });
}
