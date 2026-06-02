import 'package:core/core.dart' show ColorProfile;
import 'package:parser/terminal_parser.dart' show terminalParserProvider;
import 'package:protocol/protocol.dart' show Defaults;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:terminal/terminal.dart' show terminalIoProvider;

import 'color_probe.dart' as probe;
import 'result.dart' show QueryResult, Da1Result;

part 'color_probe_provider.g.dart';

/// TODO rename 
typedef ColorProbeFn = Future<ColorProfile> Function(
  QueryResult<Da1Result> da1Result, {
  Duration? timeout,
});

@riverpod
ColorProfile Function() colorFromEnv(Ref ref) {
  return probe.detectColorFromEnv;
}

@riverpod
ColorProfile Function(QueryResult<Da1Result>) colorFromDa1(Ref ref) {
  return probe.detectColorFromDa1;
}

@riverpod
ColorProbeFn colorProbe(Ref ref) {
  final io = ref.watch(terminalIoProvider);
  final parser = ref.watch(terminalParserProvider);
  return (da1Result, {timeout}) =>
      probe.probeColor(io, parser, da1Result, timeout: timeout ?? Defaults.defaultProbeTimeout);
}
