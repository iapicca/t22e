import '../../loop/model.dart' show Model;
import '../../loop/msg.dart' show Msg, KeyMsg, CursorBlinkMsg;
import '../../loop/cmd.dart' show Cmd, TickCmd;
import '../../well_known.dart' show WellKnown;
import '../widget.dart' show Widget;
import '../basic/text.dart' show Text;
import '../container/row.dart' show Row;
import '../enums.dart' show EchoMode;
import '../../core/style.dart' show TextStyle;
import '../../parser/events.dart' show KeyCode, KeyEvent;

class TextInput extends Model<TextInput> {
  final String value;
  final int cursorPosition;
  final int? selectionStart;
  final int maxLength;
  final EchoMode echoMode;
  final String? Function(String)? validator;
  final bool cursorVisible;
  final Duration blinkInterval;

  const TextInput({
    this.value = '',
    this.cursorPosition = 0,
    this.selectionStart,
    this.maxLength = WellKnown.textInputNoMaxLength,
    this.echoMode = EchoMode.normal,
    this.validator,
    this.cursorVisible = true,
    this.blinkInterval = WellKnown.cursorBlinkInterval,
  });

  @override
  (TextInput, Cmd?) update(Msg msg) {
    if (msg is CursorBlinkMsg) {
      return (
        copyWith(cursorVisible: !cursorVisible),
        TickCmd(blinkInterval, (_) => const CursorBlinkMsg()),
      );
    }
    if (msg is KeyMsg) {
      return _handleKey(msg.event);
    }
    return (this, null);
  }

  (TextInput, Cmd?) _handleKey(KeyEvent event) {
    final keyCode = event.keyCode;
    final shift = event.modifiers.shift;

    switch (keyCode) {
      case KeyCode.left:
        if (cursorPosition > 0) {
          return (copyWith(
            cursorPosition: _prevGraphemeBoundary(cursorPosition),
            selectionStart: shift ? (selectionStart ?? cursorPosition) : null,
          ), null);
        }
        return (this, null);

      case KeyCode.right:
        if (cursorPosition < value.length) {
          return (copyWith(
            cursorPosition: _nextGraphemeBoundary(cursorPosition),
            selectionStart: shift ? (selectionStart ?? cursorPosition) : null,
          ), null);
        }
        return (this, null);

      case KeyCode.home:
        return (copyWith(
          cursorPosition: 0,
          selectionStart: shift ? (selectionStart ?? cursorPosition) : null,
        ), null);

      case KeyCode.end:
        return (copyWith(
          cursorPosition: value.length,
          selectionStart: shift ? (selectionStart ?? cursorPosition) : null,
        ), null);

      case KeyCode.backspace:
        if (cursorPosition > 0) {
          final prev = _prevGraphemeBoundary(cursorPosition);
          final newValue = value.substring(0, prev) + value.substring(cursorPosition);
          return (copyWith(value: newValue, cursorPosition: prev), null);
        }
        return (this, null);

      case KeyCode.delete:
        if (cursorPosition < value.length) {
          final next = _nextGraphemeBoundary(cursorPosition);
          final newValue = value.substring(0, cursorPosition) + value.substring(next);
          return (copyWith(value: newValue), null);
        }
        return (this, null);

      case KeyCode.char:
        final cp = event.codepoint;
        final char = cp != null ? String.fromCharCode(cp) : '';
        if (char.isEmpty) return (this, null);
        if (_isPrintable(char)) {
          return _insertChar(char);
        }
        return (this, null);

      default:
        return (this, null);
    }
  }

  bool _isPrintable(String char) {
    final cp = char.runes.first;
    return cp >= WellKnown.codepointSpace && cp != WellKnown.codepointDel;
  }

  (TextInput, Cmd?) _insertChar(String char) {
    if (maxLength > 0 && value.length >= maxLength) return (this, null);
    final newValue = value.substring(0, cursorPosition) +
        char +
        value.substring(cursorPosition);
    final newPos = cursorPosition + char.length;
    return (copyWith(value: newValue, cursorPosition: newPos, cursorVisible: true), null);
  }

  int _prevGraphemeBoundary(int pos) {
    if (pos <= 0) return 0;
    final runes = value.runes.toList();
    var strIdx = 0;
    for (var i = 0; i < runes.length; i++) {
      final ch = String.fromCharCode(runes[i]);
      final nextStrIdx = strIdx + ch.length;
      if (nextStrIdx >= pos) return strIdx;
      strIdx = nextStrIdx;
    }
    return strIdx;
  }

  int _nextGraphemeBoundary(int pos) {
    if (pos >= value.length) return value.length;
    final runes = value.runes.toList();
    var strIdx = 0;
    for (var i = 0; i < runes.length; i++) {
      final ch = String.fromCharCode(runes[i]);
      strIdx += ch.length;
      if (strIdx > pos) return strIdx;
    }
    return value.length;
  }

  String get _displayValue {
    return switch (echoMode) {
      EchoMode.normal => value,
      EchoMode.password => WellKnown.charBullet * value.length,
      EchoMode.noEcho => '',
    };
  }

  TextInput copyWith({
    String? value,
    int? cursorPosition,
    int? selectionStart,
    int? maxLength,
    EchoMode? echoMode,
    String? Function(String)? validator,
    bool? cursorVisible,
    Duration? blinkInterval,
  }) {
    return TextInput(
      value: value ?? this.value,
      cursorPosition: cursorPosition ?? this.cursorPosition,
      selectionStart: selectionStart ?? this.selectionStart,
      maxLength: maxLength ?? this.maxLength,
      echoMode: echoMode ?? this.echoMode,
      validator: validator ?? this.validator,
      cursorVisible: cursorVisible ?? this.cursorVisible,
      blinkInterval: blinkInterval ?? this.blinkInterval,
    );
  }

  @override
  Widget view() {
    final display = _displayValue;
    final cursorPos = cursorPosition.clamp(0, display.length);
    final beforeCursor = display.substring(0, cursorPos);
    final afterCursor = display.substring(cursorPos);

    final cursorChar = cursorVisible ? WellKnown.charFullBlock : ' ';

    return Row(children: [
      Text(beforeCursor),
      Text(cursorChar, style: const TextStyle(reverse: true)),
      Text(afterCursor),
    ]);
  }
}
