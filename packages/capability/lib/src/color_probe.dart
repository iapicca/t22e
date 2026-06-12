import 'package:core/core.dart' show ColorProfile;
import 'package:meta/meta.dart';
import 'package:parser/terminal_parser.dart'
    show ColorQueryEvent, TerminalParser;
import 'package:protocol/protocol.dart' show Defaults;
import 'package:terminal/terminal.dart' show SystemIo;
import 'da1_query.dart' show Da1Query, Da1Value;
import 'system_io_probe_extension.dart' show SystemIoProbeExtension;

/// Detect color profile from COLORTERM and TERM environment variables.
@internal
ColorProfile detectColorFromEnv(Map<String, String> env) {
  final colorterm = env[Defaults.envKeyColorterm];
  if (colorterm == Defaults.envColortermTruecolor ||
      colorterm == Defaults.envColorterm24bit) {
    return ColorProfile.trueColor;
  }

  final term = env[Defaults.envKeyTerm] ?? '';
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
ColorProfile detectColorFromDa1(Da1Query da1Result) {
  if (da1Result is Da1Value) {
    final attrs = da1Result.attributes;
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
  SystemIo io,
  TerminalParser parser,
  Da1Query da1Result,
  Duration timeout,
) async {
  final env = detectColorFromEnv(io.environment);
  if (env == ColorProfile.trueColor) return env;

  return io.probeTerminal<ColorQueryEvent, ColorProfile>(
    query: '${Defaults.osc}${Defaults.oscFgQuery};?${Defaults.bel}',
    parser: parser,
    timeout: timeout,
    where: (event) => event.r != null,
    onEvent: (event) => ColorProfile.trueColor,
    onTimeout: () => detectColorFromDa1(da1Result),
  );
}
