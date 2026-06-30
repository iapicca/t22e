import 'package:meta/meta.dart' show internal;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'render_root.dart' show RenderRoot;

part 'render_root_provider.g.dart';

/// Provides a default [RenderRoot] instance.
@riverpod
@internal
RenderRoot renderRoot(Ref ref) => RenderRoot();
