import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'engine.dart' show Vt500Engine;

part 'engine_provider.g.dart';

/// Provider for the VT500-compatible byte-level state machine engine.
@riverpod
Vt500Engine vt500Engine(Ref ref) => Vt500Engine();
