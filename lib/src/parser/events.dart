sealed class Event {
  const Event();
}

// --- key codes ---

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

final class KeyModifiers {
  final bool ctrl;
  final bool shift;
  final bool alt;
  final bool meta;

  const KeyModifiers({
    this.ctrl = false,
    this.shift = false,
    this.alt = false,
    this.meta = false,
  });

  @override
  bool operator ==(Object other) =>
      other is KeyModifiers &&
      ctrl == other.ctrl &&
      shift == other.shift &&
      alt == other.alt &&
      meta == other.meta;

  @override
  int get hashCode => Object.hash(ctrl, shift, alt, meta);
}

enum KeyEventType { down, up, repeat }

// --- input events ---

final class KeyEvent extends Event {
  final KeyCode keyCode;
  final KeyModifiers modifiers;
  final KeyEventType type;
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
  String toString() => 'KeyEvent($keyCode, $modifiers, $type${codepoint != null ? ', U+${codepoint!.toRadixString(16).padLeft(4, '0')}' : ''})';
}

enum MouseButton { left, middle, right, none, wheelUp, wheelDown }

enum MouseAction { press, release, move, drag }

final class MouseEvent extends Event {
  final MouseButton button;
  final MouseAction action;
  final int x;
  final int y;

  const MouseEvent({
    required this.button,
    required this.action,
    required this.x,
    required this.y,
  });

  @override
  bool operator ==(Object other) =>
      other is MouseEvent &&
      button == other.button &&
      action == other.action &&
      x == other.x &&
      y == other.y;

  @override
  int get hashCode => Object.hash(button, action, x, y);

  @override
  String toString() => 'MouseEvent($button, $action, $x, $y)';
}

final class PasteEvent extends Event {
  final String content;

  const PasteEvent(this.content);

  @override
  bool operator ==(Object other) =>
      other is PasteEvent && content == other.content;

  @override
  int get hashCode => content.hashCode;

  @override
  String toString() => 'PasteEvent(${content.length} chars)';
}

// --- response events ---

final class CursorPositionEvent extends Event {
  final int row;
  final int col;

  const CursorPositionEvent(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      other is CursorPositionEvent && row == other.row && col == other.col;

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() => 'CursorPositionEvent($row, $col)';
}

final class ColorQueryEvent extends Event {
  final int colorNumber;
  final int? r;
  final int? g;
  final int? b;

  const ColorQueryEvent(this.colorNumber, [this.r, this.g, this.b]);

  @override
  bool operator ==(Object other) =>
      other is ColorQueryEvent &&
      colorNumber == other.colorNumber &&
      r == other.r &&
      g == other.g &&
      b == other.b;

  @override
  int get hashCode => Object.hash(colorNumber, r, g, b);

  @override
  String toString() => 'ColorQueryEvent(color=$colorNumber, rgb($r,$g,$b))';
}

final class PrimaryDeviceAttributesEvent extends Event {
  final List<int> params;

  const PrimaryDeviceAttributesEvent(this.params);

  @override
  bool operator ==(Object other) =>
      other is PrimaryDeviceAttributesEvent &&
      _listEquals(params, other.params);

  @override
  int get hashCode => Object.hashAll(params);

  @override
  String toString() => 'PrimaryDeviceAttributesEvent($params)';
}

final class KeyboardEnhancementFlagsEvent extends Event {
  final int flags;

  const KeyboardEnhancementFlagsEvent(this.flags);

  @override
  bool operator ==(Object other) =>
      other is KeyboardEnhancementFlagsEvent && flags == other.flags;

  @override
  int get hashCode => flags.hashCode;

  @override
  String toString() => 'KeyboardEnhancementFlagsEvent($flags)';
}

final class WindowResizeEvent extends Event {
  final int rows;
  final int cols;
  final int? widthPixels;
  final int? heightPixels;

  const WindowResizeEvent(this.rows, this.cols, [this.widthPixels, this.heightPixels]);

  @override
  bool operator ==(Object other) =>
      other is WindowResizeEvent &&
      rows == other.rows &&
      cols == other.cols &&
      widthPixels == other.widthPixels &&
      heightPixels == other.heightPixels;

  @override
  int get hashCode => Object.hash(rows, cols, widthPixels, heightPixels);

  @override
  String toString() => 'WindowResizeEvent(${rows}x$cols)';
}

final class FocusEvent extends Event {
  final bool focused;

  const FocusEvent(this.focused);

  @override
  bool operator ==(Object other) =>
      other is FocusEvent && focused == other.focused;

  @override
  int get hashCode => focused.hashCode;

  @override
  String toString() => 'FocusEvent($focused)';
}

final class QuerySyncUpdateEvent extends Event {
  final bool supported;

  const QuerySyncUpdateEvent(this.supported);

  @override
  bool operator ==(Object other) =>
      other is QuerySyncUpdateEvent && supported == other.supported;

  @override
  int get hashCode => supported.hashCode;

  @override
  String toString() => 'QuerySyncUpdateEvent(supported=$supported)';
}

final class ClipboardEvent extends Event {
  final String clipboard;
  final String? base64;

  const ClipboardEvent(this.clipboard, [this.base64]);

  @override
  bool operator ==(Object other) =>
      other is ClipboardEvent &&
      clipboard == other.clipboard &&
      base64 == other.base64;

  @override
  int get hashCode => Object.hash(clipboard, base64);

  @override
  String toString() => 'ClipboardEvent($clipboard, ${base64 != null ? '${base64!.length} bytes' : 'query'})';
}

// --- utility ---

final class ErrorEvent extends Event {
  final String message;
  final Object? cause;

  const ErrorEvent(this.message, [this.cause]);

  @override
  String toString() => 'ErrorEvent($message${cause != null ? ': $cause' : ''})';
}

final class InternalEvent extends Event {
  final String kind;
  final Map<String, Object?>? data;

  const InternalEvent(this.kind, [this.data]);

  @override
  String toString() => 'InternalEvent($kind${data != null ? ', $data' : ''})';
}

bool _listEquals(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
