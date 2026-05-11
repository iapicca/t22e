import 'dart:io';
import 'dart:convert';

import '../core/cell.dart';
import '../core/surface.dart';
import '../well_known.dart' show WellKnown;
import 'frame.dart' show Frame, diff;
import 'line_renderer.dart';
import 'cell_renderer.dart';

class BenchmarkResult {
  final String name;
  final int iterations;
  final double avgMicros;
  final int bytesWritten;
  final DateTime timestamp;

  const BenchmarkResult({
    required this.name,
    required this.iterations,
    required this.avgMicros,
    required this.bytesWritten,
    required this.timestamp,
  });

  Map<String, Object?> toJson() => {
    'name': name,
    'iterations': iterations,
    'avgMicros': avgMicros,
    'bytesWritten': bytesWritten,
    'timestamp': timestamp.toIso8601String(),
  };

  factory BenchmarkResult.fromJson(Map<String, Object?> json) => BenchmarkResult(
    name: json['name'] as String,
    iterations: json['iterations'] as int,
    avgMicros: (json['avgMicros'] as num).toDouble(),
    bytesWritten: json['bytesWritten'] as int,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}

class BenchmarkSuite {
  final List<BenchmarkResult> results = [];

  void measure(String name, void Function() fn, {int iterations = WellKnown.benchmarkIterationsDefault}) {
    final stopwatch = Stopwatch();
    stopwatch.start();
    for (var i = 0; i < iterations; i++) {
      fn();
    }
    stopwatch.stop();
    results.add(BenchmarkResult(
      name: name,
      iterations: iterations,
      avgMicros: stopwatch.elapsedMicroseconds / iterations,
      bytesWritten: 0,
      timestamp: DateTime.now(),
    ));
  }

  void rendererComparison(Surface small, Surface large) {
    final lineRenderer = const LineRenderer();
    final cellRenderer = const CellRenderer();

    _compare('sparse', lineRenderer, cellRenderer, small, large,
        (s) => _makeSparseFrame(s));
    _compare('full', lineRenderer, cellRenderer, small, large,
        (s) => Frame.fromSurface(s, includeCells: true));
  }

  void _compare(
    String label,
    LineRenderer line,
    CellRenderer cell,
    Surface small,
    Surface large,
    Frame Function(Surface) frameFn,
  ) {
    final base = frameFn(small);

      for (final pair in [('line', line), ('cell', cell)]) {
        final rendererName = pair.$1;
        final renderer = pair.$2;

        final stopwatch = Stopwatch();
        const iterations = WellKnown.benchmarkRenderCompareIterations;
        stopwatch.start();
        int totalBytes = 0;
        for (var i = 0; i < iterations; i++) {
          final target = frameFn(large);
          if (renderer is LineRenderer) {
            final d = diff(base, target);
            totalBytes += renderer.render(d, target).length;
          } else {
            totalBytes += (renderer as CellRenderer).render(base, target).length;
          }
        }
        stopwatch.stop();

      results.add(BenchmarkResult(
        name: '$label-$rendererName',
        iterations: iterations,
        avgMicros: stopwatch.elapsedMicroseconds / iterations,
        bytesWritten: totalBytes ~/ iterations,
        timestamp: DateTime.now(),
      ));
    }
  }

  void saveResults(String filePath) {
    final jsonList = results.map((r) => r.toJson()).toList();
    File(filePath).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(jsonList));
  }

  List<BenchmarkResult> loadResults(String filePath) {
    if (!File(filePath).existsSync()) return [];
    final jsonStr = File(filePath).readAsStringSync();
    final list = jsonDecode(jsonStr) as List<Object?>;
    return list.map((e) => BenchmarkResult.fromJson(e as Map<String, Object?>)).toList();
  }

  bool checkRegression(String name, double thresholdPercent) {
    final current = results.where((r) => r.name == name).toList();
    if (current.isEmpty) return false;

    final history = loadResults('benchmark_history.json');
    final historical = history.where((r) => r.name == name).toList();
    if (historical.isEmpty) return false;

    final currentAvg = current.last.avgMicros;
    final historicalAvg = historical.last.avgMicros;

    if (historicalAvg <= 0) return false;
    final change = ((currentAvg - historicalAvg) / historicalAvg) * WellKnown.benchmarkRegressionPercent;
    return change > thresholdPercent;
  }
}

Frame _makeSparseFrame(Surface surface) {
  final cellGrid = surface.grid.map((row) =>
    row.map((c) => Cell(char: c.char, style: c.style, wideContinuation: c.wideContinuation)).toList()
  ).toList();
  final s = Surface.fromGrid(cellGrid);
  return Frame.fromSurface(s, includeCells: true);
}
