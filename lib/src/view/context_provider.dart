import 'package:meta/meta.dart' show internal;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'context.dart' show Context;

part 'context_provider.g.dart';

/// Provides the shared app [Context] backed by the active provider container.
///
/// ViewModels that only hold a [Ref] can read this to obtain the [Context]
/// that the widget tree compiles against, without touching the container
/// directly.
@riverpod
@internal
Context context(Ref ref) => Context(ref.container);