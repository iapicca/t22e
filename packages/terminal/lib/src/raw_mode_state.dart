import 'dart:ffi';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:notifier/notifier.dart' show ValueNotifier;

part 'raw_mode_state.freezed.dart';

/// Saved termios state captured before entering raw mode.
/// TODO RawModeStateData shoulf become RawModeState, current RawModeState be deleted and RawModeInterface be a ValueNotifier<RawModeStat>
@freezed
abstract class RawModeStateData with _$RawModeStateData {
  /// Captures termios buffer and flag field snapshots.
  const factory RawModeStateData(
    Pointer<Uint8> buf,
    int cIflag,
    int cOflag,
    int cCflag,
    int cLflag,
  ) = _RawModeStateData;
}

/// Observable termios state holder.
typedef RawModeState = ValueNotifier<RawModeStateData?>;
