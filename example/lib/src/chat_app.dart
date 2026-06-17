import 'package:widgets/widgets.dart';

import 'chat_model.dart';

/// Riverpod-accessible wrapper holding model state and the dispatch loop.
class ChatApp {
  ChatModel _model;

  ChatApp(ChatModel initialModel) : _model = initialModel;

  /// The current chat model state.
  ChatModel get model => _model;

  /// Dispatches a message, runs state update, and executes any side-effect.
  void dispatch(Msg msg) {
    final (newModel, cmd) = _model.update(msg);
    _model = newModel;
    if (cmd != null) {
      final result = cmd.execute((Msg newMsg) => dispatch(newMsg));
      if (result is Msg) {
        dispatch(result);
      } else if (result is Future<Msg?>) {
        result.then((msg) {
          if (msg != null) dispatch(msg);
        });
      }
    }
  }

  /// Returns the current widget tree for rendering.
  Widget view() => _model.view();
}
