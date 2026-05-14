import 'dart:async';
import 'dart:io';

import 'package:core/core.dart' show ColorProfile;
import 'package:protocol/protocol.dart' show Defaults;
import 'package:parser/terminal_parser.dart'
    show ColorQueryEvent, TerminalParser;
import 'package:terminal/terminal.dart' show TerminalIo, RealTerminalIo;
import 'result.dart' show QueryResult, Supported, Da1Result;

class ColorProbe {
  final TerminalIo _io;

  ColorProbe({TerminalIo? io}) : _io = io ?? const RealTerminalIo();

  ColorProfile detectFromEnv() {
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

  ColorProfile detectFromDa1(QueryResult<Da1Result> da1Result) {
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

  Future<ColorProfile> probe(
    QueryResult<Da1Result> da1Result, {
    Duration timeout = Defaults.defaultProbeTimeout,
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
    sub = _io.inputStream.listen((bytes) {
      final events = parser.advance(bytes);
      for (final event in events) {
        if (event is ColorQueryEvent && event.r != null) {
          timer.cancel();
          sub.cancel();
          completer.complete(ColorProfile.trueColor);
        }
      }
    });

    _io.write('${Defaults.osc}${Defaults.oscFgQuery};?${Defaults.bel}');
    await _io.flush();

    final result = await completer.future;
    await sub.cancel();
    return result;
  }
}
