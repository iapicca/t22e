import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'ansi_writer.dart' show AnsiWriter;

part 'ansi_writer_provider.g.dart';

/// Provides a default [AnsiWriter] instance.
@riverpod
AnsiWriter ansiWriter(Ref ref) => const AnsiWriter();
