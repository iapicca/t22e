import 'dart:io';

/// Enables raw mode via Dart's stdin (echo off, line buffering off)
void enableRawModeIo() {
  stdin.echoMode = false;
  stdin.lineMode = false;
}

/// Disables raw mode, restoring echo and line buffering
void disableRawModeIo() {
  stdin.echoMode = true;
  stdin.lineMode = true;
}
