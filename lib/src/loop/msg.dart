import '../parser/events.dart' show KeyEvent, MouseEvent;

/// Base sealed class for all application messages (TEA Msg)
sealed class Msg {
  const Msg();
}

/// Signal to quit the application cleanly
final class QuitMsg extends Msg {
  const QuitMsg();
}

/// SIGINT interrupt signal received
final class InterruptMsg extends Msg {
  const InterruptMsg();
}

/// SIGTSTP suspend signal received
final class SuspendMsg extends Msg {
  const SuspendMsg();
}

/// SIGCONT resume signal received
final class ResumeMsg extends Msg {
  const ResumeMsg();
}

/// Terminal window was resized
final class WindowSizeMsg extends Msg {
  final int width;
  final int height;

  const WindowSizeMsg(this.width, this.height);

  @override
  bool operator ==(Object other) =>
      other is WindowSizeMsg && width == other.width && height == other.height;

  @override
  int get hashCode => Object.hash(width, height);
}

/// Request to clear the terminal screen
final class ClearScreenMsg extends Msg {
  const ClearScreenMsg();
}

/// Request to enter the alternate screen buffer
final class EnterAltScreenMsg extends Msg {
  const EnterAltScreenMsg();
}

/// Request to exit the alternate screen buffer
final class ExitAltScreenMsg extends Msg {
  const ExitAltScreenMsg();
}

/// Request to hide the terminal cursor
final class HideCursorMsg extends Msg {
  const HideCursorMsg();
}

/// Request to show the terminal cursor
final class ShowCursorMsg extends Msg {
  const ShowCursorMsg();
}

/// A keyboard input event message
final class KeyMsg extends Msg {
  final KeyEvent event;
  const KeyMsg(this.event);

  @override
  bool operator ==(Object other) =>
      other is KeyMsg && event == other.event;

  @override
  int get hashCode => event.hashCode;
}

/// A mouse input event message
final class MouseMsg extends Msg {
  final MouseEvent event;
  const MouseMsg(this.event);

  @override
  bool operator ==(Object other) =>
      other is MouseMsg && event == other.event;

  @override
  int get hashCode => event.hashCode;
}

// Widget Library Messages

/// Periodic tick to advance the progress bar animation
final class ProgressTickMsg extends Msg {
  const ProgressTickMsg();
}

/// Periodic tick to advance the spinner animation frame
final class SpinnerTickMsg extends Msg {
  const SpinnerTickMsg();
}

/// Periodic tick to toggle the cursor blink state
final class CursorBlinkMsg extends Msg {
  const CursorBlinkMsg();
}

/// User pressed enter on a list item
final class ListEnterMsg extends Msg {
  final int index;
  final String label;
  const ListEnterMsg(this.index, this.label);
}

/// Dialog was dismissed
final class DialogCloseMsg extends Msg {
  const DialogCloseMsg();
}

/// A dialog button was pressed
final class DialogButtonMsg extends Msg {
  final int index;
  final String label;
  const DialogButtonMsg(this.index, this.label);
}
