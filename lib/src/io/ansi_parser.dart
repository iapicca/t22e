import 'dart:async' show Stream, StreamController;
import 'dart:convert' show utf8;

import 'package:freezed_annotation/freezed_annotation.dart';

import 'ansi_parser_state.dart' show AnsiParserState;
import 'ansi_parser_symbols.dart' show AnsiParserSymbols;
import 'key/key.dart' show Key;

part 'ansi_parser.freezed.dart';

/// Sealed input event produced by [AnsiParser].
@freezed
sealed class InputEvent with _$InputEvent {
  /// A printable or control character.
  const factory InputEvent.char({required String character}) = CharEvent;

  /// A recognized special key.
  const factory InputEvent.key({required Key key}) = KeyEvent;

  /// An unrecognized or partial byte sequence.
  const factory InputEvent.unknown({required List<int> raw}) = UnknownEvent;
}

/// Converts raw terminal bytes into typed [InputEvent]s.
///
/// Covers printable chars, control bytes, arrows, and a CSI/SS3 subset.
/// TODO replace the Stream with inputValueNotifier and listen to it instead.
@internal
class AnsiParser {
  /// Creates a parser with an empty buffer.
  AnsiParser()
  /// TODO top-priority: WHAT THE FUCK! this should be somewhere else! and be initialized and disposed via riverpod!
    : _controller = StreamController<InputEvent>.broadcast(sync: true);

  bool _closed = false;

  final StreamController<InputEvent> _controller;
  final List<int> _buffer = <int>[];
  /// TODO this should be a value notifier 
  AnsiParserState _state = AnsiParserState.ground;

  /// The broadcast stream of parsed input events.
  Stream<InputEvent> get events => _controller.stream;

  /// Feeds more bytes into the parser and emits any complete events.
  void add(List<int> bytes) {
    _buffer.addAll(bytes);
    _process();
  }

  /// Flushes any remaining buffered bytes and closes the event stream.
  /// TODO this should be handled with disposable mixin and be "dispose" rather than `close`
  void close() {
    if (_closed) return;
    _closed = true;
    _flush();
    _controller.close();
  }

  /// Processes the buffer according to the current state.
  void _process() {
    while (_buffer.isNotEmpty) {
      switch (_state) {
        case AnsiParserState.ground:
          if (!_processGround()) return;
        case AnsiParserState.escape:
          if (!_processEscape()) return;
        case AnsiParserState.csi:
          if (!_processCsi()) return;
      }
    }
  }

  /// Handles one byte or run in ground state.
  /// TODO this can be an extension!
  bool _processGround() {
    final byte = _buffer.first;
    if (byte == AnsiParserSymbols.esc) {
      _state = AnsiParserState.escape;
      _buffer.removeAt(0);
      return true;
    }
    if (_isControl(byte)) {
      _emitControl(byte);
      _buffer.removeAt(0);
      return true;
    }
    final length = _utf8Length(byte);
    if (length == 0) {
      // Invalid UTF-8 lead byte; emit it as unknown.
      _controller.add(InputEvent.unknown(raw: <int>[byte]));
      _buffer.removeAt(0);
      return true;
    }
    if (_buffer.length < length) return false;
    final run = _buffer.sublist(0, length);
    final decoded = _decodeUtf8(run);
    if (decoded != null) {
      _controller.add(InputEvent.char(character: decoded));
    } else {
      _controller.add(InputEvent.unknown(raw: List<int>.from(run)));
    }
    _buffer.removeRange(0, run.length);
    return true;
  }

