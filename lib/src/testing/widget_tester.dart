import '../core/cell.dart';
import '../core/surface.dart';
import '../core/style.dart';
import '../well_known.dart' show WellKnown;
import '../widgets/widget.dart';
import '../widgets/renderer.dart';
import '../renderer/frame.dart';
import '../renderer/cell_renderer.dart';
import '../loop/msg.dart';
import '../loop/model.dart';
import '../parser/events.dart' show KeyCode, KeyModifiers, KeyEvent, MouseButton, MouseAction, MouseEvent;
import 'virtual_terminal.dart';

class WidgetTester {
  final VirtualTerminal virtualTerminal;
  final CellRenderer _cellRenderer = const CellRenderer();
  Model? _model;
  Surface Function()? _viewFn;

  WidgetTester({int width = WellKnown.defaultTerminalWidth, int height = WellKnown.defaultTerminalHeight})
      : virtualTerminal = VirtualTerminal(width: width, height: height);

  void pumpWidget(Widget root, {int width = WellKnown.defaultTerminalWidth, int height = WellKnown.defaultTerminalHeight}) {
    final surface = WidgetRenderer.render(root, width, height);
    final frame = Frame.fromSurface(surface, includeCells: true);
    final empty = Frame([], [],
        cells: List.generate(height, (_) => List.filled(width, Cell())));
    final output = _cellRenderer.render(empty, frame);
    virtualTerminal.write(output);
  }

  void pumpWidgetWithModel(Model model, {required Surface Function() view, int width = WellKnown.defaultTerminalWidth, int height = WellKnown.defaultTerminalHeight}) {
    _model = model;
    _viewFn = view;
    final surface = view();
    final frame = Frame.fromSurface(surface);
    virtualTerminal.write(frame.styledLines.join('\n'));
  }

  void sendKeyEvent(KeyCode key, {KeyModifiers? modifiers, int? codepoint}) {
    if (_model == null || _viewFn == null) return;
    final event = KeyEvent(keyCode: key, modifiers: modifiers ?? const KeyModifiers(), codepoint: codepoint);
    final result = _model!.update(KeyMsg(event));
    _model = result.$1 as Model;
    final surface = _viewFn!();
    final frame = Frame.fromSurface(surface);
    virtualTerminal.write('${WellKnown.csi}${WellKnown.eraseDisplayAll}J');
    for (var r = 0; r < frame.styledLines.length; r++) {
      virtualTerminal.write('\x1b[${r + 1};1H${frame.styledLines[r]}');
    }
  }

  void sendMouseEvent(MouseButton button, MouseAction action, int x, int y) {
    if (_model == null || _viewFn == null) return;
    final event = MouseEvent(button: button, action: action, x: x, y: y);
    final result = _model!.update(MouseMsg(event));
    _model = result.$1 as Model;
    final surface = _viewFn!();
    final frame = Frame.fromSurface(surface);
    virtualTerminal.write('${WellKnown.csi}${WellKnown.eraseDisplayAll}J');
    for (var r = 0; r < frame.styledLines.length; r++) {
      virtualTerminal.write('\x1b[${r + 1};1H${frame.styledLines[r]}');
    }
  }

  void expectCell(int row, int col, {String? char, TextStyle? style}) {
    final cell = virtualTerminal.cellAt(row, col);
    if (char != null) {
      if (cell.char != char) {
        throw TestFailure('Expected char "$char" at ($row, $col), got "${cell.char}"');
      }
    }
    if (style != null) {
      if (cell.style != style) {
        throw TestFailure('Style mismatch at ($row, $col)');
      }
    }
  }

  void expectPlainText(String expected) {
    final actual = virtualTerminal.plainText();
    if (actual != expected) {
      throw TestFailure('Expected plain text:\n$expected\n\nGot:\n$actual');
    }
  }
}

class TestFailure implements Exception {
  final String message;
  const TestFailure(this.message);

  @override
  String toString() => message;
}
