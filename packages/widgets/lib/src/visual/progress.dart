import '../model.dart' show Model;
import '../msg.dart' show Msg, ProgressTickMsg;
import '../cmd.dart' show Cmd, TickCmd;
import 'package:protocol/protocol.dart' show Defaults;
import '../widget.dart' show Widget;
import '../basic/text.dart' show Text;
import '../container/row.dart' show Row;
import 'package:core/core.dart' show TextStyle;

/// A progress bar with determinate (fraction) and indeterminate (animated) modes.
class ProgressBar extends Model<ProgressBar> {
  /// Completion fraction (0.0 to 1.0), or null for indeterminate.
  final double? fraction;
  /// Optional label text.
  final String? label;
  /// Width of the bar in cells.
  final int barWidth;
  /// Character used for filled segments.
  final String fillChar;
  /// Character used for empty segments.
  final String emptyChar;
  /// Animation interval for indeterminate mode.
  final Duration animInterval;
  /// Current scroll offset for indeterminate animation.
  final int indeterminateOffset;

  const ProgressBar({
    this.fraction,
    this.label,
    this.barWidth = Defaults.defaultProgressBarWidth,
    this.fillChar = Defaults.charFullBlock,
    this.emptyChar = Defaults.charLightShade,
    this.animInterval = Defaults.progressAnimInterval,
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

  /// Returns a copy with overridden fields.
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
    final barString = fraction != null
        ? _determinateBar(fraction!)
        : _indeterminateBar(indeterminateOffset);

    final children = <Widget>[Text(barString)];
    if (label != null) {
      children.add(Text(' $label'));
    }
    return Row(children: children);
  }

  /// Builds a determinate bar string based on fraction.
  String _determinateBar(double frac) {
    final filled = (frac.clamp(0.0, 1.0) * barWidth).round();
    return fillChar * filled + emptyChar * (barWidth - filled);
  }

  /// Builds an indeterminate scrolling bar.
  String _indeterminateBar(int offset) {
    final pos = offset % (barWidth + 3);
    final buf = StringBuffer();
    for (var i = 0; i < barWidth; i++) {
      if (i >= pos && i < pos + 3) {
        buf.write(fillChar);
      } else {
        buf.write(emptyChar);
      }
    }
    return buf.toString();
  }
}