  /// Handles the byte following ESC.
    /// TODO this can be an extension!
  bool _processEscape() {
    if (_buffer.isEmpty) return false;
    final byte = _buffer.first;
    if (byte == AnsiParserSymbols.csiIntroducer) {
      _state = AnsiParserState.csi;
      _buffer.removeAt(0);
      return true;
    }
    if (byte == AnsiParserSymbols.ss3Introducer) {
      // SS3 sequences are ESC O <final>; need one more byte.
      if (_buffer.length < 2) return false;
      final finalByte = _buffer[1];
      final key = _ss3Key(finalByte);
      if (key != null) {
        _controller.add(InputEvent.key(key: key));
      } else {
        _controller.add(
          InputEvent.unknown(raw: <int>[AnsiParserSymbols.esc, AnsiParserSymbols.ss3Introducer, finalByte]),
        );
      }
      _buffer.removeRange(0, 2);
      _state = AnsiParserState.ground;
      return true;
    }
    // Lone ESC followed by a normal byte: treat as Alt+key or unknown.
    _controller.add(InputEvent.unknown(raw: <int>[AnsiParserSymbols.esc, byte]));
    _buffer.removeAt(0);
    _state = AnsiParserState.ground;
    return true;
  }

  /// Handles a CSI sequence.
/// TODO this can be an extension!
  bool _processCsi() {
    final start = 0;
    var i = start;
    while (i < _buffer.length) {
      final byte = _buffer[i];
      if (_isCsiParam(byte) || _isCsiIntermediate(byte)) {
        i++;
        continue;
      }
      if (_isCsiFinal(byte)) {
        final params = _buffer.sublist(start, i);
        final key = _csiKey(params, byte);
        if (key != null) {
          _controller.add(InputEvent.key(key: key));
        } else {
          _controller.add(
            InputEvent.unknown(
              raw: <int>[AnsiParserSymbols.esc, AnsiParserSymbols.csiIntroducer, ...params, byte],
            ),
          );
        }
        _buffer.removeRange(0, i + 1);
        _state = AnsiParserState.ground;
        return true;
      }
      // Invalid byte inside CSI: drop the introducer and return to ground.
      _controller.add(
        InputEvent.unknown(
          raw: <int>[AnsiParserSymbols.esc, AnsiParserSymbols.csiIntroducer, ..._buffer.sublist(start, i + 1)],
        ),
      );
      _buffer.removeRange(0, i + 1);
      _state = AnsiParserState.ground;
      return true;
    }
    return false;
  }

  /// Flushes remaining buffered bytes as events.
    /// TODO this can be an extension!
  void _flush() {
    switch (_state) {
      case AnsiParserState.ground:
        while (_buffer.isNotEmpty) {
          if (!_processGround()) break;
        }
      case AnsiParserState.escape:
        // A trailing lone ESC is treated as the Escape key.
        if (_buffer.isEmpty) {
          _controller.add(const InputEvent.key(key: Key.escape));
        } else {
          _controller.add(InputEvent.unknown(raw: <int>[AnsiParserSymbols.esc, _buffer.first]));
          _buffer.removeAt(0);
          _state = AnsiParserState.ground;
          while (_buffer.isNotEmpty) {
            if (!_processGround()) break;
          }
        }
      case AnsiParserState.csi:
        _controller.add(
          InputEvent.unknown(
            raw: <int>[AnsiParserSymbols.esc, AnsiParserSymbols.csiIntroducer, ..._buffer],
          ),
        );
        _buffer.clear();
        _state = AnsiParserState.ground;
    }
  }

  /// Emits a control byte as a key or character event.
      /// TODO this can be an extension!
  void _emitControl(int byte) {
    final key = _controlKey(byte);
    if (key != null) {
      _controller.add(InputEvent.key(key: key));
    } else {
      _controller.add(InputEvent.char(character: String.fromCharCode(byte)));
    }
  }

  /// Maps a control byte to a logical key, if recognized.
    /// TODO this has nothing to do with AnsiParser and should be a factory of Key
    /// returnin a non-null Key and `_ =>` return "Key.unknown"
    /// finally bytes should be mapped in a final class as `static const int` 
  static Key? _controlKey(int byte) {
    return switch (byte) {
      AnsiParserSymbols.ctrlC => Key.ctrlC,
      AnsiParserSymbols.ctrlD => Key.ctrlD,
      AnsiParserSymbols.tab => Key.tab,
      AnsiParserSymbols.enter => Key.enter,
      AnsiParserSymbols.del => Key.backspace,
      _ => null,
    };
  }

