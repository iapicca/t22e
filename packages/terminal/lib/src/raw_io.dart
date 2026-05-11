import 'dart:io';

void enableRawModeIo() {
  stdin.echoMode = false;
  stdin.lineMode = false;
}

void disableRawModeIo() {
  stdin.echoMode = true;
  stdin.lineMode = true;
}
