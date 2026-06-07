import 'dart:ffi';

import 'package:meta/meta.dart';

/// Native C signature for libc `tcgetattr`.
@internal
typedef NativeTcGetAttr = Int32 Function(
  Int32 fileDescriptor,
  Pointer<Uint8> termiosBuffer,
);

/// Dart callable signature for libc `tcgetattr`.
@internal
typedef TcGetAttr = int Function(
  int fileDescriptor,
  Pointer<Uint8> termiosBuffer,
);

/// Native C signature for libc `tcsetattr`.
@internal
typedef NativeTcSetAttr = Int32 Function(
  Int32 fileDescriptor,
  Int32 optionalActions,
  Pointer<Uint8> termiosBuffer,
);

/// Dart callable signature for libc `tcsetattr`.
@internal
typedef TcSetAttr = int Function(
  int fileDescriptor,
  int optionalActions,
  Pointer<Uint8> termiosBuffer,
);

/// Native C signature for libc `malloc`.
@internal
typedef NativeMalloc = Pointer<Void> Function(IntPtr size);

/// Dart callable signature for libc `malloc`.
@internal
typedef Malloc = Pointer<Void> Function(int size);

/// Native C signature for libc `free`.
@internal
typedef NativeFree = Void Function(Pointer<Void> pointer);

/// Dart callable signature for libc `free`.
@internal
typedef Free = void Function(Pointer<Void> pointer);
