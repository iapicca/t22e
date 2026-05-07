# Task 4.3.3: List Widget (Selectable)

**Story:** Interactive Widgets
**Estimate:** M

## Description

Implement a selectable list widget. Renders a list of items with keyboard navigation and selection highlight. Supports single and multi-select modes.

## Implementation

```dart
class List extends Model<List> {
  final List<ListItem> items;
  int selectedIndex;
  Set<int> multiSelected;
  bool multiSelect;

  (List, Cmd?) update(Msg msg) {
    // Up/Down: navigate
    // Enter/Space: select
    // PageUp/PageDown: fast navigation
    // Home/End: first/last
  }

  View view() {
    // render items with highlight on selected
    // in multi-select: show checkmark or highlight for each selected
  }
}
```

## Acceptance Criteria

- Navigation: Up/Down moves selection by 1 (wraps or stops at ends)
- Selection highlight uses reverse or a distinct background color
- PageUp/PageDown: moves by viewport page size
- Single-select: selecting a different item deselects previous
- Multi-select: Space toggles current item, Shift+arrows extends range
- Filtering: optional, prefix-match on typed characters
- Items can have leading icons (checkbox, radio, bullet)
- Scrolls to keep selected item visible
- Unit tests: navigation, selection, multi-select, filtering, scrolling behavior
