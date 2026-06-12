import 'package:notifier/notifier.dart' show InitMixin, ValueNotifier;
import 'package:protocol/protocol.dart' show Defaults;

import 'sequence_data.dart';
import 'vt_state.dart';

/// VT500-compatible byte-level state machine engine.
class Vt500Engine extends ValueNotifier<VtState> with InitMixin {
  final _params = <int>[];
  final _intermediates = <int>[];
  final _oscBuffer = StringBuffer();
  final _dcsBuffer = StringBuffer();
  int _dcsFinalByte = 0;
  final _dcsParams = <int>[];
  final _dcsIntermediates = <int>[];
  bool _oscWaitingSt = false;
  bool _dcsWaitingSt = false;

  Vt500Engine() : super(VtState.ground);

  /// Feeds a single byte to the state machine, returning parsed data or null.
  SequenceData? advance(int b) {
    final byte = b & 0xFF;

    return switch (value) {
      VtState.ground => _onGround(byte, this),
      VtState.escape => _onEscape(byte, this),
      VtState.escapeIntermediate => _onEscapeIntermediate(byte, this),
      VtState.csiEntry => _onCsiEntry(byte, this),
      VtState.csiParam => _onCsiParam(byte, this),
      VtState.csiIntermediate => _onCsiIntermediate(byte, this),
      VtState.csiIgnore => _onCsiIgnore(byte, this),
      VtState.oscString => _onOscString(byte, this),
      VtState.dcsEntry => _onDcsEntry(byte, this),
      VtState.dcsParam => _onDcsParam(byte, this),
      VtState.dcsIntermediate => _onDcsIntermediate(byte, this),
      VtState.dcsIgnore => _onDcsIgnore(byte, this),
      VtState.dcsPassthrough => _onDcsPassthrough(byte, this),
    };
  }

  /// Feeds a list of bytes and collects all parsed sequence data.
  List<SequenceData> advanceAll(List<int> bytes) {
    final results = <SequenceData>[];
    for (final byte in bytes) {
      final result = advance(byte);
      if (result != null) results.add(result);
    }
    return results;
  }

  /// Resets the engine to its initial state.
  void reset() {
    value = VtState.ground;
    _params.clear();
    _intermediates.clear();
    _oscBuffer.clear();
    _dcsBuffer.clear();
    _dcsParams.clear();
    _dcsIntermediates.clear();
    _dcsFinalByte = 0;
  }
}

SequenceData? _onGround(int byte, Vt500Engine e) {
  return switch (byte) {
    Defaults.escapeByte => _transition(e, VtState.escape),
    Defaults.csiIntroducerByte => _csiEntryTransition(e),
    Defaults.oscIntroducerByte => _oscEntryTransition(e),
    Defaults.dcsIntroducerByte => _dcsEntryTransition(e),
    >= Defaults.byteRangePrintableLow && <= Defaults.byteRangePrintableHigh =>
      SequenceData.char(byte),
    >= Defaults.byteRangeC1Low && <= Defaults.byteRangeC1High => null,
    >= Defaults.byteRangeLowest && <= Defaults.byteRangeControlHigh2
        when byte != Defaults.escapeByte =>
      null,
    _ => null,
  };
}

SequenceData? _onEscape(int byte, Vt500Engine e) {
  return switch (byte) {
    Defaults.csiEntryByte => _csiEntryTransition(e),
    Defaults.oscEntryByte => _oscEntryTransition(e),
    Defaults.dcsEntryByte => _dcsEntryTransition(e),
    Defaults.ss3Byte ||
    >= Defaults.byteRangeGraphicLow && <= Defaults.byteRangeGraphicHigh =>
      _addIntermediateAndTransition(e, byte, VtState.escapeIntermediate),
    >= Defaults.byteRangeParamLow && <= Defaults.byteRangeUpperHigh =>
      _emitEscAndGround(e, byte),
    Defaults.escapeByte => _clearIntermediates(e),
    Defaults.bellByte || Defaults.stringTerminatorByte => _resetToGround(e),
    _ => _resetToGround(e),
  };
}

