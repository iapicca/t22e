import '../../loop/model.dart' show Model;
import '../../loop/msg.dart' show Msg, ProgressTickMsg;
import '../../loop/cmd.dart' show Cmd, TickCmd;
import '../../well_known.dart' show WellKnown;
import '../widget.dart' show Widget;
import '../basic/text.dart' show Text;
import '../container/row.dart' show Row;
import '../../core/style.dart' show TextStyle;

class ProgressBar extends Model<ProgressBar> {
  final double? fraction;
  final String? label;
  final int barWidth;
  final String fillChar;
  final String emptyChar;
  final Duration animInterval;
  final int indeterminateOffset;

  const ProgressBar({
    this.fraction,
    this.label,
    this.barWidth = WellKnown.defaultProgressBarWidth,
    this.fillChar = WellKnown.charFullBlock,
    this.emptyChar = WellKnown.charLightShade,
    this.animInterval = WellKnown.progressAnimInterval,
    this.indeterminateOffset = 0,
  });

  @override
  (ProgressBar, Cmd?) update(Msg msg) {
    if (msg is ProgressTickMsg && fraction == null) {
      return (
        copyWith(indeterminateOffset: indeterminateOffset + 1),
        TickCmd(animInterval, (_) => const ProgressTickMsg()),
      );
    }
    return (this, null);
  }

  ProgressBar copyWith({
    double? fraction,
    String? label,
    int? barWidth,
    String? fillChar,
    String? emptyChar,
    Duration? animInterval,
    int? indeterminateOffset,
  }) {
    return ProgressBar(
      fraction: fraction ?? this.fraction,
      label: label ?? this.label,
      barWidth: barWidth ?? this.barWidth,
      fillChar: fillChar ?? this.fillChar,
      emptyChar: emptyChar ?? this.emptyChar,
      animInterval: animInterval ?? this.animInterval,
      indeterminateOffset: indeterminateOffset ?? this.indeterminateOffset,
    );
  }

  @override
  Widget view() {
    final filled = fraction != null
        ? (barWidth * fraction!).round().clamp(0, barWidth)
        : indeterminateOffset % barWidth;

    final bar = StringBuffer();
    for (var i = 0; i < barWidth; i++) {
      bar.write(i < filled ? fillChar : emptyChar);
    }

    final children = <Widget>[];
    if (label != null) {
      children.add(Text('$label ', style: const TextStyle(bold: true)));
    }
    children.add(Text(bar.toString()));
    if (fraction != null) {
      children.add(Text(' ${(fraction! * 100).round()}%'));
    }

    return Row(children: children);
  }
}
