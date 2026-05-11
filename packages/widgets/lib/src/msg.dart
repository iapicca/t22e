import 'package:parser/terminal_parser.dart' show KeyEvent, MouseEvent;

sealed class Msg {
  const Msg();
}

final class QuitMsg extends Msg {
  const QuitMsg();
}

final class InterruptMsg extends Msg {
  const InterruptMsg();
}

final class SuspendMsg extends Msg {
  const SuspendMsg();
}

final class ResumeMsg extends Msg {
  const ResumeMsg();
}

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

final class ClearScreenMsg extends Msg {
  const ClearScreenMsg();
}

final class EnterAltScreenMsg extends Msg {
  const EnterAltScreenMsg();
}

final class ExitAltScreenMsg extends Msg {
  const ExitAltScreenMsg();
}

final class HideCursorMsg extends Msg {
  const HideCursorMsg();
}

final class ShowCursorMsg extends Msg {
  const ShowCursorMsg();
}

final class KeyMsg extends Msg {
  final KeyEvent event;
  const KeyMsg(this.event);

  @override
  bool operator ==(Object other) => other is KeyMsg && event == other.event;

  @override
  int get hashCode => event.hashCode;
}

final class MouseMsg extends Msg {
  final MouseEvent event;
  const MouseMsg(this.event);

  @override
  bool operator ==(Object other) => other is MouseMsg && event == other.event;

  @override
  int get hashCode => event.hashCode;
}

final class ProgressTickMsg extends Msg {
  const ProgressTickMsg();
}

final class SpinnerTickMsg extends Msg {
  const SpinnerTickMsg();
}

final class CursorBlinkMsg extends Msg {
  const CursorBlinkMsg();
}

final class ListEnterMsg extends Msg {
  final int index;
  final String label;
  const ListEnterMsg(this.index, this.label);
}

final class DialogCloseMsg extends Msg {
  const DialogCloseMsg();
}

final class DialogButtonMsg extends Msg {
  final int index;
  final String label;
  const DialogButtonMsg(this.index, this.label);
}
