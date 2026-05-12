import 'msg.dart' show Msg;
import 'cmd.dart' show Cmd;

/// The Elm Architecture model: holds state and returns (newModel, optionalCmd)
abstract class Model<M extends Model<M>> {
  const Model();

  /// Processes a message and returns (newModel, optional side-effect command)
  (M, Cmd?) update(Msg msg);

  /// Returns the current view representation
  dynamic view();
}
