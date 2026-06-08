import 'package:parser/terminal_parser.dart' show terminalParserProvider;
import 'package:protocol/protocol.dart' show Defaults;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:terminal/terminal.dart' show systemIoProvider;

import 'capabilities_definitions.dart' show Da1Probe;
import 'da1_probe.dart' show probeDa1;

part 'da1_probe_provider.g.dart';

@riverpod
/// Probe for primary device attributes (DA1) support.
Da1Probe da1Probe(Ref ref) {
  final io = ref.read(systemIoProvider);
  final parser = ref.read(terminalParserProvider);
  return ([timeout]) => probeDa1(
    io,
    parser,
    timeout: timeout ?? Defaults.defaultProbeTimeout,
  );
}
