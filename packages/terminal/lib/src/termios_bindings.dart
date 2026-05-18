import 'dart:ffi';

import 'system_io.dart';
import 'platform_service.dart';

/// Abstract interface for libc FFI calls used to manage terminal raw mode.
abstract class TermiosBindings {
  /// Posix tcgetattr: read terminal attributes into [buf].
  int tcGetAttr(int fd, Pointer<Uint8> buf);

  /// Posix tcsetattr: set terminal attributes from [buf].
  int tcSetAttr(int fd, int opt, Pointer<Uint8> buf);

  /// C malloc: allocate [size] bytes.
  Pointer<Uint8> malloc(int size);

  /// C free: release memory allocated by [malloc].
  void free(Pointer<Uint8> ptr);
}

/// Concrete [TermiosBindings] backed by a [DynamicLibrary].
final class TermiosBindingsImpl implements TermiosBindings {
  final DynamicLibrary _libc;

  final int Function(int, Pointer<Uint8>) _tcGetAttr;
  final int Function(int, int, Pointer<Uint8>) _tcSetAttr;

  /// Looks up tcgetattr and tcsetattr from the given [library].
  TermiosBindingsImpl(this._libc)
    : _tcGetAttr = _libc.lookupFunction<
          Int32 Function(Int32, Pointer<Uint8>),
          int Function(int, Pointer<Uint8>)
        >('tcgetattr'),
      _tcSetAttr = _libc.lookupFunction<
          Int32 Function(Int32, Int32, Pointer<Uint8>),
          int Function(int, int, Pointer<Uint8>)
        >('tcsetattr');

  @override
  int tcGetAttr(int fd, Pointer<Uint8> buf) => _tcGetAttr(fd, buf);

  @override
  int tcSetAttr(int fd, int opt, Pointer<Uint8> buf) =>
      _tcSetAttr(fd, opt, buf);

  @override
  Pointer<Uint8> malloc(int size) {
    final fn = _libc.lookupFunction<
        Pointer<Void> Function(IntPtr),
        Pointer<Void> Function(int)
      >('malloc');
    return fn(size).cast();
  }

  @override
  void free(Pointer<Uint8> ptr) {
    final fn = _libc.lookupFunction<
        Void Function(Pointer<Void>),
        void Function(Pointer<Void>)
      >('free');
    fn(ptr.cast());
  }

  /// Uses [PlatformService] to open the platform libc.
  static TermiosBindingsImpl fromPlatformService(SystemIo io) =>
      TermiosBindingsImpl(PlatformService(io: io).library);
}
