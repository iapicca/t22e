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

class ListItem {
  final String label;
  final String? icon;

  const ListItem(this.label, {this.icon});
}

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
    this.viewportHeight = Defaults.defaultViewportHeight,
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

  Widget _buildItemRow(ListItem item, bool isSelected, bool isMultiSelected) {
    final style = isSelected ? const TextStyle(reverse: true) : TextStyle.empty;
    final prefix = multiSelect
        ? (isMultiSelected ? '[${Defaults.charCheckMark}] ' : '[ ] ')
        : (isSelected ? '${Defaults.charRightTriangle} ' : '  ');
    return Text('$prefix${item.label}', style: style);
  }
}
