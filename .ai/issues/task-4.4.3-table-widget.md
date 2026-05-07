# Task 4.4.3: Table Widget

**Story:** Visual & Composite Widgets
**Estimate:** M

## Description

Implement a table widget with column headers, auto-column-width, sorting indicator, alternating row colors, horizontal scrolling for wide tables, and cell text alignment.

## Implementation

```dart
class Table extends Model<Table> {
  final List<String> columns;
  final List<List<Widget>> rows;
  int? sortColumn;
  bool sortAscending;

  (Table, Cmd?) update(Msg msg) {
    // MouseMsg: click column header → sort
  }

  View view() {
    // render header row with sort indicator
    // render data rows with alternating colors
    // auto-size columns to content width
  }
}
```

## Acceptance Criteria

- Column widths auto-size to content (min: header width, max: constraint)
- Header row: column names with sort indicator (▲/▼) on active column
- Click header to toggle sort (requires mouse support)
- Alternating row colors for readability
- Horizontal scroll when total width exceeds viewport
- Cell text alignment: left (default), center, right per column
- Column separator lines (optional)
- Footer row (optional, for summary)
- Empty state: "No data" message centered
