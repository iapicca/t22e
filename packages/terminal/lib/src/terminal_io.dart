import 'system_io.dart';

/// Interface for terminal I/O operations used by probe extensions.
mixin TerminalInterface {
  Stream<List<int>> get inputStream;
  void write(String data);
  Future<void> flush();
}

/// Terminal I/O facade for input/output operations.
final class TerminalIo with SystemIo, TerminalInterface {
  final SystemIo io;

  /// Creates with injected [io].
  const TerminalIo({required this.io});

  @override
  Stream<List<int>> get inputStream => io.inputStream;

  @override
  void write(String data) => io.write(data);

  @override
  Future<void> flush() => io.flush();

  @override
  bool get hasTerminal => io.hasTerminal;

  @override
  int get columns => io.columns;

  @override
  int get rows => io.rows;

  @override
  bool get echoMode => io.echoMode;

  @override
  set echoMode(bool value) => io.echoMode = value;

  @override
  bool get lineMode => io.lineMode;

  @override
  set lineMode(bool value) => io.lineMode = value;

  @override
  String get operatingSystem => io.operatingSystem;

  @override
  Map<String, String> get environment => io.environment;
}
