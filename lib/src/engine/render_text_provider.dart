import 'package:meta/meta.dart' show internal;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'render_text.dart' show RenderText;

part 'render_text_provider.g.dart';

/// Provides a default [RenderText] instance.
@riverpod
@internal
/// TODO why is this internal?
RenderText renderText(Ref ref) => RenderText(text: '');
