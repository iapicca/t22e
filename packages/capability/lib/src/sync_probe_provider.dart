import 'package:parser/terminal_parser.dart' show terminalParserProvider;
import 'package:protocol/protocol.dart' show Defaults;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:terminal/terminal.dart' show terminalIoProvider;

import 'sync_probe.dart' as probe;

part 'sync_probe_provider.g.dart';

typedef SyncProbe = Future<bool> Function({
  Duration? timeout,
});

@riverpod
SyncProbe syncProbe(Ref ref) {
  final io = ref.read(terminalIoProvider);
  final parser = ref.read(terminalParserProvider);
  return ({timeout}) => probe.probeSync(io, parser, timeout: timeout ?? Defaults.defaultProbeTimeout);
}
