import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:terminal/terminal.dart' show terminalIoProvider;

import 'da1_probe.dart';
import 'color_probe.dart';
import 'sync_probe.dart';
import 'keyboard_probe.dart';
import 'result.dart' show Capabilities;

part 'providers.g.dart';

/// Factory provider that creates a [Da1Probe] managed by Riverpod.
///
/// Riverpod handles disposal automatically via [ref.onDispose].
@riverpod
Da1Probe da1Probe(Ref ref) {
  final probe = Da1Probe(io: ref.watch(terminalIoProvider));
  ref.onDispose(() => probe.dispose(null));
  return probe;
}

/// Factory provider that creates a [ColorProbe] managed by Riverpod.
///
/// Riverpod handles disposal automatically via [ref.onDispose].
@riverpod
ColorProbe colorProbe(Ref ref) {
  final probe = ColorProbe(io: ref.watch(terminalIoProvider));
  ref.onDispose(() => probe.dispose(null));
  return probe;
}

/// Factory provider that creates a [SyncProbe] managed by Riverpod.
///
/// Riverpod handles disposal automatically via [ref.onDispose].
@riverpod
SyncProbe syncProbe(Ref ref) {
  final probe = SyncProbe(io: ref.watch(terminalIoProvider));
  ref.onDispose(() => probe.dispose(null));
  return probe;
}

/// Factory provider that creates a [KeyboardProbe] managed by Riverpod.
///
/// Riverpod handles disposal automatically via [ref.onDispose].
@riverpod
KeyboardProbe keyboardProbe(Ref ref) {
  final probe = KeyboardProbe(io: ref.watch(terminalIoProvider));
  ref.onDispose(() => probe.dispose(null));
  return probe;
}

/// Async provider that runs the full capability detection pipeline.
///
/// Example:
/// ```dart
/// final container = ProviderContainer();
/// final capabilities = await container.read(capabilitiesProvider.future);
/// print(capabilities.da1);
/// container.dispose();
/// ```
@riverpod
Future<Capabilities> capabilities(Ref ref) async {
  final da1Probe = ref.watch(da1ProbeProvider);
  final colorProbe = ref.watch(colorProbeProvider);
  final syncProbe = ref.watch(syncProbeProvider);
  final keyboardProbe = ref.watch(keyboardProbeProvider);
  final io = ref.watch(terminalIoProvider);

  final da1 = await da1Probe.probe();
  final color = await colorProbe.probe(da1);
  final syncSupported = await syncProbe.probe();
  final keyboard = await keyboardProbe.probe();

  return Capabilities(
    da1: da1,
    colorProfile: color,
    syncSupported: syncSupported,
    keyboardProtocol: keyboard,
    cols: io.columns,
    rows: io.rows,
  );
}
