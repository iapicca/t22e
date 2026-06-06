import 'dart:io';

import 'package:core/core.dart' show ColorProfile;
import 'package:meta/meta.dart';
import 'package:parser/terminal_parser.dart'
    show ColorQueryEvent, TerminalParser;
import 'package:protocol/protocol.dart' show Defaults;
import 'package:terminal/terminal.dart' show TerminalIoInterface;
import 'result.dart' show QueryResult, Supported, Da1Result;
import 'terminal_probe_extension.dart' show TerminalProbeExtension;

/// Detect color profile from COLORTERM and TERM environment variables.
@internal
ColorProfile detectColorFromEnv() {
  final colorterm = Platform.environment['COLORTERM'];
  if (colorterm == Defaults.envColortermTruecolor ||
      colorterm == Defaults.envColorterm24bit) {
    return ColorProfile.trueColor;
  }
  final term = Platform.environment['TERM'] ?? '';
  if (term.endsWith(Defaults.envTermSuffix256Color)) {
    return ColorProfile.indexed256;
  }
  if (term.endsWith(Defaults.envTermSuffixTrueColor) ||
      term.endsWith(Defaults.envTermSuffixDirect)) {
    return ColorProfile.trueColor;
  }
  return ColorProfile.ansi16;
}

/// Detect color profile from DA1 response attributes.
@internal
ColorProfile detectColorFromDa1(QueryResult<Da1Result> da1Result) {
  if (da1Result is Supported<Da1Result>) {
    final attrs = da1Result.value.attributes;
    if (attrs.contains(Defaults.da1AttrTrueColor)) {
      return ColorProfile.trueColor;
    }
    if (attrs.contains(Defaults.da1AttrIndexed256)) {
      return ColorProfile.indexed256;
    }
  }
  return ColorProfile.ansi16;
}

/// Probe terminal color support via OSC query with env/DA1 fallback.
@internal
Future<ColorProfile> probeColor(
  TerminalIoInterface io,
  TerminalParser parser,
  QueryResult<Da1Result> da1Result, {
  Duration timeout = Defaults.defaultProbeTimeout,
}) async {
  final env = detectColorFromEnv();
  if (env == ColorProfile.trueColor) return env;

  return io.probe<ColorQueryEvent, ColorProfile>(
    query: '${Defaults.osc}${Defaults.oscFgQuery};?${Defaults.bel}',
    parser: parser,
    timeout: timeout,
    where: (event) => event.r != null,
    onEvent: (event) => ColorProfile.trueColor,
    onTimeout: () => detectColorFromDa1(da1Result),
  );
}
