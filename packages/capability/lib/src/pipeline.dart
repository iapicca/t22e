import 'dart:io';

import 'result.dart' show Capabilities;
import 'da1_probe.dart' show Da1Probe;
import 'color_probe.dart' show ColorProbe;
import 'sync_probe.dart' show SyncProbe;
import 'keyboard_probe.dart' show KeyboardProbe;

/// Orchestrates all capability probes and returns a complete Capabilities result.
class ProbePipeline {
  /// DA1 (device attributes) probe.
  final Da1Probe da1Probe;
  /// Color support probe.
  final ColorProbe colorProbe;
  /// Sync update support probe.
  final SyncProbe syncProbe;
  /// Keyboard protocol probe.
  final KeyboardProbe keyboardProbe;

  ProbePipeline({
    Da1Probe? da1Probe,
    ColorProbe? colorProbe,
    SyncProbe? syncProbe,
    KeyboardProbe? keyboardProbe,
  }) : da1Probe = da1Probe ?? Da1Probe(),
       colorProbe = colorProbe ?? ColorProbe(),
       syncProbe = syncProbe ?? SyncProbe(),
       keyboardProbe = keyboardProbe ?? KeyboardProbe();

  /// Runs all probes sequentially and aggregates results.
  Future<Capabilities> run() async {
    final da1 = await da1Probe.probe();
    final color = await colorProbe.probe(da1);
    final syncSupported = await syncProbe.probe();
    final keyboard = await keyboardProbe.probe();
    final cols = stdout.terminalColumns;
    final rows = stdout.terminalLines;

    return Capabilities(
      da1: da1,
      colorProfile: color,
      syncSupported: syncSupported,
      keyboardProtocol: keyboard,
      cols: cols,
      rows: rows,
    );
  }
}
