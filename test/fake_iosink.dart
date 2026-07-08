import 'dart:async' show Future;
import 'dart:convert' show Encoding, utf8;
import 'dart:io' show IOSink;

/// An in-memory [IOSink] for testing stdout-like sinks.
class FakeIOSink implements IOSink {
  /// Creates an empty fake sink.
  FakeIOSink();

  final StringBuffer _buffer = StringBuffer();
  final List<String> _flushes = <String>[];

  /// All characters written to the sink.
  String get output => _buffer.toString();

  /// The buffer state captured on each flush.
  List<String> get flushes => List<String>.unmodifiable(_flushes);

  /// Clears the written output and flush history.
  void clear() {
    _buffer.clear();
    _flushes.clear();
  }

  @override
  Encoding encoding = utf8;

  @override
  Future<void> get done => Future<void>.value();

  @override
  void add(List<int> data) => _buffer.write(encoding.decode(data));

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future<void> addStream(Stream<List<int>> stream) async {
    await for (final chunk in stream) {
      add(chunk);
    }
  }

  @override
  Future<void> close() => Future<void>.value();

  @override
  Future<void> flush() async => _flushes.add(_buffer.toString());

  @override
  void write(Object? object) => _buffer.write(object);

  @override
  void writeAll(Iterable<Object?> objects, [String separator = '']) =>
      _buffer.writeAll(objects, separator);

  @override
  void writeCharCode(int charCode) => _buffer.writeCharCode(charCode);

  @override
  void writeln([Object? object = '']) => _buffer.writeln(object);
}
