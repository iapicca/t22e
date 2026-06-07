import 'dart:ffi';

import 'package:meta/meta.dart';
import 'package:notifier/notifier.dart' show Disposable, InitMixin;
import 'package:protocol/protocol.dart' show Defaults;

import 'extensions.dart';
import 'libc_signatures.dart';
import 'raw_mode_state.dart';
import 'pointer_extensions.dart';
import 'symbols_ffi.dart';

/// Abstract base for raw mode lifecycle management.
abstract class RawModeInterface with InitMixin, Disposable {
  RawModeState get state;
}

/// Concrete [RawModeInterface] implementation using libc FFI.
///
/// Consumers should read [rawModeProvider] instead of instantiating directly.
/// This class is exposed under `src/` for advanced use at your own risk.
@internal
final class RawMode extends RawModeInterface {
  late final DynamicLibrary _library = openLibc();
  late final RawModeState _state = RawModeState(null);

  RawMode();

  @override
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

    final buffer = malloc(Defaults.termiosStructSize).cast<Uint8>();
    final tcGetAttrResult = tcGetAttr(Defaults.stdinFd, buffer);
    if (tcGetAttrResult != 0) {
      _library.freePointer(buffer.cast());
      throw StateError('tcgetattr failed (stdin is not a TTY?)');
    }

    final savedState = RawModeStateData(
      buffer,
      buffer.read32(Defaults.termiosOffsetIFlag),
      buffer.read32(Defaults.termiosOffsetOFlag),
      buffer.read32(Defaults.termiosOffsetCFlag),
      buffer.read32(Defaults.termiosOffsetLFlag),
    );

    final modifiedLFlag =
        savedState.cLflag &
        ~(Defaults.termiosEcho |
            Defaults.termiosICanon |
            Defaults.termiosISig |
            Defaults.termiosIExten);
    buffer.write32(Defaults.termiosOffsetLFlag, modifiedLFlag);
    buffer.write8(Defaults.termiosOffsetCCMin, Defaults.termiosVminRaw);
    buffer.write8(Defaults.termiosOffsetCCTime, Defaults.termiosVtimeRaw);

    final tcSetAttrResult = tcSetAttr(
      Defaults.stdinFd,
      Defaults.tcsaNow,
      buffer,
    );
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
      savedState.buf.write32(Defaults.termiosOffsetIFlag, savedState.cIflag);
      savedState.buf.write32(Defaults.termiosOffsetOFlag, savedState.cOflag);
      savedState.buf.write32(Defaults.termiosOffsetCFlag, savedState.cCflag);
      savedState.buf.write32(Defaults.termiosOffsetLFlag, savedState.cLflag);
      tcSetAttr(Defaults.stdinFd, Defaults.tcsaNow, savedState.buf);
      _library.freePointer(savedState.buf.cast());
    }
    _state.dispose();
  }
}
