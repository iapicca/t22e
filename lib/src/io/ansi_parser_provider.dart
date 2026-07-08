import 'package:meta/meta.dart' show internal;
import 'package:riverpod/riverpod.dart';

import 'ansi_parser.dart' show AnsiParser;
import 'utf8_decoder_provider.dart' show utf8DecoderProvider;

/// Provides a default [AnsiParser] instance.
@internal
final ansiParserProvider = Provider<AnsiParser>((ref) {
  final decodeUtf8 = ref.read(utf8DecoderProvider);
  final parser = AnsiParser(decodeUtf8: decodeUtf8);
  ref.onDispose(parser.dispose);
  return parser;
});