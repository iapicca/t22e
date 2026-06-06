import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'esc_parser.dart' as parser;
import 'engine.dart' show Parser;

part 'esc_parser_provider.g.dart';

/// Provider for the ESC sequence parser function.
@riverpod
Parser escParser(Ref ref) => parser.parseEsc;
