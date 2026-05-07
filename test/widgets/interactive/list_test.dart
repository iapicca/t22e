import 'package:test/test.dart';
import 'package:t22e/src/widgets/interactive/list.dart';
import 'package:t22e/src/loop/msg.dart';
import 'package:t22e/src/parser/events.dart';

void main() {
  group('ListView', () {
    final items = [
      ListItem('One'),
      ListItem('Two'),
      ListItem('Three'),
    ];

    test('initial selected index is 0', () {
      final list = ListView(items: items);
      expect(list.selectedIndex, 0);
    });

    test('arrow down moves selection', () {
      final list = ListView(items: items);
      final (updated, _) = list.update(KeyMsg(const KeyEvent(keyCode: KeyCode.down)));
      expect(updated.selectedIndex, 1);
    });

    test('arrow up moves selection', () {
      final list = ListView(items: items, selectedIndex: 1);
      final (updated, _) = list.update(KeyMsg(const KeyEvent(keyCode: KeyCode.up)));
      expect(updated.selectedIndex, 0);
    });

    test('arrow up at start does nothing', () {
      final list = ListView(items: items, selectedIndex: 0);
      final (updated, _) = list.update(KeyMsg(const KeyEvent(keyCode: KeyCode.up)));
      expect(updated.selectedIndex, 0);
    });

    test('arrow down at end does nothing', () {
      final list = ListView(items: items, selectedIndex: 2);
      final (updated, _) = list.update(KeyMsg(const KeyEvent(keyCode: KeyCode.down)));
      expect(updated.selectedIndex, 2);
    });

    test('space toggles multi-select', () {
      final list = ListView(items: items, multiSelect: true);
      final (updated, _) = list.update(KeyMsg(const KeyEvent(keyCode: KeyCode.space)));
      expect(updated.multiSelected, contains(0));
    });

    test('enter does not crash', () {
      final list = ListView(items: items);
      expect(() => list.update(KeyMsg(const KeyEvent(keyCode: KeyCode.enter))), returnsNormally);
    });

    test('home goes to first item', () {
      final list = ListView(items: items, selectedIndex: 2);
      final (updated, _) = list.update(KeyMsg(const KeyEvent(keyCode: KeyCode.home)));
      expect(updated.selectedIndex, 0);
    });

    test('end goes to last item', () {
      final list = ListView(items: items, selectedIndex: 0);
      final (updated, _) = list.update(KeyMsg(const KeyEvent(keyCode: KeyCode.end)));
      expect(updated.selectedIndex, 2);
    });
  });
}
