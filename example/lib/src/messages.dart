import 'package:widgets/widgets.dart';

/// Triggers a simulated bot reply after a delay.
final class BotReplyMsg extends Msg {
  /// The original user text that prompted this reply.
  final String originalText;
  const BotReplyMsg(this.originalText);
}
