import 'package:parser/terminal_parser.dart' show terminalParserProvider;
import 'package:protocol/protocol.dart' show Defaults;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:terminal/terminal.dart' show terminalIoProvider;

import 'da1_probe.dart' as probe;
import 'result.dart' show QueryResult, Da1Result;

part 'da1_probe_provider.g.dart';

typedef Da1ProbeFn = Future<QueryResult<Da1Result>> Function({
  Duration? timeout,
});

@riverpod
Da1ProbeFn da1Probe(Ref ref) {
  final io = ref.watch(terminalIoProvider);
  final parser = ref.watch(terminalParserProvider);
  return ({timeout}) => probe.probeDa1(io, parser, timeout: timeout ?? Defaults.defaultProbeTimeout);
}
