import 'package:meta/meta.dart' show internal;
import 'package:riverpod/riverpod.dart';

import 'render_root.dart' show RenderRoot;

/// Provides a default [RenderRoot] instance.
@internal
final renderRootProvider = Provider<RenderRoot>((ref) => RenderRoot());