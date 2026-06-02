import 'package:parser/terminal_parser.dart' show terminalParserProvider;
import 'package:protocol/protocol.dart' show Defaults;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:terminal/terminal.dart' show terminalIoProvider;

import 'da1_probe.dart' as probe;
import 'result.dart' show QueryResult, Da1Result;

part 'da1_probe_provider.g.dart';

typedef Da1Probe = Future<QueryResult<Da1Result>> Function({
  Duration? timeout,
});

@riverpod
Da1Probe da1Probe(Ref ref) {
  final io = ref.read(terminalIoProvider);
  final parser = ref.read(terminalParserProvider);
  return ({timeout}) => probe.probeDa1(io, parser, timeout: timeout ?? Defaults.defaultProbeTimeout);
}
