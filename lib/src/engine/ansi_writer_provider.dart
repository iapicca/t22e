import 'package:meta/meta.dart' show internal;
import 'package:riverpod/riverpod.dart';

import 'ansi_writer.dart' show AnsiWriter;

/// Provides a default [AnsiWriter] instance.
@internal
final ansiWriterProvider = Provider<AnsiWriter>((ref) => const AnsiWriter());