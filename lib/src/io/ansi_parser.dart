import 'dart:async' show Stream, StreamController;

import 'package:freezed_annotation/freezed_annotation.dart';

import '../notifier/disposable.dart' show Disposable;
import 'ansi_parser_state.dart' show AnsiParserState;
import 'ansi_parser_symbols.dart' show AnsiParserSymbols;
import 'key/key.dart' show Key;
import 'terminal_bytes.dart'
    show
        isControlByte,
        isCsiFinalByte,
        isCsiIntermediateByte,
        isCsiParamByte;
import 'utf8_decoder.dart' show Utf8Decoder, utf8Length;

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
class AnsiParser with Disposable {
  /// Creates a parser with an empty buffer.
  ///
  /// The [decodeUtf8] seam is injected via [utf8DecoderProvider]; pass a
  /// fake in tests.
  AnsiParser({required this._decodeUtf8})
  /// TODO top-priority: WHAT THE FUCK! this should be somewhere else! and be initialized and disposed via riverpod!
    : _controller = StreamController<InputEvent>.broadcast(sync: true);

  final StreamController<InputEvent> _controller;
  final List<int> _buffer = <int>[];
  final Utf8Decoder _decodeUtf8;
  /// TODO this should be a value notifier 
  AnsiParserState _state = AnsiParserState.ground;

  /// The broadcast stream of parsed input events.
  Stream<InputEvent> get events => _controller.stream;

  /// Feeds more bytes into the parser and emits any complete events.
  void add(List<int> bytes) {
    check(message: 'Cannot add to a disposed AnsiParser');
    _buffer.addAll(bytes);
    _process();
  }

  /// Flushes remaining buffered bytes and closes the event stream.
  @mustCallSuper
  @override
  void dispose({String? message}) {
    if (isDisposed) return;
    super.dispose(message: message);
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
    if (isControlByte(byte)) {
      _emitControl(byte);
      _buffer.removeAt(0);
      return true;
    }
    final length = utf8Length(byte);
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
      if (isCsiParamByte(byte) || isCsiIntermediateByte(byte)) {
        i++;
        continue;
      }
      if (isCsiFinalByte(byte)) {
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
}
