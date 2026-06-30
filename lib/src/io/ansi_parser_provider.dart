import 'package:meta/meta.dart' show internal;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'ansi_parser.dart' show AnsiParser;

part 'ansi_parser_provider.g.dart';

/// Provides a default [AnsiParser] instance.
@riverpod
@internal
/// TODO why is this internal?
AnsiParser ansiParser(Ref ref) {
  final parser = AnsiParser();
  ref.onDispose(parser.close);
  return parser;
}
