import 'dart:math';

import 'package:core/core.dart';
import 'package:widgets/widgets.dart';

import 'chat_bubble.dart';
import 'chat_message.dart';

/// The chat message area displaying bubbles scrolled to the bottom.
class ChatView extends Widget {
  /// All chat messages to display.
  final List<ChatMessage> messages;

  ChatView({required this.messages});

  List<Widget>? _bubbles;
  List<int>? _bubbleHeights;
  int _allocatedWidth = 0;
  int _allocatedHeight = 0;
  int _totalContentHeight = 0;

  @override
  Size layout(Constraints constraints) {
    _allocatedWidth = constraints.maxWidth;
    _allocatedHeight = constraints.maxHeight;

    if (messages.isEmpty) {
      _bubbles = null;
      _bubbleHeights = null;
      _totalContentHeight = 0;
      return const Size(0, 0);
    }

    _bubbles = [];
    _bubbleHeights = [];
    _totalContentHeight = 0;

    for (final msg in messages) {
      final bubble = ChatBubble(message: msg);
      final size = bubble.layout(
        Constraints(
          maxWidth: constraints.maxWidth,
          maxHeight: constraints.maxHeight,
        ),
      );
      _bubbles!.add(bubble);
      _bubbleHeights!.add(size.height);
      _totalContentHeight += size.height + 1;
    }
    _totalContentHeight -= 1;

    return Size(
      _allocatedWidth.clamp(constraints.minWidth, constraints.maxWidth),
      _totalContentHeight.clamp(constraints.minHeight, constraints.maxHeight),
    );
  }

  @override
  void paint(PaintingContext context) {
    if (_bubbles == null || _bubbleHeights == null) return;

    final viewportHeight = _allocatedHeight;
    final scrollOffset = max(0, _totalContentHeight - viewportHeight);

    var yOffset = -scrollOffset;

    for (var i = 0; i < _bubbles!.length; i++) {
      final bubbleHeight = _bubbleHeights![i];

      if (yOffset + bubbleHeight > 0 && yOffset < viewportHeight) {
        _bubbles![i].paint(context.child(0, yOffset));
      }

      yOffset += bubbleHeight + 1;
    }
  }
}
