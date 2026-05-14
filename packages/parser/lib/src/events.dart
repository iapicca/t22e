// Event types emitted by the terminal parser: key, mouse, clipboard, and responses.
import 'package:freezed_annotation/freezed_annotation.dart';

part 'events.freezed.dart';
sealed class Event {
  const Event();
}

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

/// Keyboard modifier flags for key events.
@freezed
abstract class KeyModifiers with _$KeyModifiers {
  const factory KeyModifiers({
    @Default(false) bool ctrl,
    @Default(false) bool shift,
    @Default(false) bool alt,
    @Default(false) bool meta,
  }) = _KeyModifiers;
}

/// Key event type: press, release, or repeat.
enum KeyEventType { down, up, repeat }

/// A keyboard input event.
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

/// Mouse button identifiers.
enum MouseButton { left, middle, right, none, wheelUp, wheelDown }

/// Mouse action type.
enum MouseAction { press, release, move, drag }

/// A mouse input event.
final class MouseEvent extends Event {
  /// Which mouse button was involved.
  final MouseButton button;
  /// Press, release, move, or drag.
  final MouseAction action;
  /// Column position (0-based).
  final int x;
  /// Row position (0-based).
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

/// A bracketed paste event.
final class PasteEvent extends Event {
  /// The pasted text content.
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

/// Terminal response: cursor position report.
final class CursorPositionEvent extends Event {
  /// Row (1-based).
  final int row;
  /// Column (1-based).
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

/// Terminal response: color query with optional RGB values.
final class ColorQueryEvent extends Event {
  /// OSC color number (10=fg, 11=bg).
  final int colorNumber;
  /// Red component, or null if not available.
  final int? r;
  /// Green component, or null if not available.
  final int? g;
  /// Blue component, or null if not available.
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

/// Terminal response: primary device attributes (DA1).
final class PrimaryDeviceAttributesEvent extends Event {
  /// The DA1 parameter list.
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

/// Terminal response: Kitty keyboard protocol flags.
final class KeyboardEnhancementFlagsEvent extends Event {
  /// The flags value reported by the terminal.
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

/// SIGWINCH / window resize event.
final class WindowResizeEvent extends Event {
  /// New terminal rows.
  final int rows;
  /// New terminal columns.
  final int cols;
  /// Width in pixels (optional).
  final int? widthPixels;
  /// Height in pixels (optional).
  final int? heightPixels;

  const WindowResizeEvent(
    this.rows,
    this.cols, [
    this.widthPixels,
    this.heightPixels,
  ]);

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

/// Focus gained/lost event.
final class FocusEvent extends Event {
  /// True if the terminal gained focus.
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

/// Terminal response: synchronized update capability.
final class QuerySyncUpdateEvent extends Event {
  /// True if the terminal supports sync updates.
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

/// Clipboard read/write event.
final class ClipboardEvent extends Event {
  /// Clipboard selection name (e.g. 'c' for system).
  final String clipboard;
  /// Base64-encoded clipboard data, or null for a query.
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
  String toString() =>
      'ClipboardEvent($clipboard, ${base64 != null ? '${base64!.length} bytes' : 'query'})';
}

/// Error event for malformed or unhandled sequences.
final class ErrorEvent extends Event {
  /// Human-readable error message.
  final String message;
  /// Optional underlying cause.
  final Object? cause;

  const ErrorEvent(this.message, [this.cause]);

  @override
  String toString() => 'ErrorEvent($message${cause != null ? ': $cause' : ''})';
}

/// Internal event for plumbing between parser layers.
final class InternalEvent extends Event {
  /// Event kind string.
  final String kind;
  /// Optional key-value data payload.
  final Map<String, Object?>? data;

  const InternalEvent(this.kind, [this.data]);

  @override
  String toString() => 'InternalEvent($kind${data != null ? ', $data' : ''})';
}

/// Compares two integer lists for equality.
bool _listEquals(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
