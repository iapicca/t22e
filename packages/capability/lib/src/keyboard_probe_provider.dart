import 'package:parser/terminal_parser.dart' show terminalParserProvider;
import 'package:protocol/protocol.dart' show Defaults;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:terminal/terminal.dart' show systemIoProvider;

import 'keyboard_probe.dart' as probe;
import 'result.dart' show KeyboardProtocol;

part 'keyboard_probe_provider.g.dart';

/// Type alias for the keyboard probe function.
typedef KeyboardProbe = Future<KeyboardProtocol> Function({Duration? timeout});

@riverpod
/// Probe for Kitty keyboard protocol support.
KeyboardProbe keyboardProbe(Ref ref) {
  final io = ref.read(systemIoProvider);
  final parser = ref.read(terminalParserProvider);
  return ({timeout}) => probe.probeKeyboard(
    io,
    parser,
    timeout: timeout ?? Defaults.defaultProbeTimeout,
  );
}
