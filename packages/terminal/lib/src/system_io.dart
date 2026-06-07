import 'dart:async';

/// Wraps dart:io stdin/stdout/Platform to enable mocking.
mixin SystemIo {
  /// Raw input byte stream (like stdin).
  Stream<List<int>> get inputStream;

  /// Writes [data] to standard output.
  void write(String data);

  /// Flushes the standard output buffer.
  Future<void> flush();

  /// Whether stdout is connected to a terminal (not piped or redirected).
  bool get hasTerminal;

  /// Terminal width in columns.
  int get columns;

  /// Terminal height in rows.
  int get rows;

  /// Whether stdin echoes typed characters.
  bool get echoMode;
  set echoMode(bool value);

  /// Whether stdin buffers input by line.
  bool get lineMode;
  set lineMode(bool value);

  /// Current platform name (eg 'macos', 'linux', 'windows').
  String get operatingSystem;
}
