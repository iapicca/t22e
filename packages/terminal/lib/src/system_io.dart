import 'dart:async';

/// Wraps dart:io stdin/stdout/Platform to enable mocking.
abstract class SystemIo {
  const SystemIo();

  /// Raw input byte stream (like stdin).
  Stream<List<int>> get inputStream;

  /// Writes [data] to standard output.
  void write(String data);

  /// Flushes the standard output buffer.
  Future<void> flush();

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
