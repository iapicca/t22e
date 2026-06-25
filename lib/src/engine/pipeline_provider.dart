import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'pipeline.dart' show Pipeline;

part 'pipeline_provider.g.dart';

/// Provides a default [Pipeline] instance.
@riverpod
Pipeline pipeline(Ref ref) => Pipeline();
