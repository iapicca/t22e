import 'package:widgets/widgets.dart';
import 'package:core/core.dart';
import 'package:parser/terminal_parser.dart';
import 'package:protocol/protocol.dart' show Defaults;
import 'chat_message.dart';
import 'chat_view.dart';

class ChatModel extends Model<ChatModel> {
  final List<ChatMessage> messages;
  final String inputValue;
  final int cursorPosition;
  final int terminalWidth;
  final int terminalHeight;
  final bool cursorVisible;

  const ChatModel({
    this.messages = const [],
    this.inputValue = '',
    this.cursorPosition = 0,
    this.terminalWidth = 80,
    this.terminalHeight = 24,
    this.cursorVisible = true,
  });

  static ChatModel initial(int width, int height) {
    return ChatModel(
      terminalWidth: width,
      terminalHeight: height,
      messages: const [
        ChatMessage(text: 'Hello', isUser: false),
      ],
    );
  }

  @override
  (ChatModel, Cmd?) update(Msg msg) {
    if (msg is KeyMsg) {
      return _handleKey(msg);
    }
    if (msg is WindowSizeMsg) {
      return (
        copyWith(
          terminalWidth: msg.width,
          terminalHeight: msg.height,
        ),
        null,
      );
    }
    if (msg is CursorBlinkMsg) {
      return (
        copyWith(cursorVisible: !cursorVisible),
        TickCmd(const Duration(milliseconds: 500), (_) => const CursorBlinkMsg()),
      );
    }
    return (this, null);
  }

  (ChatModel, Cmd?) _handleKey(KeyMsg msg) {
    final event = msg.event;
    final keyCode = event.keyCode;

    if (keyCode == KeyCode.enter) {
      return _handleSubmit();
    }

    if (keyCode == KeyCode.char) {
      final cp = event.codepoint;
      if (cp != null && cp >= Defaults.codepointSpace && cp != Defaults.codepointDel) {
        return _insertChar(String.fromCharCode(cp));
      }
      return (this, null);
    }

    if (keyCode == KeyCode.left) {
      if (cursorPosition > 0) {
        return (
          copyWith(cursorPosition: _prevGraphemeBoundary(cursorPosition)),
          null,
        );
      }
      return (this, null);
    }

    if (keyCode == KeyCode.right) {
      if (cursorPosition < inputValue.length) {
        return (
          copyWith(cursorPosition: _nextGraphemeBoundary(cursorPosition)),
          null,
        );
      }
      return (this, null);
    }

    if (keyCode == KeyCode.backspace) {
      if (cursorPosition > 0) {
        final prev = _prevGraphemeBoundary(cursorPosition);
        final newValue = inputValue.substring(0, prev) + inputValue.substring(cursorPosition);
        return (
          copyWith(value: newValue, cursorPosition: prev),
          null,
        );
      }
      return (this, null);
    }

    if (keyCode == KeyCode.delete) {
      if (cursorPosition < inputValue.length) {
        final next = _nextGraphemeBoundary(cursorPosition);
        final newValue = inputValue.substring(0, cursorPosition) + inputValue.substring(next);
        return (copyWith(value: newValue), null);
      }
      return (this, null);
    }

    if (keyCode == KeyCode.home) {
      return (copyWith(cursorPosition: 0), null);
    }

    if (keyCode == KeyCode.end) {
      return (copyWith(cursorPosition: inputValue.length), null);
    }

    return (this, null);
  }

  (ChatModel, Cmd?) _handleSubmit() {
    if (inputValue.trim().isEmpty) {
      return (this, null);
    }

    final userMsg = ChatMessage(text: inputValue, isUser: true);
    final botReply = ChatMessage(
      text: "'$inputValue' is ${inputValue.length} characters long",
      isUser: false,
    );

    final newMessages = [...messages, userMsg, botReply];

    return (
      copyWith(
        messages: newMessages,
        value: '',
        cursorPosition: 0,
        cursorVisible: true,
      ),
      null,
    );
  }

  (ChatModel, Cmd?) _insertChar(String char) {
    final newValue =
        inputValue.substring(0, cursorPosition) +
        char +
        inputValue.substring(cursorPosition);
    final newPos = cursorPosition + char.length;
    return (
      copyWith(value: newValue, cursorPosition: newPos, cursorVisible: true),
      null,
    );
  }

  int _prevGraphemeBoundary(int pos) {
    if (pos <= 0) return 0;
    final runes = inputValue.runes.toList();
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
    if (pos >= inputValue.length) return inputValue.length;
    final runes = inputValue.runes.toList();
    var strIdx = 0;
    for (var i = 0; i < runes.length; i++) {
      final ch = String.fromCharCode(runes[i]);
      strIdx += ch.length;
      if (strIdx > pos) return strIdx;
    }
    return inputValue.length;
  }

  ChatModel copyWith({
    List<ChatMessage>? messages,
    String? value,
    int? cursorPosition,
    int? terminalWidth,
    int? terminalHeight,
    bool? cursorVisible,
  }) {
    return ChatModel(
      messages: messages ?? this.messages,
      inputValue: value ?? inputValue,
      cursorPosition: cursorPosition ?? this.cursorPosition,
      terminalWidth: terminalWidth ?? this.terminalWidth,
      terminalHeight: terminalHeight ?? this.terminalHeight,
      cursorVisible: cursorVisible ?? this.cursorVisible,
    );
  }

  @override
  Widget view() {
    final chatHeight = terminalHeight * 2 ~/ 3;
    final inputHeight = terminalHeight - chatHeight - 1;

    return Column(
      children: [
        ChatView(
          messages: messages,
          width: terminalWidth,
          height: chatHeight,
        ),
        Text(
          '─' * terminalWidth,
          style: TextStyle(foreground: Color.brightBlack()),
        ),
        _buildInputArea(inputHeight),
      ],
    );
  }

  Widget _buildInputArea(int height) {
    final display = inputValue;
    final cursorPos = cursorPosition.clamp(0, display.length);
    final beforeCursor = display.substring(0, cursorPos);
    final afterCursor = display.substring(cursorPos);
    final cursorChar = cursorVisible ? Defaults.charFullBlock : ' ';

    return Column(
      children: [
        Row(
          children: [
            Text('> ', style: TextStyle(foreground: Color.brightGreen(), bold: true)),
            Text(beforeCursor),
            Text(cursorChar, style: const TextStyle(reverse: true)),
            Text(afterCursor),
          ],
        ),
        Text(
          'Press Enter to send - q to quit',
          style: TextStyle(foreground: Color.brightBlack(), dim: true),
        ),
      ],
    );
  }
}
