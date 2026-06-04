class ChatMessage {
  final String text;
  final bool isUser;

  const ChatMessage({required this.text, required this.isUser});

  ChatMessage copyWith({String? text, bool? isUser}) {
    return ChatMessage(text: text ?? this.text, isUser: isUser ?? this.isUser);
  }

  @override
  String toString() => 'ChatMessage(text: $text, isUser: $isUser)';
}
