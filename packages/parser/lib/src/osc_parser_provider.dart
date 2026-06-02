import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'osc_parser.dart' as parser;
import 'engine.dart' show Parser;

part 'osc_parser_provider.g.dart';

@riverpod
Parser oscParser(Ref ref) => parser.parseOsc;
