import 'package:test/test.dart';
import 'package:t22e/src/widgets/visual/dialog.dart';
import 'package:t22e/src/widgets/basic/text.dart';
import 'package:t22e/src/widgets/widget.dart';
import 'package:t22e/src/loop/msg.dart';
import 'package:t22e/src/parser/events.dart';

void main() {
  group('Dialog', () {
    test('renders content widget', () {
      final dialog = Dialog(
        title: 'Test',
        content: Text('Hello'),
        buttons: [
          const DialogButton('OK'),
          const DialogButton('Cancel'),
        ],
      );
      final view = dialog.view();
      expect(view, isA<Widget>());
    });

    test('tab cycles focus through buttons', () {
      final dialog = Dialog(
        title: 'Test',
        content: Text('Hello'),
        buttons: [
          const DialogButton('OK'),
          const DialogButton('Cancel'),
        ],
        focusedButton: 0,
      );
      final (updated, _) = dialog.update(KeyMsg(
        const KeyEvent(keyCode: KeyCode.tab),
      ));
      expect(updated.focusedButton, 1);
    });

    test('shift+tab cycles focus backwards', () {
      final dialog = Dialog(
        title: 'Test',
        content: Text('Hello'),
        buttons: [
          const DialogButton('OK'),
          const DialogButton('Cancel'),
        ],
        focusedButton: 1,
      );
      final (updated, _) = dialog.update(KeyMsg(
        const KeyEvent(keyCode: KeyCode.tab, modifiers: KeyModifiers(shift: true)),
      ));
      expect(updated.focusedButton, 0);
    });

    test('escape does not crash when dismissible', () {
      final dialog = Dialog(
        dismissible: true,
        content: Text('Hello'),
      );
      expect(
        () => dialog.update(KeyMsg(const KeyEvent(keyCode: KeyCode.escape))),
        returnsNormally,
      );
    });
  });
}
