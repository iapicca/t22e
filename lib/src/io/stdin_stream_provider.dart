import 'dart:io';

import 'package:riverpod/riverpod.dart';

/// Provides the raw byte stream from [stdin].
///
/// Override this provider in tests with a controlled [Stream].
/// TODO this should use @riverpod
final stdinStreamProvider = Provider<Stream<List<int>>>((ref) => stdin);
