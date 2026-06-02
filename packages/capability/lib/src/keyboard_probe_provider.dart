import 'package:parser/terminal_parser.dart' show terminalParserProvider;
import 'package:protocol/protocol.dart' show Defaults;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:terminal/terminal.dart' show terminalIoProvider;

import 'keyboard_probe.dart' as probe;
import 'result.dart' show KeyboardProtocol;

part 'keyboard_probe_provider.g.dart';

typedef KeyboardProbe = Future<KeyboardProtocol> Function({
  Duration? timeout,
});

@riverpod
KeyboardProbe keyboardProbe(Ref ref) {
  final io = ref.read(terminalIoProvider);
  final parser = ref.read(terminalParserProvider);
  return ({timeout}) => probe.probeKeyboard(io, parser, timeout: timeout ?? Defaults.defaultProbeTimeout);
}
