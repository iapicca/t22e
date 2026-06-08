import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:terminal/terminal.dart' show systemIoProvider;

import 'color_probe_provider.dart' show colorProbeProvider;
import 'keyboard_probe_provider.dart' show keyboardProbeProvider;
import 'sync_probe_provider.dart' show syncProbeProvider;
import 'capabilities.dart' show Capabilities;

part 'capabilities_provider.g.dart';

/// Aggregates all capability probes into a single result.
@riverpod
Future<Capabilities> capabilities(Ref ref) async {
  final io = ref.read(systemIoProvider);
  final color = await ref.read(colorProbeProvider)();
  final syncSupported = await ref.read(syncProbeProvider)();
  final keyboard = await ref.read(keyboardProbeProvider)();

  return Capabilities(
    colorProfile: color,
    syncSupported: syncSupported,
    keyboardProtocol: keyboard,
    cols: io.columns,
    rows: io.rows,
  );
}
