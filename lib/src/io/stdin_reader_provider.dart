import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'stdin_reader.dart' show StdinReader;

part 'stdin_reader_provider.g.dart';

/// Provides the default [StdinReader] backed by `dart:io` stdin.
@riverpod
StdinReader stdinReader(Ref ref) => StdinReader();
