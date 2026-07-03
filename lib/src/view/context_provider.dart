import 'package:meta/meta.dart' show internal;
import 'package:riverpod/riverpod.dart';

import 'context.dart' show Context;

/// Provides the shared app [Context] backed by the active provider container.
///
/// ViewModels holding only a [Ref] read this to reach the tree's [Context].
@internal
final contextProvider = Provider<Context>((ref) => Context(ref.container));