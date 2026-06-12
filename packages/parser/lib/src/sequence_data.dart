import 'package:freezed_annotation/freezed_annotation.dart';

import 'events.dart';

part 'sequence_data.freezed.dart';

/// Parser function that converts sequence data into an event.
typedef Parser = Event? Function(SequenceData);

/// Byte-level parsed sequence data emitted by the VT500 state machine.
@freezed
sealed class SequenceData with _$SequenceData {
  const factory SequenceData.char(int codepoint) = CharData;
  const factory SequenceData.csi({
    required List<int> params,
    required List<int> intermediates,
    required int finalByte,
  }) = CsiSequenceData;
  const factory SequenceData.esc({
    required List<int> intermediates,
    required int finalByte,
  }) = EscSequenceData;
  const factory SequenceData.osc(String content) = OscSequenceData;
  const factory SequenceData.dcs({
    required List<int> params,
    required List<int> intermediates,
    required int finalByte,
    String? data,
  }) = DcsSequenceData;
}
