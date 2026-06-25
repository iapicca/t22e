import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'ansi_parser.dart' show AnsiParser;

part 'ansi_parser_provider.g.dart';

/// Provides a default [AnsiParser] instance.
@riverpod
AnsiParser ansiParser(Ref ref) {
  final parser = AnsiParser();
  ref.onDispose(parser.close);
  return parser;
}
