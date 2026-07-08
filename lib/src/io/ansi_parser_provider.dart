import 'package:meta/meta.dart' show internal;
import 'package:riverpod/riverpod.dart';

import 'ansi_parser.dart' show AnsiParser;

/// Provides a default [AnsiParser] instance.
@internal
final ansiParserProvider = Provider<AnsiParser>((ref) {
  final parser = AnsiParser();
  ref.onDispose(parser.dispose);
  return parser;
});