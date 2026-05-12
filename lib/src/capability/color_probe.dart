import 'dart:async';
import 'dart:io';

import '../core/color.dart' show ColorProfile;
import '../well_known.dart' show WellKnown;
import '../parser/events.dart' show ColorQueryEvent;
import '../parser/parser.dart' show TerminalParser;
import 'result.dart' show QueryResult, Supported, Da1Result;

/// Detects terminal color profile via env vars, DA1 attributes, and OSC query
class ColorProbe {
  /// Detects color support from COLORTERM and TERM environment variables
  ColorProfile detectFromEnv() {
    final colorterm = Platform.environment['COLORTERM'];
    if (colorterm == WellKnown.envColortermTruecolor || colorterm == WellKnown.envColorterm24bit) {
      return ColorProfile.trueColor;
    }
    final term = Platform.environment['TERM'] ?? '';
    if (term.endsWith(WellKnown.envTermSuffix256Color)) return ColorProfile.indexed256;
    if (term.endsWith(WellKnown.envTermSuffixTrueColor) || term.endsWith(WellKnown.envTermSuffixDirect)) {
      return ColorProfile.trueColor;
    }
    return ColorProfile.ansi16;
  }

  /// Detects color support from DA1 attributes (256-color or true-color flags)
  ColorProfile detectFromDa1(QueryResult<Da1Result> da1Result) {
    if (da1Result is Supported<Da1Result>) {
      final attrs = da1Result.value.attributes;
      if (attrs.contains(WellKnown.da1AttrTrueColor)) return ColorProfile.trueColor;
      if (attrs.contains(WellKnown.da1AttrIndexed256)) return ColorProfile.indexed256;
    }
    return ColorProfile.ansi16;
  }

  /// Queries terminal for true color support via OSC foreground color query
  Future<ColorProfile> probe(
    QueryResult<Da1Result> da1Result, {
    Duration timeout = WellKnown.defaultProbeTimeout,
  }) async {
    final env = detectFromEnv();
    if (env == ColorProfile.trueColor) return env;

    final parser = TerminalParser();
    final completer = Completer<ColorProfile>();
    final timer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.complete(detectFromDa1(da1Result));
      }
    });

    late final StreamSubscription<List<int>> sub;
    sub = stdin.listen((bytes) {
      final events = parser.advance(bytes);
      for (final event in events) {
        if (event is ColorQueryEvent && event.r != null) {
          timer.cancel();
          sub.cancel();
          completer.complete(ColorProfile.trueColor);
        }
      }
    });

    stdout.write('${WellKnown.osc}${WellKnown.oscFgQuery};?${WellKnown.bel}');
    await stdout.flush();

    final result = await completer.future;
    await sub.cancel();
    return result;
  }
}