SequenceData? _onEscapeIntermediate(int byte, Vt500Engine e) {
  if (byte >= Defaults.byteRangeGraphicLow &&
      byte <= Defaults.byteRangeGraphicHigh) {
    e._intermediates.add(byte);
    return null;
  }
  if (byte >= Defaults.byteRangeParamLow &&
      byte <= Defaults.byteRangeUpperHigh) {
    return _emitEscAndGround(e, byte);
  }
  if (byte == Defaults.escapeByte) {
    e.value = VtState.escape;
    e._intermediates.clear();
    return null;
  }
  e.value = VtState.ground;
  e._intermediates.clear();
  return null;
}

SequenceData? _onCsiEntry(int byte, Vt500Engine e) {
  if (byte >= Defaults.byteRangeParamLow &&
      byte <= Defaults.byteRangeParamHigh) {
    if (byte >= Defaults.byteRangeDigitLow &&
        byte <= Defaults.byteRangeDigitHigh) {
      e._params.add(byte - Defaults.byteRangeDigitLow);
    } else if (byte == Defaults.semicolonByte) {
      e._params.add(0);
    } else if (byte >= Defaults.intermediatePrefixByte &&
        byte <= Defaults.byteRangeParamHigh) {
      e._intermediates.add(byte);
    }
    e.value = VtState.csiParam;
    return null;
  }
  if (byte >= Defaults.byteRangeGraphicLow &&
      byte <= Defaults.byteRangeGraphicHigh) {
    e._intermediates.add(byte);
    e.value = VtState.csiIntermediate;
    return null;
  }
  if (byte >= Defaults.byteRangeUpperLow &&
      byte <= Defaults.byteRangeUpperHigh) {
    return _emitCsiAndGround(e, byte);
  }
  if (byte >= Defaults.byteRangeLowest &&
      byte <= Defaults.byteRangeControlHigh2 &&
      byte != Defaults.escapeByte) {
    return null;
  }
  if (byte == Defaults.escapeByte) {
    e.value = VtState.escape;
    e._params.clear();
    e._intermediates.clear();
    return null;
  }
  e.value = VtState.csiIgnore;
  e._params.clear();
  e._intermediates.clear();
  return null;
}

SequenceData? _onCsiParam(int byte, Vt500Engine e) {
  if (byte >= Defaults.byteRangeDigitLow &&
      byte <= Defaults.byteRangeDigitHigh) {
    final last = e._params.isEmpty ? 0 : e._params.removeLast();
    e._params.add(last * 10 + (byte - Defaults.byteRangeDigitLow));
    return null;
  }
  if (byte == Defaults.semicolonByte) {
    e._params.add(0);
    return null;
  }
  if (byte >= Defaults.intermediatePrefixByte &&
      byte <= Defaults.byteRangeParamHigh) {
    e._intermediates.add(byte);
    e.value = VtState.csiParam;
    return null;
  }
  if (byte >= Defaults.byteRangeGraphicLow &&
      byte <= Defaults.byteRangeGraphicHigh) {
    e._intermediates.add(byte);
    e.value = VtState.csiIntermediate;
    return null;
  }
  if (byte >= Defaults.byteRangeUpperLow &&
      byte <= Defaults.byteRangeUpperHigh) {
    return _emitCsiAndGround(e, byte);
  }
  if (byte == Defaults.escapeByte) {
    e.value = VtState.escape;
    e._params.clear();
    e._intermediates.clear();
    return null;
  }
  e.value = VtState.csiIgnore;
  e._params.clear();
  e._intermediates.clear();
  return null;
}

