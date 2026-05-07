# Task 5.2.4: Hyperlinks

**Story:** Advanced Input
**Estimate:** S

## Description

Implement hyperlink rendering via OSC 8 sequences. Text wrapped in hyperlink sequences appears clickable in terminals that support it (kitty, iTerm2, Windows Terminal, etc.).

## Implementation

```dart
// Format: \x1b]8;params;uri\x07text\x1b]8;;\x07
// id param: \x1b]8;id=hash;uri\x07 (groups hyperlinks under same ID)

String hyperlink(String uri, String text, {String? id}) {
  final params = id != null ? 'id=$id' : '';
  return '\x1b]8;$params;${uri}\x07$text\x1b]8;;\x07';
}

class HyperlinkSpan extends Widget {
  final String uri;
  final String text;
  final TextStyle style;
  // ...
}
```

## Acceptance Criteria

- Hyperlink widget renders text with OSC 8 wrapping
- URI is encoded properly (no breaking chars in params)
- Optional id parameter groups related hyperlinks
- Style change on hover (if supported by terminal, via OSC 8 params)
- Graceful degradation: on unsupported terminals, renders as plain text
- Integration with TextStyle for underlined + colored link appearance
- TextStyle.link(uri) convenience constructor
