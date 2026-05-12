import 'dart:async';
import 'dart:io';

import 'msg.dart' show Msg;

/// Base sealed class for side-effect commands (TEA Cmd)
sealed class Cmd {
  const Cmd();

  /// Executes the side effect and optionally returns a message
  FutureOr<Msg?> execute(void Function(Msg) enqueue);
}

/// A delayed one-shot command that produces a message after a set time
final class TickCmd extends Cmd {
  final Duration delay;
  final Msg Function(DateTime) createMsg;

  const TickCmd(this.delay, this.createMsg);

  @override
  FutureOr<Msg?> execute(void Function(Msg) enqueue) async {
    await Future.delayed(delay);
    return createMsg(DateTime.now());
  }
}

/// A recurring command that produces a message at regular intervals
final class EveryCmd extends Cmd {
  final Duration interval;
  final Msg Function(DateTime) createMsg;

  const EveryCmd(this.interval, this.createMsg);

  @override
  FutureOr<Msg?> execute(void Function(Msg) enqueue) {
    final now = DateTime.now();
    final alignMs = now.millisecondsSinceEpoch % interval.inMilliseconds;
    final firstDelay = Duration(milliseconds: alignMs);
    Timer(firstDelay, () {
      enqueue(createMsg(DateTime.now()));
      Timer.periodic(interval, (_) => enqueue(createMsg(DateTime.now())));
    });
    return null;
  }
}

/// Runs multiple commands concurrently and waits for all to complete
final class BatchCmd extends Cmd {
  final List<Cmd?> commands;

  const BatchCmd(this.commands);

  @override
  FutureOr<Msg?> execute(void Function(Msg) enqueue) async {
    await Future.wait(
      commands.whereType<Cmd>().map((c) => Future<Msg?>.value(c.execute(enqueue))),
    );
    return null;
  }
}

/// Runs commands sequentially, one after another
final class SequenceCmd extends Cmd {
  final List<Cmd> commands;

  const SequenceCmd(this.commands);

  @override
  FutureOr<Msg?> execute(void Function(Msg) enqueue) async {
    for (final cmd in commands) {
      final msg = await cmd.execute(enqueue);
      if (msg != null) enqueue(msg);
    }
    return null;
  }
}

/// Spawns an external process and optionally fires a message on completion
final class ExecCmd extends Cmd {
  final String exe;
  final List<String> args;
  final Msg Function(int exitCode)? onExit;

  const ExecCmd(this.exe, this.args, {this.onExit});

  @override
  FutureOr<Msg?> execute(void Function(Msg) enqueue) async {
    final result = await Process.run(exe, args);
    if (onExit != null) {
      enqueue(onExit!(result.exitCode));
    }
    return null;
  }
}

/// A no-op command that does nothing
final class NoCmd extends Cmd {
  const NoCmd();

  @override
  FutureOr<Msg?> execute(void Function(Msg) enqueue) => null;
}

/// Creates a TickCmd: fires createMsg after delay milliseconds
Cmd tick(Duration delay, Msg Function(DateTime) createMsg) =>
    TickCmd(delay, createMsg);

/// Creates an EveryCmd: fires createMsg at regular intervals
Cmd every(Duration interval, Msg Function(DateTime) createMsg) =>
    EveryCmd(interval, createMsg);

/// Creates a BatchCmd: runs multiple commands concurrently
Cmd batch(List<Cmd?> commands) => BatchCmd(commands);

/// Creates a SequenceCmd: runs commands one after another
Cmd sequence(List<Cmd> commands) => SequenceCmd(commands);

/// Creates an ExecCmd: runs an external process
Cmd execProcess(
  String exe,
  List<String> args, {
  Msg Function(int exitCode)? onExit,
}) =>
    ExecCmd(exe, args, onExit: onExit);

/// Creates a NoCmd: does nothing
Cmd none() => const NoCmd();
