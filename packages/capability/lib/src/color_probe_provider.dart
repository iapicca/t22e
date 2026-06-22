import 'package:core/core.dart' show ColorProfile;
import 'package:parser/terminal_parser.dart' show terminalParserProvider;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:terminal/terminal.dart' show systemIoProvider;

import 'color_probe.dart';
import 'da1_probe_provider.dart' show da1ProbeProvider;
import 'probe_definitions.dart' show ColorProbe;
import 'probe_timeout_provider.dart' show probeTimeoutProvider;

part 'color_probe_provider.g.dart';

@riverpod
/// Full color probe: env fallback, then OSC query, then DA1 fallback.
ColorProbe colorProbe(Ref ref) async {
  final io = ref.read(systemIoProvider);
  final parser = ref.read(terminalParserProvider);
  final da1Result = await ref.read(da1ProbeProvider.future);
  final timeout = ref.read(probeTimeoutProvider);
  return probeColor(io, parser, da1Result, timeout);
}

@riverpod
/// Detect color profile from environment variables.
ColorProfile colorFromEnv(Ref ref) {
  final io = ref.read(systemIoProvider);
  return detectColorFromEnv(io.context.value.environment);
}
