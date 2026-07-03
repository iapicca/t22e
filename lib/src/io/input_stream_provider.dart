import 'dart:async' show StreamController;
import 'dart:io' show stdin;

import 'package:meta/meta.dart' show internal;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'input_stream_provider.g.dart';

/// Provides a [StreamController] forwarding `dart:io` stdin byte chunks.
///
/// Used exclusively by [inputValueProvider]; override in tests with a fake
/// controller.
@riverpod
@internal
StreamController<List<int>> inputStream(Ref ref) {
  final controller = StreamController<List<int>>();
  final subscription = stdin.listen(
    controller.add,
    onError: controller.addError,
    onDone: controller.close,
  );
  ref.onDispose(() {
    subscription.cancel();
    controller.close();
  });
  return controller;
}
