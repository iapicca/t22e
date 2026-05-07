import 'dart:io';

import 'package:test/test.dart';
import '../../lib/src/renderer/benchmark.dart';
import '../../lib/src/core/surface.dart';
import '../../lib/src/core/style.dart';

void main() {
  group('BenchmarkSuite', () {
    test('measure records results', () {
      final suite = BenchmarkSuite();
      suite.measure('dummy', () {
        var x = 0;
        for (var i = 0; i < 100; i++) {
          x += i;
        }
      }, iterations: 100);
      expect(suite.results, hasLength(1));
      expect(suite.results.first.name, 'dummy');
      expect(suite.results.first.avgMicros, greaterThan(0));
    });

    test('rendererComparison runs without errors', () {
      final small = Surface(10, 5);
      final large = Surface(20, 10);
      final suite = BenchmarkSuite();
      suite.rendererComparison(small, large);
      expect(suite.results, isNotEmpty);
    });

    test('save/load results round-trips', () {
      final suite = BenchmarkSuite();
      suite.measure('test', () {}, iterations: 10);
      final tempFile = '${Directory.systemTemp.path}/benchmark_test.json';
      suite.saveResults(tempFile);
      final loaded = suite.loadResults(tempFile);
      expect(loaded, hasLength(1));
      expect(loaded.first.name, 'test');
      File(tempFile).deleteSync();
    });
  });
}