SequenceData? _onCsiIntermediate(int byte, Vt500Engine e) {
  if (byte >= Defaults.byteRangeGraphicLow &&
      byte <= Defaults.byteRangeGraphicHigh) {
    e._intermediates.add(byte);
    return null;
  }
  if (byte >= Defaults.byteRangeUpperLow &&
      byte <= Defaults.byteRangeUpperHigh) {
    return _emitCsiAndGround(e, byte);
  }
  if (byte == Defaults.escapeByte) {
    e.value = VtState.escape;
    e._params.clear();
    e._intermediates.clear();
    return null;
  }
  e.value = VtState.ground;
  e._params.clear();
  e._intermediates.clear();
  return null;
}

SequenceData? _onCsiIgnore(int byte, Vt500Engine e) {
  if (byte >= Defaults.byteRangeUpperLow &&
      byte <= Defaults.byteRangeUpperHigh) {
    e.value = VtState.ground;
    return null;
  }
  if (byte == Defaults.escapeByte) {
    e.value = VtState.escape;
    return null;
  }
  return null;
}

SequenceData? _onOscString(int byte, Vt500Engine e) {
  if (e._oscWaitingSt) {
    e._oscWaitingSt = false;
    if (byte == Defaults.dcsStByte) {
      e.value = VtState.ground;
      final content = e._oscBuffer.toString();
      e._oscBuffer.clear();
      return SequenceData.osc(content);
    }
    e._oscBuffer.writeCharCode(Defaults.escapeByte);
    if (byte >= Defaults.byteRangePrintableLow &&
        byte <= Defaults.codepointDel) {
      e._oscBuffer.writeCharCode(byte);
    }
    return null;
  }
  if (byte == Defaults.escapeByte) {
    e._oscWaitingSt = true;
    return null;
  }
  if (byte == Defaults.bellByte || byte == Defaults.stringTerminatorByte) {
    e.value = VtState.ground;
    final content = e._oscBuffer.toString();
    e._oscBuffer.clear();
    return SequenceData.osc(content);
  }
  if (byte >= Defaults.byteRangePrintableLow && byte <= Defaults.codepointDel) {
    e._oscBuffer.writeCharCode(byte);
    return null;
  }
  return null;
}

SequenceData? _onDcsEntry(int byte, Vt500Engine e) {
  if (byte >= Defaults.byteRangeParamLow &&
      byte <= Defaults.byteRangeParamHigh) {
    if (byte >= Defaults.byteRangeDigitLow &&
        byte <= Defaults.byteRangeDigitHigh) {
      e._dcsParams.add(byte - Defaults.byteRangeDigitLow);
    }
    e.value = VtState.dcsParam;
    return null;
  }
  if (byte >= Defaults.byteRangeGraphicLow &&
      byte <= Defaults.byteRangeGraphicHigh) {
    e._dcsIntermediates.add(byte);
    e.value = VtState.dcsIntermediate;
    return null;
  }
  if (byte >= Defaults.byteRangeUpperLow &&
      byte <= Defaults.byteRangeUpperHigh) {
    e._dcsFinalByte = byte;
    e.value = VtState.dcsPassthrough;
    return null;
  }
  e.value = VtState.dcsIgnore;
  return null;
}

SequenceData? _onDcsParam(int byte, Vt500Engine e) {
  if (byte >= Defaults.byteRangeDigitLow &&
      byte <= Defaults.byteRangeDigitHigh) {
    final last = e._dcsParams.isEmpty ? 0 : e._dcsParams.removeLast();
    e._dcsParams.add(last * 10 + (byte - Defaults.byteRangeDigitLow));
    return null;
  }
  if (byte == Defaults.semicolonByte) {
    e._dcsParams.add(0);
    return null;
  }
  if (byte >= Defaults.byteRangeGraphicLow &&
      byte <= Defaults.byteRangeGraphicHigh) {
    e._dcsIntermediates.add(byte);
    e.value = VtState.dcsIntermediate;
    return null;
  }
  if (byte >= Defaults.byteRangeUpperLow &&
      byte <= Defaults.byteRangeUpperHigh) {
    e._dcsFinalByte = byte;
    e.value = VtState.dcsPassthrough;
    return null;
  }
  e.value = VtState.dcsIgnore;
  return null;
}

