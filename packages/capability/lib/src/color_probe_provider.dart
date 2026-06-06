import 'package:core/core.dart' show ColorProfile;
import 'package:parser/terminal_parser.dart' show terminalParserProvider;
import 'package:protocol/protocol.dart' show Defaults;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:terminal/terminal.dart' show terminalIoProvider;

import 'color_probe.dart' as probe;
import 'result.dart' show QueryResult, Da1Result;

part 'color_probe_provider.g.dart';

/// Type alias for the color probe function.
typedef ColorProbe =
    Future<ColorProfile> Function(
      QueryResult<Da1Result> da1Result, {
      Duration? timeout,
    });

@riverpod
/// Detect color profile from environment variables.
ColorProfile Function() colorFromEnv(Ref ref) {
  return probe.detectColorFromEnv;
}

@riverpod
/// Detect color profile from DA1 response attributes.
ColorProfile Function(QueryResult<Da1Result>) colorFromDa1(Ref ref) {
  return probe.detectColorFromDa1;
}

@riverpod
/// Full color probe: env fallback, then OSC query, then DA1 fallback.
ColorProbe colorProbe(Ref ref) {
  final io = ref.read(terminalIoProvider);
  final parser = ref.read(terminalParserProvider);
  return (da1Result, {timeout}) => probe.probeColor(
    io,
    parser,
    da1Result,
    timeout: timeout ?? Defaults.defaultProbeTimeout,
  );
}
