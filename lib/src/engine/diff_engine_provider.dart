import 'package:meta/meta.dart' show internal;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'diff_engine.dart' show DiffEngine;

part 'diff_engine_provider.g.dart';

/// Provides a default [DiffEngine] instance.
@riverpod
@internal
DiffEngine diffEngine(Ref ref) => const DiffEngine();
