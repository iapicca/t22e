# Task 5.1.2: Performance Benchmarking

**Story:** Cell-Level Renderer
**Estimate:** M

## Description

Create a benchmarking suite for the rendering pipeline. Measure frame time, bytes written, and throughput for both line-level and cell-level renderers across various scenarios.

## Implementation

```dart
class Benchmark {
  void measure(String name, void Function() fn, {int iterations = 1000}) {
    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < iterations; i++) fn();
    stopwatch.stop();
    print('$name: ${stopwatch.elapsedMicroseconds / iterations} µs avg');
  }
}
```

## Acceptance Criteria

- Benchmarks: frame diff time, render output time, total frame time
- Benchmarks: sparse update (1 cell), row update (1 row), full frame, resize
- Benchmarks: compare line-level vs cell-level renderer
- Output size: measure bytes written per frame type
- CI-integrated: benchmark thresholds fail if performance regresses by >20%
- Historical tracking: benchmark results written to file for trend analysis
