import 'package:widgets/widgets.dart';
import 'package:core/core.dart';
import 'chat_message.dart';
import 'chat_bubble.dart';

class ChatView extends Widget {
  final List<ChatMessage> messages;
  final int width;
  final int height;

  late Size _size;
  late List<(int, ChatBubble, bool)> _laidOutBubbles;

  ChatView({required this.messages, required this.width, required this.height});

  @override
  Size layout(Constraints constraints) {
    _laidOutBubbles = [];
    var yOffset = 0;
    final bubbleMaxWidth = width - 2;

    for (final msg in messages) {
      final bubble = ChatBubble(
        text: msg.text,
        isUser: msg.isUser,
        maxWidth: bubbleMaxWidth,
      );
      final size = bubble.layout(
        Constraints(
          minWidth: 0,
          maxWidth: bubbleMaxWidth,
          minHeight: 0,
          maxHeight: height,
        ),
      );

      if (yOffset + size.height <= height) {
        _laidOutBubbles.add((yOffset, bubble, msg.isUser));
        yOffset += size.height + 1;
      }
    }

    _size = Size(width, height);
    return _size;
  }

  @override
  void paint(PaintingContext context) {
    for (final entry in _laidOutBubbles) {
      final yOffset = entry.$1;
      final bubble = entry.$2;
      final isUser = entry.$3;

      final bubbleWidth = bubble.size.width;

      final xOffset = isUser ? width - bubbleWidth - 2 : 2;

      bubble.paint(context.child(xOffset, yOffset));
    }
  }
}
