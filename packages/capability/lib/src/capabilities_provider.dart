import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:terminal/terminal.dart' show terminalIoProvider;

import 'color_probe_provider.dart' show colorProbeProvider;
import 'da1_probe_provider.dart' show da1ProbeProvider;
import 'keyboard_probe_provider.dart' show keyboardProbeProvider;
import 'sync_probe_provider.dart' show syncProbeProvider;
import 'result.dart' show Capabilities;

part 'capabilities_provider.g.dart';

/// Aggregates all capability probes into a single result.
@riverpod
Future<Capabilities> capabilities(Ref ref) async {
  final da1 = await ref.read(da1ProbeProvider)();
  final color = await ref.read(colorProbeProvider)(da1);
  final syncSupported = await ref.read(syncProbeProvider)();
  final keyboard = await ref.read(keyboardProbeProvider)();
  final io = ref.read(terminalIoProvider);

  return Capabilities(
    da1: da1,
    colorProfile: color,
    syncSupported: syncSupported,
    keyboardProtocol: keyboard,
    cols: io.columns,
    rows: io.rows,
  );
}
