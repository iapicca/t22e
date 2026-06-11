import 'package:parser/terminal_parser.dart' show terminalParserProvider;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:terminal/terminal.dart' show systemIoProvider;
import 'capabilities.dart' show KeyboardProtocol;
import 'keyboard_probe.dart' ;

import 'probe_definitions.dart' show KeyboardProbe;
import 'probe_timeout_provider.dart' show probeTimeoutProvider;

part 'keyboard_probe_provider.g.dart';


@riverpod
/// Probe for Kitty keyboard protocol support.
KeyboardProbe keyboardProbe(Ref ref) {
  final io = ref.read(systemIoProvider);
  final parser = ref.read(terminalParserProvider);
  final timeout = ref.read(probeTimeoutProvider);
  return probeKeyboard(
    io,
    parser,
    timeout,
  );
}
