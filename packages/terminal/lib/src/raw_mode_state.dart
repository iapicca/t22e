import 'dart:ffi';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'raw_mode_state.freezed.dart';

/// Saved termios state captured before entering raw mode.
@freezed
abstract class RawModeState with _$RawModeState {
  /// Captures termios buffer and flag field snapshots.
  const factory RawModeState(
    Pointer<Uint8> buf,
    int cIflag,
    int cOflag,
    int cCflag,
    int cLflag,
  ) = _RawModeState;
}
