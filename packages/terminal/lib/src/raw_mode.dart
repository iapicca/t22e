import 'dart:ffi';

import 'package:meta/meta.dart';
import 'package:notifier/notifier.dart' show Disposable, InitMixin;

import 'extensions.dart';
import 'libc_signatures.dart';
import 'raw_mode_state.dart';
import 'pointer_extensions.dart';
import 'termios.dart';
import 'symbols_ffi.dart';

/// Abstract base for raw mode lifecycle management.
/// TODO THIS SHOULD BE A VALUE NOTIFIER
abstract class RawModeInterface with InitMixin, Disposable {
  RawModeState get state;
}

/// Concrete [RawModeInterface] implementation using libc FFI.
///
/// Consumers should read [rawModeProvider] instead of instantiating directly.
/// This class is exposed under `src/` for advanced use at your own risk.
@internal
final class RawMode extends RawModeInterface {
  /// TODO this should be injected with riverpod
  late final DynamicLibrary _library = openLibc();
  /// TODO this should be initialized with init!
  late final RawModeState _state = RawModeState(null);

  RawMode();

  @override
  /// TODO this will be unnecessary when RawModeInterface will be a ValueNotifier
  RawModeState get state => _state;

  @override
  void init({String? message, bool throwIfExists = false}) {
    super.init(message: message, throwIfExists: throwIfExists);
    final tcGetAttr = _library.lookupFunction<NativeTcGetAttr, TcGetAttr>(
      SymbolsFFI.tcGetAttrName,
    );
    final tcSetAttr = _library.lookupFunction<NativeTcSetAttr, TcSetAttr>(
      SymbolsFFI.tcSetAttrName,
    );
    final malloc = _library.lookupFunction<NativeMalloc, Malloc>(
      SymbolsFFI.mallocName,
    );
    /// TODO I don't like calling malloc directly!
    final buffer = malloc(Termios.termiosStructSize).cast<Uint8>();
    final tcGetAttrResult = tcGetAttr(Termios.stdinFd, buffer);
    if (tcGetAttrResult != 0) {
      _library.freePointer(buffer.cast());
      throw StateError('tcgetattr failed (stdin is not a TTY?)');
    }

    final savedState = RawModeStateData(
      buffer,
      buffer.read32(Termios.termiosOffsetIFlag),
      buffer.read32(Termios.termiosOffsetOFlag),
      buffer.read32(Termios.termiosOffsetCFlag),
      buffer.read32(Termios.termiosOffsetLFlag),
    );

    final modifiedLFlag =
        savedState.cLflag &
        ~(Termios.termiosEcho |
            Termios.termiosICanon |
            Termios.termiosISig |
            Termios.termiosIExten);
    buffer.write32(Termios.termiosOffsetLFlag, modifiedLFlag);
    buffer.write8(Termios.termiosOffsetCCMin, Termios.termiosVminRaw);
    buffer.write8(Termios.termiosOffsetCCTime, Termios.termiosVtimeRaw);

    final tcSetAttrResult = tcSetAttr(Termios.stdinFd, Termios.tcsaNow, buffer);
    if (tcSetAttrResult != 0) {
      _library.freePointer(buffer.cast());
      throw StateError('tcsetattr failed');
    }

    _state.value = savedState;
  }

  @override
  void dispose({String? message}) {
    super.dispose(message: message);
    final savedState = _state.value;
    if (savedState != null) {
      final tcSetAttr = _library.lookupFunction<NativeTcSetAttr, TcSetAttr>(
        SymbolsFFI.tcSetAttrName,
      );
      savedState.buf.write32(Termios.termiosOffsetIFlag, savedState.cIflag);
      savedState.buf.write32(Termios.termiosOffsetOFlag, savedState.cOflag);
      savedState.buf.write32(Termios.termiosOffsetCFlag, savedState.cCflag);
      savedState.buf.write32(Termios.termiosOffsetLFlag, savedState.cLflag);
      tcSetAttr(Termios.stdinFd, Termios.tcsaNow, savedState.buf);
      _library.freePointer(savedState.buf.cast());
    }
    _state.dispose();
  }
}
