import 'package:core/core.dart';
import 'package:parser/terminal_parser.dart' show KeyCode;
import 'package:widgets/widgets.dart';

import 'chat_message.dart';
import 'messages.dart';

/// The TEA model for the chat application.
class ChatModel extends Model<ChatModel> {
  /// All chat messages.
  final List<ChatMessage> messages;

  /// The text input widget state.
  final TextInput input;

  /// Current terminal width in columns.
  final int terminalWidth;

  /// Current terminal height in rows.
  final int terminalHeight;

  const ChatModel({
    this.messages = const [],
    this.input = const TextInput(),
    this.terminalWidth = 80,
    this.terminalHeight = 24,
  });

  @override
  (ChatModel, Cmd?) update(Msg msg) {
    if (msg is QuitMsg) return (this, none());
    if (msg is WindowSizeMsg) {
      return (
        copyWith(terminalWidth: msg.width, terminalHeight: msg.height),
        null,
      );
    }
    if (msg is KeyMsg) {
      final event = msg.event;
      if (event.codepoint == 0x03) return (this, null);
      if (event.keyCode == KeyCode.enter) return _handleEnter();
      return _delegateToInput(msg);
    }
    if (msg is CursorBlinkMsg) return _delegateToInput(msg);
    if (msg is BotReplyMsg) return _handleBotReply(msg.originalText);
    return (this, null);
  }

  /// Delegates a message to the TextInput and propagates its state change.
  (ChatModel, Cmd?) _delegateToInput(Msg msg) {
    final (newInput, cmd) = input.update(msg);
    return (copyWith(input: newInput), cmd);
  }

  /// Handles Enter: creates a user message and schedules a bot reply.
  (ChatModel, Cmd?) _handleEnter() {
    final text = input.value.trim();
    if (text.isEmpty) return (this, null);

    final message = ChatMessage(
      text: text,
      isBot: false,
      timestamp: DateTime.now(),
    );
    final newInput = const TextInput();
    final tickCmd = TickCmd(
      const Duration(milliseconds: 250),
      (_) => BotReplyMsg(text),
    );
    return (
      copyWith(messages: [...messages, message], input: newInput),
      tickCmd,
    );
  }

  /// Adds a bot reply message to the list.
  (ChatModel, Cmd?) _handleBotReply(String originalText) {
    final reply = 'Your message was ${originalText.length} characters';
    final message = ChatMessage(
      text: reply,
      isBot: true,
      timestamp: DateTime.now(),
    );
    return (copyWith(messages: [...messages, message]), null);
  }

  /// Returns a copy with overridden fields.
  ChatModel copyWith({
    List<ChatMessage>? messages,
    TextInput? input,
    int? terminalWidth,
    int? terminalHeight,
  }) {
    return ChatModel(
      messages: messages ?? this.messages,
      input: input ?? this.input,
      terminalWidth: terminalWidth ?? this.terminalWidth,
      terminalHeight: terminalHeight ?? this.terminalHeight,
    );
  }

  @override
  Widget view() {
    return Column(
      children: [
        Spacer(flex: 2),
        Text(
          '\nPress Enter to send - Ctrl+C to quit',
          style: const TextStyle(dim: true),
        ),
        input.view(),
      ],
    );
  }
}
