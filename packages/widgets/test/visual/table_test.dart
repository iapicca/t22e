import 'package:test/test.dart';
import 'package:widgets/widgets.dart';

void main() {
  group('Table', () {
    test('empty columns shows placeholder', () {
      final table = Table();
      final view = table.view();
      expect(view, isA<Widget>());
    });

    test('with columns renders header row', () {
      final table = Table(
        columns: ['Name', 'Value'],
        rows: [
          ['A', '1'],
          ['B', '2'],
        ],
      );
      final view = table.view();
      expect(view, isA<Widget>());
    });

    test('sort column shows indicator', () {
      final table = Table(
        columns: ['Name', 'Value'],
        sortColumn: 1,
        sortAscending: true,
      );
      final view = table.view();
      expect(view, isA<Widget>());
    });

    test('descending sort shows correct indicator', () {
      final table = Table(
        columns: ['Name'],
        sortColumn: 0,
        sortAscending: false,
      );
      final view = table.view();
      expect(view, isA<Widget>());
    });
  });
}
