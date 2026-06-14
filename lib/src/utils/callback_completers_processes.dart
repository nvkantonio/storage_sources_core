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

  Future<R> run<R extends T>(FutureOr<R> Function() callback,
      {required Object processLink, dynamic equalityArg = const NoArgument()}) {
    final processHash = processLink.hashCode;
    final completer = completersHashMap[processHash];

    if (completer != null) {
      return completer.run(callback).whenComplete(
        () {
          if (completersHashMap[processHash]?.isInProgress == false) {
            completersHashMap.remove(processHash);
          }
        },
      );
    } else {
      final completer = CallbackCompleter<T>();
      completersHashMap[processHash] = completer;

      return completer.run(callback).whenComplete(
        () {
          if (completersHashMap[processHash]?.isInProgress == false) {
            completersHashMap.remove(processHash);
          }
        },
      );
    }
  }
}
