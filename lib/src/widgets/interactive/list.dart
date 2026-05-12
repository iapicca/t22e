import '../../loop/model.dart' show Model;
import '../../loop/msg.dart' show Msg, KeyMsg;
import '../../loop/cmd.dart' show Cmd;
import '../../well_known.dart' show WellKnown;
import '../widget.dart' show Widget;
import '../basic/text.dart' show Text;
import '../basic/box.dart' show Box;
import '../container/column.dart' show Column;
import '../enums.dart' show BorderStyle;
import '../../core/style.dart' show TextStyle;
import '../../core/geometry.dart' show Insets;
import '../../parser/events.dart' show KeyCode, KeyEvent;

/// An item in a list view, with a label and optional icon
class ListItem {
  final String label;
  final String? icon;

  const ListItem(this.label, {this.icon});
}

/// A keyboard-navigable list view with single/multi selection support
class ListView extends Model<ListView> {
  final List<ListItem> items;
  final int selectedIndex;
  final Set<int> multiSelected;
  final bool multiSelect;
  final int viewportHeight;

  const ListView({
    this.items = const [],
    this.selectedIndex = 0,
    this.multiSelected = const {},
    this.multiSelect = false,
    this.viewportHeight = WellKnown.defaultViewportHeight,
  });

  @override
  (ListView, Cmd?) update(Msg msg) {
    if (msg is KeyMsg) {
      return _handleKey(msg.event);
    }
    return (this, null);
  }

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
      final newIdx = (selectedIndex - viewportHeight).clamp(0, items.length - 1);
      return (copyWith(selectedIndex: newIdx), null);
    }
    if (keyCode == KeyCode.pageDown) {
      final newIdx = (selectedIndex + viewportHeight).clamp(0, items.length - 1);
      return (copyWith(selectedIndex: newIdx), null);
    }
    return (this, null);
  }

  /// Copy with optional field updates
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

  /// Starting index of the visible portion, centered on selectedIndex
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

  /// Builds a single row widget for a list item
  Widget _buildItemRow(ListItem item, bool isSelected, bool isMultiSelected) {
    final style = isSelected
        ? const TextStyle(reverse: true)
        : TextStyle.empty;
    final prefix = multiSelect
        ? (isMultiSelected ? '[${WellKnown.charCheckMark}] ' : '[ ] ')
        : (isSelected ? '${WellKnown.charRightTriangle} ' : '  ');
    return Text('$prefix${item.label}', style: style);
  }
}
