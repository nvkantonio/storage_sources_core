import 'dart:async';

import 'package:meta/meta.dart';

final class NoArgument {
  const NoArgument();

  @override
  int get hashCode => super.hashCode;

  @override
  bool operator ==(Object other) => other is NoArgument;
}

final class UniqueArgument {
  const UniqueArgument();

  @override
  int get hashCode => super.hashCode;

  @override
  bool operator ==(Object other) => false;
}

final class CompleterWithArgument<T> {
  CompleterWithArgument(this.equalityArg) : completer = Completer<T>();

  final Completer<T> completer;
  final dynamic equalityArg;
}

class CallbackCompleter<T> {
  CallbackCompleter();

  @protected
  @visibleForTesting
  CompleterWithArgument? completerWithArg;

  CompleterWithArgument? get currentCompleterWithArg => completerWithArg;

  bool get isInProgress =>
      completerWithArg != null && !completerWithArg!.completer.isCompleted;

  Future<R> run<R extends T>(
    FutureOr<R> Function() callback, {
    dynamic equalityArg = const NoArgument(),
  }) {
    final currentCompleterWithArg = completerWithArg;

    if (currentCompleterWithArg == null) {
      final newCompleterWithArg = CompleterWithArgument<R>(equalityArg);
      completerWithArg = newCompleterWithArg;

      return _runCompleter(callback, newCompleterWithArg);
    }

    if (currentCompleterWithArg is CompleterWithArgument<R> &&
        equalityArg == currentCompleterWithArg.equalityArg) {
      return currentCompleterWithArg.completer.future;
    }

    final newCompleterWithArg = CompleterWithArgument<R>(equalityArg);
    completerWithArg = newCompleterWithArg;

    final currentCompleterFuture =
        Future<dynamic>(() => currentCompleterWithArg.completer.future);

    return currentCompleterFuture.catchError((_) => null).then(
      (_) {
        return _runCompleter(callback, newCompleterWithArg);
      },
    );
  }

  bool completerIdenticalTo(CallbackCompleter other) =>
      identical(this.completerWithArg, other.completerWithArg);

  Future<R> _runCompleter<R extends T>(FutureOr<R> Function() callback,
      CompleterWithArgument<R> completerWithArg) {
    final completer = completerWithArg.completer;

    Future(
      () async {
        try {
          final res = await callback();
          completer.complete(res);
        } catch (e, st) {
          completer.completeError(e, st);
        }
      },
    ).whenComplete(() {
      if (identical(completerWithArg, this.completerWithArg)) {
        this.completerWithArg = null;
      }
    });

    return completer.future;
  }
}
