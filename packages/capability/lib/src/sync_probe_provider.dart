import 'package:parser/terminal_parser.dart' show terminalParserProvider;
import 'package:protocol/protocol.dart' show Defaults;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:terminal/terminal.dart' show terminalIoProvider;

import 'sync_probe.dart' as probe;

part 'sync_probe_provider.g.dart';

typedef SyncProbeFn = Future<bool> Function({
  Duration? timeout,
});

@riverpod
SyncProbeFn syncProbe(Ref ref) {
  final io = ref.watch(terminalIoProvider);
  final parser = ref.watch(terminalParserProvider);
  return ({timeout}) => probe.probeSync(io, parser, timeout: timeout ?? Defaults.defaultProbeTimeout);
}
