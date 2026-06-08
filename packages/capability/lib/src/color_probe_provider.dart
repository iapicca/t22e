import 'package:core/core.dart' show ColorProfile;
import 'package:parser/terminal_parser.dart' show terminalParserProvider;
import 'package:protocol/protocol.dart' show Defaults;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:terminal/terminal.dart' show systemIoProvider;

import 'capabilities_definitions.dart' show ColorProbe;
import 'color_probe.dart' as probe;
import 'da1_probe_provider.dart' show da1ProbeProvider;

part 'color_probe_provider.g.dart';



@riverpod
/// Full color probe: env fallback, then OSC query, then DA1 fallback.
ColorProbe colorProbe(Ref ref) {
  final io = ref.read(systemIoProvider);
  final parser = ref.read(terminalParserProvider);
  final da1Probe = ref.read(da1ProbeProvider);
  return ([timeout]) => da1Probe(timeout).then((da1Result)=> probe.probeColor(
    io,
    parser,
    da1Result,
    timeout: timeout ?? Defaults.defaultProbeTimeout,
  ),);
}
