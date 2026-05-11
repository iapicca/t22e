import '../model.dart' show Model;
import '../msg.dart' show Msg;
import '../cmd.dart' show Cmd;
import 'package:protocol/protocol.dart' show Defaults;
import '../widget.dart' show Widget;
import '../basic/text.dart' show Text;
import '../basic/box.dart' show Box;
import '../container/row.dart' show Row;
import '../container/column.dart' show Column;
import '../enums.dart' show BorderStyle;
import 'package:core/core.dart' show TextStyle;

class Table extends Model<Table> {
  final List<String> columns;
  final List<List<String>> rows;
  final int? sortColumn;
  final bool sortAscending;
  final bool showRowNumbers;

  const Table({
    this.columns = const [],
    this.rows = const [],
    this.sortColumn,
    this.sortAscending = true,
    this.showRowNumbers = false,
  });

  @override
  (Table, Cmd?) update(Msg msg) {
    return (this, null);
  }

  Table copyWith({
    List<String>? columns,
    List<List<String>>? rows,
    int? sortColumn,
    bool? sortAscending,
    bool? showRowNumbers,
  }) {
    return Table(
      columns: columns ?? this.columns,
      rows: rows ?? this.rows,
      sortColumn: sortColumn ?? this.sortColumn,
      sortAscending: sortAscending ?? this.sortAscending,
      showRowNumbers: showRowNumbers ?? this.showRowNumbers,
    );
  }

  @override
  Widget view() {
    if (columns.isEmpty) {
      return Box(
        borderStyle: BorderStyle.single,
        child: Text('(no columns)', style: const TextStyle(dim: true)),
      );
    }

    final headerWidgets = <Widget>[];
    for (var c = 0; c < columns.length; c++) {
      var label = columns[c];
      if (c == sortColumn) {
        label += sortAscending
            ? ' ${Defaults.charUpTriangle}'
            : ' ${Defaults.charDownTriangle}';
      }
      headerWidgets.add(Text(label, style: const TextStyle(bold: true)));
    }
    final headerRow = Row(children: headerWidgets);

    final rowWidgets = <Widget>[headerRow];
    for (var r = 0; r < rows.length; r++) {
      final rowStyle = r % 2 == 1
          ? const TextStyle(dim: true)
          : TextStyle.empty;
      final cellWidgets = <Widget>[];
      for (var c = 0; c < rows[r].length && c < columns.length; c++) {
        final cellText = rows[r][c];
        cellWidgets.add(Text(cellText, style: rowStyle));
      }
      rowWidgets.add(Row(children: cellWidgets));
    }

    return Column(children: rowWidgets);
  }
}
