import 'system_io.dart';
import 'native_io.dart';

typedef Write = void Function(String data);
typedef Flush = Future<void> Function();

/// Terminal I/O facade for input/output operations.
final class TerminalIo {
  final SystemIo _io;

  /// Creates with injected [io] (defaults to [NativeIo]).
  const TerminalIo({this._io = const NativeIo()});

  /// Stream of raw input bytes from the terminal.
  Stream<List<int>> get inputStream => _io.inputStream;

  /// Writes [data] to the terminal output.
  Write get write => _io.write;

  /// Flushes the output buffer.
  Flush get flush => _io.flush;

  /// Current terminal width in columns.
  int get columns => _io.columns;

  /// Current terminal height in rows.
  int get rows => _io.rows;
}
