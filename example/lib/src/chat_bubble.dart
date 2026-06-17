import 'dart:math';

import 'package:core/core.dart';
import 'package:widgets/widgets.dart';

import 'chat_message.dart';

/// A single message bubble with border, colored text, and timestamp.
class ChatBubble extends Widget {
  /// The chat message to display.
  final ChatMessage message;

  ChatBubble({required this.message});

  Widget? _boxWidget;
  Widget? _timestampWidget;
  int _boxWidth = 0;
  int _boxHeight = 0;
  int _timestampWidth = 0;
  int _timestampHeight = 0;
  int _allocatedWidth = 0;

  @override
  Size layout(Constraints constraints) {
    final color = message.isBot ? Color.blue() : Color.green();
    final timestampStr = _formatTimestamp(message.timestamp);

    _boxWidget = Box(
      child: Text(
        message.text,
        style: TextStyle(foreground: color),
        wordWrap: true,
      ),
      borderStyle: BorderStyle.single,
    );
    final boxSize = _boxWidget!.layout(
      Constraints(
        maxWidth: constraints.maxWidth,
        maxHeight: constraints.maxHeight,
      ),
    );
    _boxWidth = boxSize.width;
    _boxHeight = boxSize.height;

    _timestampWidget = Text(timestampStr, style: const TextStyle(dim: true));
    final timestampSize = _timestampWidget!.layout(
      Constraints(
        maxWidth: constraints.maxWidth,
        maxHeight: constraints.maxHeight,
      ),
    );
    _timestampWidth = timestampSize.width;
    _timestampHeight = timestampSize.height;

    _allocatedWidth = constraints.maxWidth;

    final totalWidth = max(_boxWidth, _timestampWidth);
    final hasTimestamp = _timestampHeight > 0;
    final totalHeight = _boxHeight + (hasTimestamp ? 1 + _timestampHeight : 0);

    return Size(
      totalWidth.clamp(constraints.minWidth, constraints.maxWidth),
      totalHeight.clamp(constraints.minHeight, constraints.maxHeight),
    );
  }

  @override
  void paint(PaintingContext context) {
    if (_boxWidget == null) return;

    final isBot = message.isBot;
    final boxX = isBot ? 0 : _allocatedWidth - _boxWidth;
    final timestampX = isBot ? 0 : _allocatedWidth - _timestampWidth;

    _boxWidget!.paint(context.child(boxX, 0));

    if (_timestampHeight > 0) {
      _timestampWidget!.paint(context.child(timestampX, _boxHeight));
    }
  }

  String _formatTimestamp(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
