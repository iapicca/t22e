import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'csi_parser.dart' as parser;
import 'engine.dart' show Parser;

part 'csi_parser_provider.g.dart';

/// Provider for the CSI sequence parser function.
@riverpod
Parser csiParser(Ref ref) => parser.parseCsi;
