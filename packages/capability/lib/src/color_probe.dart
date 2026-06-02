import 'dart:async';
import 'dart:io';

import 'package:core/core.dart' show ColorProfile;
import 'package:parser/terminal_parser.dart'
    show ColorQueryEvent, TerminalParser;
import 'package:protocol/protocol.dart' show Defaults;
import 'package:terminal/terminal.dart' show TerminalIo;
import 'result.dart' show QueryResult, Supported, Da1Result;

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

@internal
Future<ColorProfile> probeColor(
  TerminalIo io,
  TerminalParser parser,
  QueryResult<Da1Result> da1Result, {
  Duration timeout = Defaults.defaultProbeTimeout,
}) async {
  final env = detectColorFromEnv();
  if (env == ColorProfile.trueColor) return env;

  final completer = Completer<ColorProfile>();
  final timer = Timer(timeout, () {
    if (!completer.isCompleted) {
      completer.complete(detectColorFromDa1(da1Result));
    }
  });

  late final StreamSubscription<List<int>> sub;
  sub = io.inputStream.listen((bytes) {
    final events = parser.advance(bytes);
    for (final event in events) {
      if (event is ColorQueryEvent && event.r != null) {
        timer.cancel();
        sub.cancel();
        completer.complete(ColorProfile.trueColor);
      }
    }
  });

  io.write('${Defaults.osc}${Defaults.oscFgQuery};?${Defaults.bel}');
  await io.flush();

  final result = await completer.future;
  await sub.cancel();
  return result;
}
