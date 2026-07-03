import 'package:meta/meta.dart' show internal;
import 'package:riverpod/riverpod.dart';

import 'ansi_writer_provider.dart' show ansiWriterProvider;
import 'diff_engine_provider.dart' show diffEngineProvider;
import 'pipeline.dart' show Pipeline;
import 'stdout_interface_provider.dart' show stdoutInterfaceProvider;

/// Provides a default [Pipeline] instance with injected engine dependencies.
@internal
final pipelineProvider = Provider<Pipeline>(
  (ref) => Pipeline(
    ansiWriter: ref.read(ansiWriterProvider),
    diffEngine: ref.read(diffEngineProvider),
    stdoutInterface: ref.read(stdoutInterfaceProvider),
  ),
);