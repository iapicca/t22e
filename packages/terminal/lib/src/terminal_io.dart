import 'dart:async';

/// Abstract interface for terminal input/output operations.
abstract class TerminalIo {
  const TerminalIo();

  /// Stream of raw input bytes from the terminal.
  Stream<List<int>> get inputStream;

  /// Writes [data] to the terminal output.
  void write(String data);

  /// Flushes the output buffer.
  Future<void> flush();

  /// Current terminal width in columns.
  int get columns;

  /// Current terminal height in rows.
  int get rows;
}
