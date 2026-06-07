import 'package:parser/terminal_parser.dart' show terminalParserProvider;
import 'package:protocol/protocol.dart' show Defaults;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:terminal/terminal.dart' show systemIoProvider;

import 'sync_probe.dart' as probe;

part 'sync_probe_provider.g.dart';

/// Type alias for the sync probe function.
typedef SyncProbe = Future<bool> Function({Duration? timeout});

@riverpod
/// Probe for synchronized update (DEC 2026) support.
SyncProbe syncProbe(Ref ref) {
  final io = ref.read(systemIoProvider);
  final parser = ref.read(terminalParserProvider);
  return ({timeout}) => probe.probeSync(
    io,
    parser,
    timeout: timeout ?? Defaults.defaultProbeTimeout,
  );
}
