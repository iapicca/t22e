import 'package:meta/meta.dart' show internal;
import 'package:riverpod/riverpod.dart';

import 'render_text.dart' show RenderText;

/// Provides a default [RenderText] instance.
@internal
/// TODO why is this internal?
final renderTextProvider =
    Provider<RenderText>((ref) => RenderText(text: ''));