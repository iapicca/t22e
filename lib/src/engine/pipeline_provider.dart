import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'ansi_writer_provider.dart' show ansiWriterProvider;
import 'diff_engine_provider.dart' show diffEngineProvider;
import 'pipeline.dart' show Pipeline;
import 'stdout_interface_provider.dart' show stdoutInterfaceProvider;

part 'pipeline_provider.g.dart';

/// Provides a default [Pipeline] instance with injected engine dependencies.
@riverpod
Pipeline pipeline(Ref ref) => Pipeline(
      ansiWriter: ref.read(ansiWriterProvider),
      diffEngine: ref.read(diffEngineProvider),
      stdoutInterface: ref.read(stdoutInterfaceProvider),
    );
