import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';

/// An immutable chat message data class.
@freezed
abstract class ChatMessage with _$ChatMessage {
  /// Creates a chat message with text, sender flag, and timestamp.
  const factory ChatMessage({
    required String text,
    required bool isBot,
    required DateTime timestamp,
  }) = _ChatMessage;
}
