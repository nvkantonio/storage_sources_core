import 'dart:async';
import 'dart:collection';
import 'package:meta/meta.dart';

import 'callback_completer.dart';

class CallbackCompletersProcesses<T> {
  CallbackCompletersProcesses();

  @protected
  @visibleForTesting
  final Map<int, CallbackCompleter<T>> completersHashMap = HashMap();

  CallbackCompleter<T>? completerOfProcess(Object processLink) =>
      completersHashMap[processLink.hashCode];

  Future<R> run<R extends T>(
    FutureOr<R> Function() callback, {
    required Object processLink,
    dynamic equalityArg = const NoArgument(),
  }) {
    final processHash = processLink.hashCode;
    final hashMapCompleter = completersHashMap[processHash];

    final CallbackCompleter<T> completer;

    if (hashMapCompleter != null) {
      completer = hashMapCompleter;
    } else {
      completer = CallbackCompleter<T>();
      completersHashMap[processHash] = completer;
    }

    return completer.run(callback, equalityArg: equalityArg).whenComplete(
      () {
        if (completersHashMap[processHash]?.isInProgress == false) {
          completersHashMap.remove(processHash);
        }
      },
    );
  }
}
