import 'dart:async';

/// Wraps dart:io stdin/stdout/Platform to enable mocking.
/// TODO evaluate creating a `SystemContext` freezed class that will contain
/// - columns and rows (maybe named width and height)
/// - "mode" enum (echo, line) if the can't be used concurrently!
/// - hasTerminal
/// - operatingSystem (enum)
/// - environment (not as map but mapping Platform.environment to a freezed class in a separate file)
/// SystemContext expose a ValueNotifier<SystemContext>
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

  /// Environment variables (like Platform.environment).
  Map<String, String> get environment;
}
