import 'package:meta/meta.dart' show internal;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'context.dart' show Context;

part 'context_provider.g.dart';

/// Provides the shared app [Context] backed by the active provider container.
///
/// ViewModels holding only a [Ref] read this to reach the tree's [Context].
@riverpod
@internal
Context context(Ref ref) => Context(ref.container);