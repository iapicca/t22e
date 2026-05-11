import 'dart:async';
import 'dart:io';

import 'msg.dart' show Msg;

sealed class Cmd {
  const Cmd();

  FutureOr<Msg?> execute(void Function(Msg) enqueue);
}

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

final class NoCmd extends Cmd {
  const NoCmd();

  @override
  FutureOr<Msg?> execute(void Function(Msg) enqueue) => null;
}

Cmd tick(Duration delay, Msg Function(DateTime) createMsg) =>
    TickCmd(delay, createMsg);

Cmd every(Duration interval, Msg Function(DateTime) createMsg) =>
    EveryCmd(interval, createMsg);

Cmd batch(List<Cmd?> commands) => BatchCmd(commands);

Cmd sequence(List<Cmd> commands) => SequenceCmd(commands);

Cmd execProcess(
  String exe,
  List<String> args, {
  Msg Function(int exitCode)? onExit,
}) => ExecCmd(exe, args, onExit: onExit);

Cmd none() => const NoCmd();
