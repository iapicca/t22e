import 'msg.dart' show Msg;
import 'cmd.dart' show Cmd;

abstract class Model<M extends Model<M>> {
  const Model();

  (M, Cmd?) update(Msg msg);

  dynamic view();
}
