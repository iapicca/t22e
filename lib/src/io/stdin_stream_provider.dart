import 'package:meta/meta.dart' show internal;
import 'package:riverpod/riverpod.dart';

import 'stdin_reader_provider.dart' show stdinReaderProvider;

/// Provides the raw byte stream from [stdin] as a broadcast stream.
///
/// Multiple listeners can subscribe. Override this provider in tests with a
/// controlled [Stream].
@internal
final stdinStreamProvider = Provider<Stream<List<int>>>((ref) {
  final reader = ref.watch(stdinReaderProvider);
  ref.onDispose(reader.dispose);
  return reader.bytes;
});
