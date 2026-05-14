import '../model.dart' show Model;
import '../msg.dart' show Msg, KeyMsg;
import '../cmd.dart' show Cmd;
import 'package:protocol/protocol.dart' show Defaults;
import '../widget.dart' show Widget, PaintingContext;
import '../basic/text.dart' show Text;
import '../basic/box.dart' show Box;
import '../container/row.dart' show Row;
import '../container/column.dart' show Column;
import '../enums.dart' show BorderStyle;
import 'package:core/core.dart' show TextStyle;
import 'package:core/core.dart' show Constraints, Size;
import 'package:core/core.dart' show Insets;
import 'package:parser/terminal_parser.dart' show KeyCode, KeyEvent;

/// A button in a dialog.
class DialogButton {
  /// Button label text.
  final String label;
  /// Whether this button has focus.
  final bool focused;

  const DialogButton(this.label, {this.focused = false});
}

/// A modal dialog overlay with title, content, and buttons.
class Dialog extends Model<Dialog> {
  /// Dialog title text.
  final String title;
  /// Content widget inside the dialog.
  final Widget content;
  /// Action buttons at the bottom.
  final List<DialogButton> buttons;
  /// Whether pressing Escape closes the dialog.
  final bool dismissible;
  /// Index of the currently focused button.
  final int focusedButton;

  const Dialog({
    this.title = '',
    required this.content,
    this.buttons = const [],
    this.dismissible = true,
    this.focusedButton = 0,
  });

  @override
  (Dialog, Cmd?) update(Msg msg) {
    if (msg is KeyMsg) {
      return _handleKey(msg.event);
    }
    return (this, null);
  }

  /// Handles Escape (dismiss) and Tab/Shift-Tab (button focus cycling).
  (Dialog, Cmd?) _handleKey(KeyEvent event) {
    final keyCode = event.keyCode;
    switch (keyCode) {
      case KeyCode.escape:
        if (dismissible) {
          return (this, null);
        }
        return (this, null);
      case KeyCode.tab:
        final shift = event.modifiers.shift;
        if (buttons.isEmpty) return (this, null);
        final next = shift
            ? (focusedButton - 1 + buttons.length) % buttons.length
            : (focusedButton + 1) % buttons.length;
        return (copyWith(focusedButton: next), null);
      case KeyCode.enter:
        if (buttons.isNotEmpty) {
          return (this, null);
        }
        return (this, null);
      default:
        return (this, null);
    }
  }

  /// Returns a copy with overridden fields.
  Dialog copyWith({
    String? title,
    Widget? content,
    List<DialogButton>? buttons,
    bool? dismissible,
    int? focusedButton,
  }) {
    return Dialog(
      title: title ?? this.title,
      content: content ?? this.content,
      buttons: buttons ?? this.buttons,
      dismissible: dismissible ?? this.dismissible,
      focusedButton: focusedButton ?? this.focusedButton,
    );
  }

  @override
  Widget view() {
    return _DialogOverlay(
      title: title,
      content: content,
      buttons: buttons,
      focusedButton: focusedButton,
    );
  }
}

/// Internal widget that dims the background and paints the dialog.
class _DialogOverlay extends Widget {
  final String title;
  final Widget content;
  final List<DialogButton> buttons;
  final int focusedButton;

  _DialogOverlay({
    this.title = '',
    required this.content,
    this.buttons = const [],
    this.focusedButton = 0,
  });

  @override
  Size layout(Constraints constraints) {
    return Size(constraints.maxWidth, constraints.maxHeight);
  }

  @override
  void paint(PaintingContext context) {
    final w = context.surface.width;
    final h = context.surface.height;

    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final cell = context.surface.grid[y][x];
        if (cell.char != ' ') {
          context.surface.putChar(
            x,
            y,
            cell.char,
            cell.style.merge(const TextStyle(dim: true)),
          );
        }
      }
    }

    final dialogW = (w * Defaults.dialogWidthRatio).round().clamp(
      Defaults.dialogMinWidth,
      w - Defaults.dialogHMargin,
    );
    final dialogH = (h * Defaults.dialogHeightRatio).round().clamp(
      Defaults.dialogMinHeight,
      h - Defaults.dialogHMargin,
    );
    final dialogX = (w - dialogW) ~/ 2;
    final dialogY = h ~/ 3;

    final contentHeight =
        dialogH -
        Defaults.dialogHMargin -
        (buttons.isNotEmpty ? Defaults.dialogButtonBarHeight : 0);

    final buttonBar = _buildButtonBar();

    final dialogBox = Box(
      borderStyle: BorderStyle.double,
      title: title.isNotEmpty ? title : null,
      padding: const Insets.all(1),
      child: Column(
        children: [
          SizedBox(
            height: contentHeight.clamp(1, Defaults.dialogContentClampHigh),
            child: content,
          ),
          if (buttons.isNotEmpty)
            SizedBox(height: Defaults.dialogButtonBarHeight, child: buttonBar),
        ],
      ),
    );

    final dialogConstraints = Constraints.tight(dialogW, dialogH);
    dialogBox.layout(dialogConstraints);
    dialogBox.paint(context.child(dialogX, dialogY));
  }

  /// Builds the button bar with focus highlights.
  Widget _buildButtonBar() {
    final children = <Widget>[];
    for (var i = 0; i < buttons.length; i++) {
      final isFocused = i == focusedButton;
      final label = isFocused
          ? '[${buttons[i].label}]'
          : ' ${buttons[i].label} ';
      children.add(
        Text(
          label,
          style: isFocused ? const TextStyle(reverse: true) : TextStyle.empty,
        ),
      );
      if (i < buttons.length - 1) {
        children.add(Text('  '));
      }
    }
    return Row(children: children);
  }
}

/// Constrains a child to a specific size.
class SizedBox extends Widget {
  /// Forced width, or null to let child choose.
  final int? width;
  /// Forced height, or null to let child choose.
  final int? height;
  /// The child widget.
  final Widget child;

  SizedBox({this.width, this.height, required this.child});

  @override
  Size layout(Constraints constraints) {
    final maxW = width ?? constraints.maxWidth;
    final maxH = height ?? constraints.maxHeight;
    return child.layout(
      Constraints(
        maxWidth: maxW.clamp(constraints.minWidth, constraints.maxWidth),
        maxHeight: maxH.clamp(constraints.minHeight, constraints.maxHeight),
      ),
    );
  }

  @override
  void paint(PaintingContext context) {
    child.paint(context);
  }
}
