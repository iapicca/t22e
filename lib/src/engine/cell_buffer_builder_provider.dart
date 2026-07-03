import 'package:meta/meta.dart' show internal;
import 'package:riverpod/riverpod.dart';

import '../models/size.dart' show Size;
import 'cell_buffer_builder.dart' show CellBufferBuilder;

/// Provides a [CellBufferBuilder] of the given dimensions.
@internal
/// TODO this is exporting bullshit and shouldn't be internal
final cellBufferBuilderProvider =
    Provider.family<CellBufferBuilder, (int, int)>(
  (ref, dims) => CellBufferBuilder(Size(dims.$1, dims.$2)),
);