  /// Maps an SS3 final byte to a logical key; unmapped in this phase.
 /// TODO this has nothing to do with AnsiParser and should be a factory of Key
    /// returnin  "Key.unknown"
  static Key? _ss3Key(int byte) => null;

  /// Maps a completed CSI sequence to a logical key.
   /// TODO this has nothing to do with AnsiParser and should be a factory of Key
    /// returnin a non-null Key and `_ =>` return "Key.unknown"
    /// finally bytes should be mapped in a final class as `static const int` 
  static Key? _csiKey(List<int> params, int finalByte) {
    final paramString = String.fromCharCodes(params);
    return switch (finalByte) {
      AnsiParserSymbols.csiUp => Key.up,
      AnsiParserSymbols.csiDown => Key.down,
      AnsiParserSymbols.csiRight => Key.right,
      AnsiParserSymbols.csiLeft => Key.left,
      AnsiParserSymbols.csiHome => Key.home,
      AnsiParserSymbols.csiEnd => Key.end,
      AnsiParserSymbols.csiTilde => switch (paramString) {
          '1' => Key.home,
          '3' => Key.delete,
          '4' => Key.end,
          '5' => Key.pageUp,
          '6' => Key.pageDown,
          _ => null,
        },
      _ => null,
    };
  }

  /// Decodes a UTF-8 byte run to a single character string.
  /// TODO this has nothing to do with AnsiParser and should be in a separate file
    /// utf8.decode should be "imported" through riverpod
  static String? _decodeUtf8(List<int> bytes) {
    try {
      return utf8.decode(bytes, allowMalformed: false);
    } on FormatException {
      return null;
    }
  }

  /// Bytes in the UTF-8 code point starting with [byte], or 0 if invalid lead.
  /// TODO this has nothing to do with AnsiParser and should be in a separate file
    /// finally bytes should be mapped in a final class as `static const int` 
  static int _utf8Length(int byte) {
    if (byte < AnsiParserSymbols.utf8AsciiMax) return 1;
    if ((byte & AnsiParserSymbols.utf8TwoByteMask) ==
        AnsiParserSymbols.utf8TwoByteLead) {
      return 2;
    }
    if ((byte & AnsiParserSymbols.utf8ThreeByteMask) ==
        AnsiParserSymbols.utf8ThreeByteLead) {
      return 3;
    }
    if ((byte & AnsiParserSymbols.utf8FourByteMask) ==
        AnsiParserSymbols.utf8FourByteLead) {
      return 4;
    }
    return 0;
  }

  /// Whether [byte] is a control byte that should not be decoded as UTF-8.
    /// TODO this has nothing to do with AnsiParser and should be in a separate file
    /// finally bytes should be mapped in a final class as `static const int` 
  static bool _isControl(int byte) => byte < 0x20 || byte == 0x7F;

  /// Whether [byte] is a CSI parameter byte.
    /// TODO this has nothing to do with AnsiParser and should be in a separate file
    /// finally bytes should be mapped in a final class as `static const int` 
  static bool _isCsiParam(int byte) => byte >= 0x30 && byte <= 0x3F;

  /// Whether [byte] is a CSI intermediate byte.
    /// TODO this has nothing to do with AnsiParser and should be in a separate file
    /// finally bytes should be mapped in a final class as `static const int` 
  static bool _isCsiIntermediate(int byte) => byte >= 0x20 && byte <= 0x2F;

/// Whether [byte] is a CSI final byte.
     /// TODO this has nothing to do with AnsiParser and should be in a separate file
     /// finally bytes should be mapped in a final class as `static const int` 
  static bool _isCsiFinal(int byte) => byte >= 0x40 && byte <= 0x7E;
}
