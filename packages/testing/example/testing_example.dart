import 'package:testing/testing.dart';

void main() {
  final vt = VirtualTerminal();
  vt.write('Hello, World!');
  print(vt.plainText());
}
