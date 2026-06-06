import 'dart:io';

import 'package:test/test.dart';

void main() {
  final exampleDir = Directory.current.path.endsWith('example')
      ? Directory.current.path
      : '${Directory.current.path}/example';

  final testExePath = '$exampleDir/example_app_smoke';

  tearDown(() {
    final testExe = File(testExePath);
    if (testExe.existsSync()) {
      testExe.deleteSync();
    }
  });

  test(
    'Compile smoke test: app compiles to native executable',
    () async {
      final compileResult = await Process.run('dart', [
        'compile',
        'exe',
        'bin/example.dart',
        '-o',
        'example_app_smoke',
      ], workingDirectory: exampleDir);

      expect(compileResult.exitCode, equals(0));

      final testExe = File(testExePath);
      expect(testExe.existsSync(), isTrue);
    },
    timeout: const Timeout(Duration(seconds: 60)),
  );

  test(
    'Compiled executable runs and quits cleanly',
    () async {
      final compileResult = await Process.run('dart', [
        'compile',
        'exe',
        'bin/example.dart',
        '-o',
        'example_app_smoke',
      ], workingDirectory: exampleDir);

      expect(compileResult.exitCode, equals(0));

      final process = await Process.start('script', [
        '-q',
        '/dev/null',
        testExePath,
      ], workingDirectory: exampleDir);

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
    },
    timeout: const Timeout(Duration(seconds: 90)),
  );
}
