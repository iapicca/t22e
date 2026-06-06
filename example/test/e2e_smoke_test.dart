import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  final exampleDir = Directory.current.path.endsWith('example')
      ? Directory.current.path
      : '${Directory.current.path}/example';

  test(
    'E2E smoke test: app starts and quits cleanly',
    () async {
      final process = await Process.start('script', [
        '-q',
        '/dev/null',
        'dart',
        'run',
        'bin/example.dart',
      ], workingDirectory: exampleDir);

      final outputLines = <String>[];
      final stderrLines = <String>[];

      process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) => outputLines.add(line));

      process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) => stderrLines.add(line));

      await Future.delayed(const Duration(milliseconds: 500));

      process.stdin.write('q\n');
      await process.stdin.flush();

      final exitCode = await process.exitCode.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          process.kill();
          fail('Process did not exit within timeout');
        },
      );

      expect(exitCode, equals(0));

      final cleanStderr = stderrLines.join('\n').trim();
      expect(
        cleanStderr,
        isEmpty,
        reason: 'Expected no stderr output, got: $cleanStderr',
      );
    },
    timeout: const Timeout(Duration(seconds: 15)),
  );
}
