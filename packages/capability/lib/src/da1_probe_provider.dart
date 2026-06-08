import 'package:parser/terminal_parser.dart' show terminalParserProvider;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:terminal/terminal.dart' show systemIoProvider;


import 'da1_probe.dart' show probeDa1;
import 'probe_definitions.dart' show Da1Probe;
import 'probe_timeout_provider.dart' show probeTimeoutProvider;

part 'da1_probe_provider.g.dart';

@riverpod
/// Probe for primary device attributes (DA1) support.
Da1Probe da1Probe(Ref ref) {
  final io = ref.read(systemIoProvider);
  final parser = ref.read(terminalParserProvider);
  final timeout = ref.read(probeTimeoutProvider);
  return probeDa1(
    io,
    parser,
    timeout,
  );
}
