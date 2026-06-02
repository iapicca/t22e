import 'package:parser/terminal_parser.dart' show terminalParserProvider;
import 'package:protocol/protocol.dart' show Defaults;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:terminal/terminal.dart' show terminalIoProvider;

import 'keyboard_probe.dart' as probe;
import 'result.dart' show KeyboardProtocol;

part 'keyboard_probe_provider.g.dart';

typedef KeyboardProbeFn = Future<KeyboardProtocol> Function({
  Duration? timeout,
});

@riverpod
KeyboardProbeFn keyboardProbe(Ref ref) {
  final io = ref.watch(terminalIoProvider);
  final parser = ref.watch(terminalParserProvider);
  return ({timeout}) => probe.probeKeyboard(io, parser, timeout: timeout ?? Defaults.defaultProbeTimeout);
}
