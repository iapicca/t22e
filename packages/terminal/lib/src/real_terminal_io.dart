import 'dart:async';
import 'dart:io';

import 'terminal_io.dart';

final class RealTerminalIo implements TerminalIo {
  const RealTerminalIo();

  @override
  Stream<List<int>> get inputStream => stdin;

  @override
  void write(String data) => stdout.write(data);

  @override
  Future<void> flush() => stdout.flush();

  @override
  int get columns => stdout.terminalColumns;

  @override
  int get rows => stdout.terminalLines;
}
