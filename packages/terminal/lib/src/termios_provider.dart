import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'termios.dart';
import 'termios_linux.dart';
import 'termios_macos.dart';

part 'termios_provider.g.dart';

@riverpod
Termios termios(Ref ref) => switch (Platform.operatingSystem) {
  'macos' => const MacosTermios(),
  'linux' => const LinuxTermios(),
  _ => throw UnsupportedError(
    'Termios is not supported on ${Platform.operatingSystem}',
  ),
};
