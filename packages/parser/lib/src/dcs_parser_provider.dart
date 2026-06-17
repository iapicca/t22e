import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'dcs_parser.dart' as parser;
import 'sequence_data.dart' show Parser;

part 'dcs_parser_provider.g.dart';

/// Provider for the DCS sequence parser function.
@riverpod
Parser dcsParser(Ref ref) => parser.parseDcs;
