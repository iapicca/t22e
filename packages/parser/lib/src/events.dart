// Event types emitted by the terminal parser: key, mouse, clipboard, and responses.
import 'package:freezed_annotation/freezed_annotation.dart';

part 'events.freezed.dart';
part 'key_event.dart';
part 'mouse_event.dart';

/// TODO this should be a freezed class
sealed class Event {
  const Event();
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

/// A mouse input event.
@freezed
abstract class MouseEvent extends Event with _$MouseEvent {
  const MouseEvent._();

  const factory MouseEvent({
    required MouseButton button,
    required MouseAction action,
    required int x,
    required int y,
  }) = _MouseEvent;
}

/// A bracketed paste event.
/// TODO this should be a freezed class
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
/// TODO this should be a freezed class
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
/// TODO this should be a freezed class
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
/// TODO this should be a freezed class
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
/// TODO this should be a freezed class
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

/// Focus gained/lost event.
/// TODO this should be a freezed class
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
/// TODO this should be a freezed class
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
/// TODO this should be a freezed class
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
/// TODO this should be a freezed class
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
/// TODO this should be a freezed class
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
