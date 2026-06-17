import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:terminal/terminal.dart';

import 'chat_app.dart';
import 'chat_model.dart';

part 'chat_app_provider.g.dart';

@riverpod
ChatApp chatApp(Ref ref) {
  final io = ref.read(systemIoProvider);
  final width = io.context.value.width;
  final height = io.context.value.height;
  return ChatApp(ChatModel(terminalWidth: width, terminalHeight: height));
}
