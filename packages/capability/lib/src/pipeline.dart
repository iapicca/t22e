import 'package:terminal/terminal.dart' show TerminalIo, RealTerminalIo;
import 'result.dart' show Capabilities;
import 'da1_probe.dart' show Da1Probe;
import 'color_probe.dart' show ColorProbe;
import 'sync_probe.dart' show SyncProbe;
import 'keyboard_probe.dart' show KeyboardProbe;

class ProbePipeline {
  final Da1Probe da1Probe;
  final ColorProbe colorProbe;
  final SyncProbe syncProbe;
  final KeyboardProbe keyboardProbe;
  final TerminalIo _io;

  ProbePipeline({
    Da1Probe? da1Probe,
    ColorProbe? colorProbe,
    SyncProbe? syncProbe,
    KeyboardProbe? keyboardProbe,
    TerminalIo? io,
  }) : _io = io ?? const RealTerminalIo(),
       da1Probe = da1Probe ?? Da1Probe(io: io),
       colorProbe = colorProbe ?? ColorProbe(io: io),
       syncProbe = syncProbe ?? SyncProbe(io: io),
       keyboardProbe = keyboardProbe ?? KeyboardProbe(io: io);

  Future<Capabilities> run() async {
    final da1 = await da1Probe.probe();
    final color = await colorProbe.probe(da1);
    final syncSupported = await syncProbe.probe();
    final keyboard = await keyboardProbe.probe();
    final cols = _io.columns;
    final rows = _io.rows;

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
