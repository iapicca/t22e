import 'package:meta/meta.dart' show internal;

import 'render_text.dart' show RenderText;

/// Layout helpers for [RenderText].
@internal
extension RenderTextLayout on RenderText {
  /// The number of lines in [text], treating an empty string as one line.
  int get lineCount => text.isEmpty ? 1 : text.split('\n').length;
}
