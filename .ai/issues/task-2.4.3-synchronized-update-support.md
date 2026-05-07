# Task 2.4.3: Synchronized Update Support

**Story:** Diff Engine & Output
**Estimate:** S

## Description

Wrap render output in synchronized update sequences (`\x1b[?2026h` / `\x1b[?2026l`) when the terminal supports it. This eliminates tearing by making the terminal buffer all output and flush atomically.

## Implementation

```dart
class SyncRenderer {
  final bool syncSupported;

  String render(DiffResult diff, Frame currentFrame) {
    final content = _lineRenderer.render(diff, currentFrame);
    if (!syncSupported) return content;
    return '\x1b[?2026h$content\x1b[?2026l';
  }
}
```

## Acceptance Criteria

- Wraps output in sync markers when supported
- Falls through to plain output when not supported
- No flicker on terminals with sync support
- Feature flag controlled by capability probe result
- Unit tests: with sync, without sync, mixed
