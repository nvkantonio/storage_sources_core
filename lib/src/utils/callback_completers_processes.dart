import 'dart:async';
import 'dart:collection';
import 'package:meta/meta.dart';

import 'callback_completer.dart';

class CallbackCompletersProcesses<T> {
  CallbackCompletersProcesses();

  @protected
  @visibleForTesting
  final Map<Object, CallbackCompleter<T>> completersHashMap = HashMap();

  CallbackCompleter<T>? completerOfProcess(Object processLink) =>
      completersHashMap[processLink];

  Future<R> run<R extends T>(
    FutureOr<R> Function() callback, {
    required Object processLink,
    dynamic equalityArg = const NoArgument(),
  }) {
    final hashMapCompleter = completersHashMap[processLink];

    final CallbackCompleter<T> completer;

    if (hashMapCompleter == null) {
      completer = CallbackCompleter<T>();
      completersHashMap[processLink] = completer;
    } else {
      completer = hashMapCompleter;
    }

    void whenCompleterCompletes() {
      if (completersHashMap[processLink]?.isInProgress == false) {
        completersHashMap.remove(processLink);
      }
    }

    return completer
        .run(callback, equalityArg: equalityArg)
        .whenComplete(whenCompleterCompletes);
  }
}
