import 'dart:async';

class CallbackCompleter<T> {
  CallbackCompleter();

  Completer<T>? _completer;

  bool get isInProgress => _completer != null && !_completer!.isCompleted;

  Future<T>? get future => _completer?.future;

  Future<T> run(Future<T> Function() callback) async {
    if (_completer != null) {
      return _completer!.future;
    }

    final completer = Completer<T>();
    _completer = completer;

    T? result;
    Object? error;
    StackTrace? stackTrace;

    try {
      final res = await callback();
      result = res;
      return res;
    } catch (e, st) {
      error = e;
      stackTrace = st;
      rethrow;
    } finally {
      if (error != null) {
        completer.completeError(error, stackTrace);
      } else {
        completer.complete(result);
      }
      _completer = null;
    }
  }
}
