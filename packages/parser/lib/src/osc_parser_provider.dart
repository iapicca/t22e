import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'osc_parser.dart' as parser;
import 'sequence_data.dart' show Parser;

part 'osc_parser_provider.g.dart';

/// Provider for the OSC sequence parser function.
@riverpod
Parser oscParser(Ref ref) => parser.parseOsc;
