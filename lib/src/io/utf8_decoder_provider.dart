import 'dart:convert' show utf8;

import 'package:meta/meta.dart' show internal;
import 'package:riverpod/riverpod.dart';

import 'utf8_decoder.dart' show Utf8Decoder;

/// Provides the default [Utf8Decoder] (`utf8.decode`); override in tests.
@internal
final utf8DecoderProvider = Provider<Utf8Decoder>(
  (ref) => utf8.decode,
);