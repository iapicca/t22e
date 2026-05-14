import 'dart:io';

/// Enables raw mode using dart:io (echoMode/lineMode).
void enableRawModeIo() {
  stdin.echoMode = false;
  stdin.lineMode = false;
}

/// Disables raw mode using dart:io, restoring echo and line mode.
void disableRawModeIo() {
  stdin.echoMode = true;
  stdin.lineMode = true;
}
