import 'dart:async';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:protocol/protocol.dart' show Defaults;

import 'system_io.dart';

/// Concrete [SystemIo] backed by native dart:io stdin/stdout/Platform.
@internal
final class NativeIo implements SystemIo {
  const NativeIo();

  @override
  Stream<List<int>> get inputStream => stdin;

  @override
  void write(String data) => stdout.write(data);

  @override
  Future<void> flush() => stdout.flush();

  @override
  bool get hasTerminal => stdout.hasTerminal;

  @override
  int get columns => stdout.hasTerminal
      ? stdout.terminalColumns
      : Defaults.defaultTerminalWidth;

  @override
  int get rows => stdout.hasTerminal
      ? stdout.terminalLines
      : Defaults.defaultTerminalHeight;

  @override
  bool get echoMode => stdout.hasTerminal ? stdin.echoMode : true;

  @override
  set echoMode(bool value) {
    if (stdout.hasTerminal) stdin.echoMode = value;
  }

  @override
  bool get lineMode => stdout.hasTerminal ? stdin.lineMode : true;

  @override
  set lineMode(bool value) {
    if (stdout.hasTerminal) stdin.lineMode = value;
  }

  @override
  String get operatingSystem => Platform.operatingSystem;
}
