import 'package:parser/terminal_parser.dart' show KeyEvent, MouseEvent;

/// Base sealed class for all messages in the MVU architecture.
sealed class Msg {
  const Msg();
}

/// Signals the program to terminate.
final class QuitMsg extends Msg {
  const QuitMsg();
}

/// Raised on SIGINT (Ctrl+C).
final class InterruptMsg extends Msg {
  const InterruptMsg();
}

/// Raised on SIGTSTP (suspend).
final class SuspendMsg extends Msg {
  const SuspendMsg();
}

/// Raised on SIGCONT (resume).
final class ResumeMsg extends Msg {
  const ResumeMsg();
}

/// The terminal window was resized.
final class WindowSizeMsg extends Msg {
  /// New width in columns.
  final int width;
  /// New height in rows.
  final int height;

  const WindowSizeMsg(this.width, this.height);

  @override
  bool operator ==(Object other) =>
      other is WindowSizeMsg && width == other.width && height == other.height;

  @override
  int get hashCode => Object.hash(width, height);
}

/// Requests a full screen repaint.
final class ClearScreenMsg extends Msg {
  const ClearScreenMsg();
}

/// Requests entering the alternate screen buffer.
final class EnterAltScreenMsg extends Msg {
  const EnterAltScreenMsg();
}

/// Requests exiting the alternate screen buffer.
final class ExitAltScreenMsg extends Msg {
  const ExitAltScreenMsg();
}

/// Requests hiding the cursor.
final class HideCursorMsg extends Msg {
  const HideCursorMsg();
}

/// Requests showing the cursor.
final class ShowCursorMsg extends Msg {
  const ShowCursorMsg();
}

/// A keyboard event message.
final class KeyMsg extends Msg {
  /// The parsed key event.
  final KeyEvent event;
  const KeyMsg(this.event);

  @override
  bool operator ==(Object other) => other is KeyMsg && event == other.event;

  @override
  int get hashCode => event.hashCode;
}

/// A mouse event message.
final class MouseMsg extends Msg {
  /// The parsed mouse event.
  final MouseEvent event;
  const MouseMsg(this.event);

  @override
  bool operator ==(Object other) => other is MouseMsg && event == other.event;

  @override
  int get hashCode => event.hashCode;
}

/// Periodic tick for progress bar animation.
final class ProgressTickMsg extends Msg {
  const ProgressTickMsg();
}

/// Periodic tick for spinner animation.
final class SpinnerTickMsg extends Msg {
  const SpinnerTickMsg();
}

/// Periodic tick for text input cursor blink.
final class CursorBlinkMsg extends Msg {
  const CursorBlinkMsg();
}

/// An item was selected/activated in a ListView.
final class ListEnterMsg extends Msg {
  /// Index of the selected item.
  final int index;
  /// Label of the selected item.
  final String label;
  const ListEnterMsg(this.index, this.label);
}

/// The dialog was closed (e.g. via Escape).
final class DialogCloseMsg extends Msg {
  const DialogCloseMsg();
}

/// A button in a Dialog was pressed.
final class DialogButtonMsg extends Msg {
  /// Button index in the button list.
  final int index;
  /// Button label.
  final String label;
  const DialogButtonMsg(this.index, this.label);
}
