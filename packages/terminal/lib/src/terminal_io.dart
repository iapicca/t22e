import 'system_io.dart';
import 'native_io.dart';

/// Terminal I/O facade for input/output operations.
final class TerminalIo {
  final SystemIo _io;

  /// Creates with injected [io] (defaults to [NativeIo]).
  const TerminalIo({SystemIo io = const NativeIo()}) : _io = io;

  /// Stream of raw input bytes from the terminal.
  Stream<List<int>> get inputStream => _io.inputStream;

  /// Writes [data] to the terminal output.
  void write(String data) => _io.write(data);

  /// Flushes the output buffer.
  Future<void> flush() => _io.flush();

  /// Current terminal width in columns.
  int get columns => _io.columns;

  /// Current terminal height in rows.
  int get rows => _io.rows;
}
