import 'dart:async';
import 'dart:io';

import 'msg.dart' show Msg;

/// Base sealed class for side-effect commands in the MVU runtime.
sealed class Cmd {
  const Cmd();

  /// Executes the command, optionally returning a message to enqueue.
  FutureOr<Msg?> execute(void Function(Msg) enqueue);
}

/// Schedules a one-shot delayed message.
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

/// Starts a periodic timer that enqueues messages at a fixed interval.
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

/// Runs multiple commands concurrently, discarding their messages.
final class BatchCmd extends Cmd {
  final List<Cmd?> commands;

  const BatchCmd(this.commands);

  @override
  FutureOr<Msg?> execute(void Function(Msg) enqueue) async {
    await Future.wait(
      commands.whereType<Cmd>().map(
        (c) => Future<Msg?>.value(c.execute(enqueue)),
      ),
    );
    return null;
  }
}

/// Runs commands sequentially, enqueueing any returned messages.
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

/// Runs an external process and enqueues a message with the exit code.
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

/// A no-op command.
final class NoCmd extends Cmd {
  const NoCmd();

  @override
  FutureOr<Msg?> execute(void Function(Msg) enqueue) => null;
}

/// Factory: one-shot delayed message.
Cmd tick(Duration delay, Msg Function(DateTime) createMsg) =>
    TickCmd(delay, createMsg);

/// Factory: periodic message emitter.
Cmd every(Duration interval, Msg Function(DateTime) createMsg) =>
    EveryCmd(interval, createMsg);

/// Factory: concurrent batch of commands.
Cmd batch(List<Cmd?> commands) => BatchCmd(commands);

/// Factory: sequential chain of commands.
Cmd sequence(List<Cmd> commands) => SequenceCmd(commands);

/// Factory: run an external process.
Cmd execProcess(
  String exe,
  List<String> args, {
  Msg Function(int exitCode)? onExit,
}) => ExecCmd(exe, args, onExit: onExit);

/// Factory: no-op command.
Cmd none() => const NoCmd();
