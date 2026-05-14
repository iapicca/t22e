import '../model.dart' show Model;
import '../msg.dart' show Msg, KeyMsg;
import '../cmd.dart' show Cmd;
import 'package:protocol/protocol.dart' show Defaults;
import '../widget.dart' show Widget;
import '../basic/text.dart' show Text;
import '../basic/box.dart' show Box;
import '../container/column.dart' show Column;
import '../enums.dart' show BorderStyle;
import 'package:core/core.dart' show TextStyle;
import 'package:core/core.dart' show Insets;
import 'package:parser/terminal_parser.dart' show KeyCode, KeyEvent;

/// A single list item with a label and optional icon.
class ListItem {
  /// Display text for the item.
  final String label;
  /// Optional icon string.
  final String? icon;

  const ListItem(this.label, {this.icon});
}

/// A scrollable, keyboard-navigable list widget with optional multi-select.
class ListView extends Model<ListView> {
  /// The list items to display.
  final List<ListItem> items;
  /// Index of the currently selected item.
  final int selectedIndex;
  /// Indices of multi-selected items (for checkboxes).
  final Set<int> multiSelected;
  /// Enable multi-select mode.
  final bool multiSelect;
  /// Number of visible rows in the viewport.
  final int viewportHeight;

  const ListView({
    this.items = const [],
    this.selectedIndex = 0,
    this.multiSelected = const {},
    this.multiSelect = false,
    this.viewportHeight = Defaults.defaultViewportHeight,
  });

  @override
  (ListView, Cmd?) update(Msg msg) {
    if (msg is KeyMsg) {
      return _handleKey(msg.event);
    }
    return (this, null);
  }

  /// Handles keyboard navigation and selection.
  (ListView, Cmd?) _handleKey(KeyEvent event) {
    final keyCode = event.keyCode;
    if (keyCode == KeyCode.up && selectedIndex > 0) {
      return (copyWith(selectedIndex: selectedIndex - 1), null);
    }
    if (keyCode == KeyCode.down && selectedIndex < items.length - 1) {
      return (copyWith(selectedIndex: selectedIndex + 1), null);
    }
    if (keyCode == KeyCode.enter && items.isNotEmpty) {
      return (this, null);
    }
    if (keyCode == KeyCode.space && multiSelect) {
      final updated = Set<int>.from(multiSelected);
      if (updated.contains(selectedIndex)) {
        updated.remove(selectedIndex);
      } else {
        updated.add(selectedIndex);
      }
      return (copyWith(multiSelected: updated), null);
    }
    if (keyCode == KeyCode.home) {
      return (copyWith(selectedIndex: 0), null);
    }
    if (keyCode == KeyCode.end) {
      return (copyWith(selectedIndex: items.length - 1), null);
    }
    if (keyCode == KeyCode.pageUp) {
      final newIdx = (selectedIndex - viewportHeight).clamp(
        0,
        items.length - 1,
      );
      return (copyWith(selectedIndex: newIdx), null);
    }
    if (keyCode == KeyCode.pageDown) {
      final newIdx = (selectedIndex + viewportHeight).clamp(
        0,
        items.length - 1,
      );
      return (copyWith(selectedIndex: newIdx), null);
    }
    return (this, null);
  }

  /// Returns a copy with overridden fields.
  ListView copyWith({
    List<ListItem>? items,
    int? selectedIndex,
    Set<int>? multiSelected,
    bool? multiSelect,
    int? viewportHeight,
  }) {
    return ListView(
      items: items ?? this.items,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      multiSelected: multiSelected ?? this.multiSelected,
      multiSelect: multiSelect ?? this.multiSelect,
      viewportHeight: viewportHeight ?? this.viewportHeight,
    );
  }

  @override
  Widget view() {
    if (items.isEmpty) {
      return Box(
        borderStyle: BorderStyle.single,
        child: Text('(no items)', style: const TextStyle(dim: true)),
      );
    }

    final startIdx = _visibleStart;
    final endIdx = (_visibleStart + viewportHeight).clamp(0, items.length);

    final itemWidgets = <Widget>[];
    for (var i = startIdx; i < endIdx; i++) {
      final isSelected = i == selectedIndex;
      final isMulti = multiSelected.contains(i);
      itemWidgets.add(_buildItemRow(items[i], isSelected, isMulti));
    }

    return Box(
      borderStyle: BorderStyle.single,
      padding: const Insets.all(1),
      child: Column(children: itemWidgets),
    );
  }

  /// Computes the starting visible index centering around the selection.
  int get _visibleStart {
    if (selectedIndex < 0) return 0;
    final half = viewportHeight ~/ 2;
    final start = selectedIndex - half;
    if (start < 0) return 0;
    if (start + viewportHeight > items.length) {
      return (items.length - viewportHeight).clamp(0, items.length);
    }
    return start;
  }

  /// Builds a single item row with selection/multi-select indicators.
  Widget _buildItemRow(ListItem item, bool isSelected, bool isMultiSelected) {
    final style = isSelected ? const TextStyle(reverse: true) : TextStyle.empty;
    final prefix = multiSelect
        ? (isMultiSelected ? '[${Defaults.charCheckMark}] ' : '[ ] ')
        : (isSelected ? '${Defaults.charRightTriangle} ' : '  ');
    return Text('$prefix${item.label}', style: style);
  }
}
