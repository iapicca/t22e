import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'da1_probe.dart';
import 'color_probe.dart';
import 'sync_probe.dart';
import 'keyboard_probe.dart';
import 'pipeline.dart';

part 'providers.g.dart';

/// Factory provider that creates a [Da1Probe] managed by Riverpod.
///
/// Riverpod handles disposal automatically via [ref.onDispose].
@riverpod
Da1Probe da1Probe(Ref ref) {
  final probe = Da1Probe();
  ref.onDispose(() => probe.dispose(null));
  return probe;
}

/// Factory provider that creates a [ColorProbe] managed by Riverpod.
///
/// Riverpod handles disposal automatically via [ref.onDispose].
@riverpod
ColorProbe colorProbe(Ref ref) {
  final probe = ColorProbe();
  ref.onDispose(() => probe.dispose(null));
  return probe;
}

/// Factory provider that creates a [SyncProbe] managed by Riverpod.
///
/// Riverpod handles disposal automatically via [ref.onDispose].
@riverpod
SyncProbe syncProbe(Ref ref) {
  final probe = SyncProbe();
  ref.onDispose(() => probe.dispose(null));
  return probe;
}

/// Factory provider that creates a [KeyboardProbe] managed by Riverpod.
///
/// Riverpod handles disposal automatically via [ref.onDispose].
@riverpod
KeyboardProbe keyboardProbe(Ref ref) {
  final probe = KeyboardProbe();
  ref.onDispose(() => probe.dispose(null));
  return probe;
}

/// Factory provider that creates a [ProbePipeline] managed by Riverpod.
///
/// The pipeline aggregates all probes and provides a single [run()] method
/// to detect terminal capabilities.
///
/// Example:
/// ```dart
/// final container = ProviderContainer();
/// final pipeline = container.read(probePipelineProvider);
/// final capabilities = await pipeline.run();
/// container.dispose();
/// ```
@riverpod
ProbePipeline probePipeline(Ref ref) {
  return ProbePipeline(
    da1Probe: ref.watch(da1ProbeProvider),
    colorProbe: ref.watch(colorProbeProvider),
    syncProbe: ref.watch(syncProbeProvider),
    keyboardProbe: ref.watch(keyboardProbeProvider),
  );
}
