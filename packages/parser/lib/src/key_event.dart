part of 'events.dart';

/// Identifies logical keys (arrows, function keys, home, end, etc.).
enum KeyCode {
  none,
  tab,
  enter,
  escape,
  backspace,
  space,
  up,
  down,
  left,
  right,
  home,
  end,
  pageUp,
  pageDown,
  insert,
  delete,
  f1,
  f2,
  f3,
  f4,
  f5,
  f6,
  f7,
  f8,
  f9,
  f10,
  f11,
  f12,
  f13,
  f14,
  f15,
  f16,
  f17,
  f18,
  f19,
  f20,
  f21,
  f22,
  f23,
  f24,
  char,
}

/// Key event type: press, release, or repeat.
enum KeyEventType { down, up, repeat }

/// A keyboard input event.
/// TODO this should be a freezed class
final class KeyEvent extends Event {
  /// Which logical key was pressed.
  final KeyCode keyCode;

  /// Modifier keys held at the time.
  final KeyModifiers modifiers;

  /// Event type (down/up/repeat).
  final KeyEventType type;

  /// Unicode codepoint for char events, null otherwise.
  final int? codepoint;

  const KeyEvent({
    required this.keyCode,
    this.modifiers = const KeyModifiers(),
    this.type = KeyEventType.down,
    this.codepoint,
  });

  @override
  bool operator ==(Object other) =>
      other is KeyEvent &&
      keyCode == other.keyCode &&
      modifiers == other.modifiers &&
      type == other.type &&
      codepoint == other.codepoint;

  @override
  int get hashCode => Object.hash(keyCode, modifiers, type, codepoint);

  @override
  String toString() =>
      'KeyEvent($keyCode, $modifiers, $type${codepoint != null ? ', U+${codepoint!.toRadixString(16).padLeft(4, '0')}' : ''})';
}
