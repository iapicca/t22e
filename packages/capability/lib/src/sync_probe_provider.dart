import 'package:parser/terminal_parser.dart' show terminalParserProvider;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:terminal/terminal.dart' show systemIoProvider;

import 'probe_definitions.dart' show SyncProbe;
import 'probe_timeout_provider.dart' show probeTimeoutProvider;
import 'sync_probe.dart';

part 'sync_probe_provider.g.dart';

@riverpod
/// Probe for synchronized update (DEC 2026) support.
SyncProbe syncProbe(Ref ref) {
  final io = ref.read(systemIoProvider);
  final parser = ref.read(terminalParserProvider);
  final timeout = ref.read(probeTimeoutProvider);
  return probeSync(io, parser, timeout);
}
