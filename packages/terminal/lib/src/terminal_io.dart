import 'dart:async';

abstract class TerminalIo {
  const TerminalIo();

  Stream<List<int>> get inputStream;
  void write(String data);
  Future<void> flush();
  int get columns;
  int get rows;
}