SequenceData? _onDcsIntermediate(int byte, Vt500Engine e) {
  if (byte >= Defaults.byteRangeGraphicLow &&
      byte <= Defaults.byteRangeGraphicHigh) {
    e._dcsIntermediates.add(byte);
    return null;
  }
  if (byte >= Defaults.byteRangeUpperLow &&
      byte <= Defaults.byteRangeUpperHigh) {
    e._dcsFinalByte = byte;
    e.value = VtState.dcsPassthrough;
    return null;
  }
  e.value = VtState.dcsIgnore;
  return null;
}

SequenceData? _onDcsIgnore(int byte, Vt500Engine e) {
  if (byte == Defaults.bellByte || byte == Defaults.stringTerminatorByte) {
    e.value = VtState.ground;
    return null;
  }
  if (byte == Defaults.escapeByte) {
    return _onGround(byte, e);
  }
  return null;
}

SequenceData? _onDcsPassthrough(int byte, Vt500Engine e) {
  if (e._dcsWaitingSt) {
    e._dcsWaitingSt = false;
    if (byte == Defaults.dcsStByte) {
      e.value = VtState.ground;
      final data = e._dcsBuffer.toString();
      e._dcsBuffer.clear();
      if (data.isEmpty) return null;
      return SequenceData.dcs(
        params: List.unmodifiable(e._dcsParams),
        intermediates: List.unmodifiable(e._dcsIntermediates),
        finalByte: e._dcsFinalByte,
        data: data,
      );
    }
    return null;
  }
  if (byte == Defaults.bellByte || byte == Defaults.stringTerminatorByte) {
    e.value = VtState.ground;
    final data = e._dcsBuffer.toString();
    e._dcsBuffer.clear();
    if (data.isEmpty) return null;
    return SequenceData.dcs(
      params: List.unmodifiable(e._dcsParams),
      intermediates: List.unmodifiable(e._dcsIntermediates),
      finalByte: e._dcsFinalByte,
      data: data,
    );
  }
  if (byte == Defaults.escapeByte) {
    e._dcsWaitingSt = true;
    return null;
  }
  e._dcsBuffer.writeCharCode(byte);
  return null;
}

SequenceData? _transition(Vt500Engine e, VtState state) {
  e.value = state;
  return null;
}

SequenceData? _csiEntryTransition(Vt500Engine e) {
  e.value = VtState.csiEntry;
  e._params.clear();
  e._intermediates.clear();
  return null;
}

SequenceData? _oscEntryTransition(Vt500Engine e) {
  e.value = VtState.oscString;
  e._oscBuffer.clear();
  return null;
}

SequenceData? _dcsEntryTransition(Vt500Engine e) {
  e.value = VtState.dcsEntry;
  e._dcsParams.clear();
  e._dcsIntermediates.clear();
  e._dcsBuffer.clear();
  return null;
}

SequenceData? _addIntermediateAndTransition(
  Vt500Engine e,
  int byte,
  VtState state,
) {
  e._intermediates.add(byte);
  e.value = state;
  return null;
}

SequenceData? _emitEscAndGround(Vt500Engine e, int byte) {
  e.value = VtState.ground;
  final data = SequenceData.esc(
    intermediates: List.unmodifiable(e._intermediates),
    finalByte: byte,
  );
  e._intermediates.clear();
  return data;
}

SequenceData? _emitCsiAndGround(Vt500Engine e, int byte) {
  e.value = VtState.ground;
  final data = SequenceData.csi(
    params: List.unmodifiable(e._params),
    intermediates: List.unmodifiable(e._intermediates),
    finalByte: byte,
  );
  e._params.clear();
  e._intermediates.clear();
  return data;
}

SequenceData? _clearIntermediates(Vt500Engine e) {
  e._intermediates.clear();
  return null;
}

SequenceData? _resetToGround(Vt500Engine e) {
  e.value = VtState.ground;
  e._intermediates.clear();
  return null;
}
