import 'package:meta/meta.dart' show internal;
import 'package:riverpod/riverpod.dart';

import 'diff_engine.dart' show DiffEngine;

/// Provides a default [DiffEngine] instance.
@internal
/// TODO why is this internal?
final diffEngineProvider = Provider<DiffEngine>((ref) => const DiffEngine());