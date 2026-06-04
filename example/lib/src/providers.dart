import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'chat_model.dart';

part 'providers.g.dart';

/// Provider for the chat model state.
@riverpod
class ChatModelState extends _$ChatModelState {
  @override
  ChatModel build({required int width, required int height}) {
    return ChatModel.initial(width, height);
  }

  void updateModel(ChatModel newModel) {
    state = newModel;
  }
}
