# Task 2.2.3: Style Inheritance

**Story:** TextStyle & Color Resolution
**Estimate:** S

## Description

Implement style inheritance where child styles fill null fields from parent styles. This is crucial for theming — a theme defines base styles and components override only what they need.

## Implementation

```dart
extension StyleInherit on TextStyle {
  TextStyle inherit(TextStyle parent) {
    return TextStyle(
      foreground: foreground ?? parent.foreground,
      background: background ?? parent.background,
      bold: bold ?? parent.bold,
      // ... etc for all fields
    );
  }
}
```

## Acceptance Criteria

- Null fields in child are filled from parent
- Non-null fields in child are preserved (child overrides parent)
- Works with deep nesting (child.inherit(parent).inherit(grandparent))
- Layout properties (padding, margin, width, height) follow same inheritance
- `TextStyle.empty.inherit(parent)` produces parent
- `child.inherit(TextStyle.empty)` produces child (no change)
