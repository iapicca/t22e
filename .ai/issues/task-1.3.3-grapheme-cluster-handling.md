# Task 1.3.3: Grapheme Cluster Handling

**Story:** Unicode Width Tables
**Estimate:** M

## Description

Implement grapheme cluster segmentation following UAX #29 rules. Handle base characters + zero-width joiners + variation selectors. Ensure emoji ZWJ sequences (family, profession+skin tone, flags) are treated as single clusters with correct combined width.

## Implementation

```dart
class GraphemeCluster {
  final int start;       // codepoint index in string
  final int end;         // exclusive end
  final int columnWidth; // total terminal columns occupied
}

List<GraphemeCluster> graphemeClusters(String text) { ... }
int stringWidth(String text) { ... }  // total terminal columns
String truncate(String text, int maxWidth) { ... }
```

## Acceptance Criteria

- UAX #29 grapheme cluster break rules are implemented (GB1-GB12/GB999)
- ZWJ sequences (emoji + ZWJ + emoji) are treated as single cluster
- Variation selectors (VS16, VS15) are handled
- `stringWidth()` returns correct total column width for mixed CJK/emoji/Latin text
- `truncate()` preserves grapheme cluster boundaries
- Unit tests with known emoji sequences: family (👨‍👩‍👧‍👦), flags (🇺🇳), keycap sequences (#️⃣)
