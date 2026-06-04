import 'msg.dart' show Msg;
import 'cmd.dart' show Cmd;

/// Elm-style Model base class with update/view pattern.
abstract class Model<M extends Model<M>> {
  const Model();

  /// Returns (newModel, optionalCommand) in response to a message.
  (M, Cmd?) update(Msg msg);

  /// Returns the Widget or Surface representing this model's current state.
  dynamic view();
}
