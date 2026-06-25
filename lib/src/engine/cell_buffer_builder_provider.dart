import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/size.dart' show Size;
import 'cell_buffer_builder.dart' show CellBufferBuilder;

part 'cell_buffer_builder_provider.g.dart';

/// Provides a [CellBufferBuilder] of the given dimensions.
@riverpod
CellBufferBuilder cellBufferBuilder(Ref ref, int width, int height) =>
    CellBufferBuilder(Size(width, height));
