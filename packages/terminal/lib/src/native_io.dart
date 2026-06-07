import 'dart:async';
import 'dart:io';

import 'package:meta/meta.dart';

import 'system_io.dart';

/// Concrete [SystemIo] backed by native dart:io stdin/stdout/Platform.
@internal
final class NativeIo with SystemIo {
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
  int get columns => stdout.terminalColumns;

  @override
  int get rows => stdout.terminalLines;

  @override
  bool get echoMode => stdin.echoMode;

  @override
  set echoMode(bool value) => stdin.echoMode = value;

  @override
  bool get lineMode => stdin.lineMode;

  @override
  set lineMode(bool value) => stdin.lineMode = value;

  @override
  String get operatingSystem => Platform.operatingSystem;

  @override
  Map<String, String> get environment => Platform.environment;
}
