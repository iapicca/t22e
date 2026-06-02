import 'system_io.dart';

typedef Write = void Function(String data);
typedef Flush = Future<void> Function();

/// Terminal I/O facade for input/output operations.
final class TerminalIo {
  final SystemIo io;

  /// Creates with injected [io].
  const TerminalIo({required this.io});

  /// Stream of raw input bytes from the terminal.
  Stream<List<int>> get inputStream => io.inputStream;

  /// Writes [data] to the terminal output.
  Write get write => io.write;

  /// Flushes the output buffer.
  Flush get flush => io.flush;

  /// Current terminal width in columns.
  int get columns => io.columns;

  /// Current terminal height in rows.
  int get rows => io.rows;
}
