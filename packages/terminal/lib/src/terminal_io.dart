import 'system_io.dart';

typedef Write = void Function(String data);
typedef Flush = Future<void> Function();

/// Interface for terminal I/O operations used by probe extensions.
abstract interface class TerminalIoInterface {
  Stream<List<int>> get inputStream;
  Write get write;
  Flush get flush;
}

/// Terminal I/O facade for input/output operations.
final class TerminalIo implements TerminalIoInterface {
  final SystemIo io;

  /// Creates with injected [io].
  const TerminalIo({required this.io});

  @override
  Stream<List<int>> get inputStream => io.inputStream;

  @override
  Write get write => io.write;

  @override
  Flush get flush => io.flush;

  /// Current terminal width in columns.
  int get columns => io.columns;

  /// Current terminal height in rows.
  int get rows => io.rows;
}
