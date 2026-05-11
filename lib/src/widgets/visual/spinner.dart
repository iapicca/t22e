import '../../loop/model.dart' show Model;
import '../../loop/msg.dart' show Msg, SpinnerTickMsg;
import '../../loop/cmd.dart' show Cmd, TickCmd;
import '../../well_known.dart' show WellKnown;
import '../widget.dart' show Widget;
import '../basic/text.dart' show Text;
import '../container/row.dart' show Row;

class Spinner extends Model<Spinner> {
  final int frame;
  final List<String> frames;
  final Duration interval;
  final String? label;

  static const List<String> defaultFrames = WellKnown.spinnerFrames;

  const Spinner({
    this.frame = 0,
    this.frames = defaultFrames,
    this.interval = WellKnown.spinnerAnimInterval,
    this.label,
  });

  @override
  (Spinner, Cmd?) update(Msg msg) {
    if (msg is SpinnerTickMsg) {
      return (
        copyWith(frame: (frame + 1) % frames.length),
        TickCmd(interval, (_) => const SpinnerTickMsg()),
      );
    }
    return (this, null);
  }

  Spinner copyWith({
    int? frame,
    List<String>? frames,
    Duration? interval,
    String? label,
  }) {
    return Spinner(
      frame: frame ?? this.frame,
      frames: frames ?? this.frames,
      interval: interval ?? this.interval,
      label: label ?? this.label,
    );
  }

  @override
  Widget view() {
    final spinnerText = frames[frame % frames.length];
    final children = <Widget>[
      Text(spinnerText),
    ];
    if (label != null) {
      children.add(Text(' $label'));
    }
    return Row(children: children);
  }
}
