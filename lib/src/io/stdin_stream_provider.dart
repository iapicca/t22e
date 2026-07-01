import 'package:meta/meta.dart' show internal;
import 'package:riverpod/riverpod.dart';

import 'stdin_reader_provider.dart' show stdinReaderProvider;

/// Provides the raw byte stream from [stdin] as a broadcast stream.
///
/// Multiple listeners can subscribe; override in tests with a fake [Stream].
/// TODO this should use riverpod annotation!
/// TODO warning `ref.watch` doesn't work outside flutter! need to use `ref.listen`
@internal
final stdinStreamProvider = Provider<Stream<List<int>>>((ref) {
  final reader = ref.watch(stdinReaderProvider);
  ref.onDispose(reader.dispose);
  return reader.bytes;
});
